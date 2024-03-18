const std = @import("std");
const ArrayList = std.ArrayList;
const Ast = @import("ast.zig").Ast;
const Chunk = @import("./chunk.zig").Chunk;
const ChunkError = @import("./chunk.zig").ChunkError;
const Elem = @import("./elem.zig").Elem;
const Location = @import("location.zig").Location;
const OpCode = @import("./op_code.zig").OpCode;
const Scanner = @import("./scanner.zig").Scanner;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("./vm.zig").VM;
const logger = @import("./logger.zig");

pub const Compiler = struct {
    vm: *VM,
    ast: Ast,
    function: *Elem.Dyn.Function,

    const Error = error{
        InvalidAst,
        ChunkWriteFailure,
        NoMainParser,
        MultipleMainParsers,
        UnexpectedMainParser,
        MaxFunctionArgs,
        MaxFunctionLocals,
        OutOfMemory,
        TooManyConstants,
        ShortOverflow,
        VariableNameUsedInScope,
    };

    pub fn init(vm: *VM, ast: Ast) !Compiler {
        var main = try Elem.Dyn.Function.create(vm, .{
            .name = try vm.strings.insert("@main"),
            .functionType = .Main,
            .arity = 0,
        });

        return try initWithFunction(vm, ast, main);
    }

    fn initWithFunction(vm: *VM, ast: Ast, function: *Elem.Dyn.Function) !Compiler {
        return Compiler{
            .vm = vm,
            .ast = ast,
            .function = function,
        };
    }

    pub fn deinit(self: *Compiler) void {
        _ = self;
    }

    pub fn compile(self: *Compiler) !*Elem.Dyn.Function {
        var mainNodeId: ?usize = null;

        for (self.ast.roots.items) |nodeId| {
            if (self.ast.getInfixOfType(nodeId, .DeclareGlobal)) |infix| {
                try self.compileGlobalDeclaration(infix.left, infix.right);
            } else if (mainNodeId == null) {
                mainNodeId = nodeId;
            } else {
                return Error.MultipleMainParsers;
            }
        }

        if (mainNodeId) |nodeId| {
            try self.compileMainParser(nodeId);
        } else {
            return Error.NoMainParser;
        }

        self.ast = undefined;

        return self.function;
    }

    pub fn compileLib(self: *Compiler) !void {
        for (self.ast.roots.items) |nodeId| {
            if (self.ast.getInfixOfType(nodeId, .DeclareGlobal)) |infix| {
                try self.compileGlobalDeclaration(infix.left, infix.right);
            } else {
                return Error.UnexpectedMainParser;
            }
        }

        self.ast = undefined;
    }

    fn compileMainParser(self: *Compiler, nodeId: usize) !void {
        try self.writeParser(nodeId, false);
        try self.emitOp(.End, self.ast.endLocation);
    }

    fn compileGlobalDeclaration(self: *Compiler, headNodeId: usize, bodyNodeId: usize) !void {
        switch (self.ast.getNode(headNodeId)) {
            .InfixNode => |infix| switch (infix.infixType) {
                .CallOrDefineFunction => {
                    const nameNodeId = infix.left;
                    const paramsNodeId = infix.right;
                    try self.compileGlobalFunction(nameNodeId, paramsNodeId, bodyNodeId);
                },
                else => return Error.InvalidAst,
            },
            .ElemNode => |nameElem| switch (nameElem) {
                .ParserVar => try self.compileGlobalFunction(headNodeId, null, bodyNodeId),
                .ValueVar => {
                    try self.compileGlobalValue(headNodeId, bodyNodeId);
                },
                else => return Error.InvalidAst,
            },
        }
    }

    // Create a parser or value in the global namespace. The word "function"
    // here is a bit misleading. All globals can be considered as functions,
    // but not all functions require allocating a function struct with a new
    // chunk of bytecode.
    //
    // ```
    // # Global string parser "function"
    // foo = "foo"
    //
    // # Global string value "function"
    // Foo = "foo"
    //
    // # Global function, even though param is unused
    // foo(a) = "foo"
    //
    // # Global function, even though it takes 0 params
    // foobar = "foo" + "bar"
    //
    // # Global function
    // double(p) = p + p
    // ```
    //
    // To compile a global function we first check if both the params node is
    // null and the body is a single elem. In this case the global var points
    // to the elem as the parser/value. Otherwise we create a new function
    // elem. The body AST is compiled into the funciton's bytecode. In the main
    // function we then load the function elem as a global.
    fn compileGlobalFunction(self: *Compiler, nameNodeId: usize, paramsNodeId: ?usize, bodyNodeId: usize) !void {
        const globalName = switch (self.ast.getNode(nameNodeId)) {
            .ElemNode => |elem| switch (elem) {
                .ParserVar => |sId| sId,
                .True => try self.vm.strings.insert("true"),
                .False => try self.vm.strings.insert("false"),
                .Null => try self.vm.strings.insert("null"),
                else => return Error.InvalidAst,
            },
            else => return Error.InvalidAst,
        };

        if (self.isMetaVar(globalName)) {
            return Error.InvalidAst;
        }

        // Simple no-param single elem case
        if (paramsNodeId == null) {
            if (self.ast.getElem(bodyNodeId)) |bodyElem| {
                try self.vm.globals.put(globalName, bodyElem);
                return;
            }
        }

        // Otherwise create a new function
        const function = try self.writeFunction(globalName, paramsNodeId, bodyNodeId);
        try self.vm.globals.put(globalName, function.dyn.elem());
    }

    fn compileGlobalValue(self: *Compiler, nameNodeId: usize, bodyNodeId: usize) !void {
        const globalName = switch (self.ast.getNode(nameNodeId)) {
            .ElemNode => |elem| switch (elem) {
                .ValueVar => |sId| sId,
                else => return Error.InvalidAst,
            },
            else => return Error.InvalidAst,
        };

        if (self.isMetaVar(globalName)) {
            return Error.InvalidAst;
        }

        if (self.ast.getElem(bodyNodeId)) |bodyElem| {
            try self.vm.globals.put(globalName, bodyElem);
        } else {
            // Otherwise create a new value function
            @panic("todo");
        }
    }

    fn writeFunction(self: *Compiler, functionName: StringTable.Id, paramsNodeId: ?usize, bodyNodeId: usize) !*Elem.Dyn.Function {
        var function = try Elem.Dyn.Function.create(self.vm, .{
            .name = functionName,
            .functionType = .NamedFunction,
            .arity = 0,
        });

        var compiler = try initWithFunction(self.vm, self.ast, function);
        defer compiler.deinit();

        if (paramsNodeId) |nodeId| {
            var paramsNode = compiler.ast.getNode(nodeId);

            while (true) {
                switch (paramsNode) {
                    .ElemNode => |elem| {
                        // This is the last param
                        _ = try compiler.addLocal(
                            elem,
                            self.ast.getLocation(nodeId),
                        );
                        compiler.function.arity += 1;
                        break;
                    },
                    .InfixNode => |infix| {
                        if (infix.infixType == .ParamsOrArgs) {
                            if (self.ast.getElem(infix.left)) |leftElem| {
                                _ = try compiler.addLocal(
                                    leftElem,
                                    self.ast.getLocation(infix.left),
                                );
                                compiler.function.arity += 1;
                            } else {
                                return Error.InvalidAst;
                            }
                        } else {
                            return Error.InvalidAst;
                        }

                        paramsNode = self.ast.getNode(infix.right);
                    },
                }
            }
        }

        try compiler.writeParser(bodyNodeId, true);

        try compiler.emitOp(.End, compiler.ast.getLocation(bodyNodeId));

        return compiler.function;
    }

    fn writeParser(self: *Compiler, nodeId: usize, isTailPosition: bool) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        try self.addPatternLocals(nodeId, false);

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Backtrack => {
                    try self.emitOp(.SetInputMark, loc);
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.Backtrack, loc);
                    try self.writeParser(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Merge => {
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeParser(infix.right, false);
                    try self.emitOp(.Merge, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .TakeLeft => {
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeParser(infix.right, false);
                    try self.emitOp(.TakeLeft, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .TakeRight => {
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, loc);
                    try self.writeParser(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Destructure => {
                    try self.writePattern(infix.left);
                    try self.writeParser(infix.right, false);
                    try self.emitOp(.Destructure, loc);
                },
                .Or => {
                    try self.emitOp(.SetInputMark, loc);
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.Or, loc);
                    try self.writeParser(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Return => {
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, loc);
                    try self.writeValue(infix.right);
                    try self.patchJump(jumpIndex, loc);
                },
                .ConditionalIfThen => {
                    // Then/Else is always the right-side node
                    const thenElseOp = self.ast.getInfixOfType(
                        infix.right,
                        .ConditionalThenElse,
                    ) orelse return Error.InvalidAst;
                    const thenElseLoc = self.ast.getLocation(infix.right);

                    // Get each part of `ifNodeId ? thenNodeId : elseNodeId`
                    const ifNodeId = infix.left;
                    const thenNodeId = thenElseOp.left;
                    const elseNodeId = thenElseOp.right;

                    try self.writeParser(ifNodeId, false);
                    const ifThenJumpIndex = try self.emitJump(.ConditionalThen, loc);
                    try self.writeParser(thenNodeId, isTailPosition);
                    const thenElseJumpIndex = try self.emitJump(.ConditionalElse, thenElseLoc);
                    try self.patchJump(ifThenJumpIndex, loc);
                    try self.writeParser(elseNodeId, isTailPosition);
                    try self.patchJump(thenElseJumpIndex, thenElseLoc);
                },
                .ConditionalThenElse => @panic("internal error"), // always handled via ConditionalIfThen
                .DeclareGlobal => unreachable,
                .CallOrDefineFunction => {
                    // Call a function
                    const functionNode = self.ast.getElem(infix.left) orelse @panic("internal error");
                    const functionLoc = self.ast.getLocation(infix.left);
                    try self.writeGetVar(functionNode, functionLoc, .Value);
                    const argCount = try self.writeArguments(infix.right);
                    if (isTailPosition) {
                        try self.emitUnaryOp(.CallTailParser, argCount, loc);
                    } else {
                        try self.emitUnaryOp(.CallParser, argCount, loc);
                    }
                },
                .ParamsOrArgs => @panic("internal error"), // always handled via CallOrDefineFunction
                .ArrayHead,
                .ArrayCons,
                => return Error.InvalidAst,
            },
            .ElemNode => try self.writeParserElem(nodeId),
        }
    }

    fn writeParserElem(self: *Compiler, nodeId: usize) !void {
        const loc = self.ast.getLocation(nodeId);

        switch (self.ast.getNode(nodeId)) {
            .ElemNode => |elem| {
                switch (elem) {
                    .ParserVar => {
                        try self.writeGetVar(elem, loc, .Parser);
                        try self.emitUnaryOp(.CallParser, 0, loc);
                    },
                    .ValueVar => {
                        printError("Variable is only valid as a pattern or value", loc);
                        return Error.InvalidAst;
                    },
                    .String,
                    .IntegerString,
                    .FloatString,
                    .CharacterRange,
                    .IntegerRange,
                    => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                        try self.emitUnaryOp(.CallParser, 0, loc);
                    },
                    .True => {
                        // In this context `true` could be a zero-arg function call
                        try self.writeGetVar(elem, loc, .Parser);
                        try self.emitUnaryOp(.CallParser, 0, loc);
                    },
                    .False => {
                        // In this context `false` could be a zero-arg function call
                        try self.writeGetVar(elem, loc, .Parser);
                        try self.emitUnaryOp(.CallParser, 0, loc);
                    },
                    .Null => {
                        // In this context `null` could be a zero-arg function call
                        try self.writeGetVar(elem, loc, .Parser);
                        try self.emitUnaryOp(.CallParser, 0, loc);
                    },
                    .Integer,
                    .Float,
                    .Success,
                    .Failure,
                    => unreachable, // not produced by the parser
                    .Dyn => |d| switch (d.dynType) {
                        .String,
                        .Closure,
                        => unreachable, // not produced by the parser
                        .Array => {
                            printError("Array literal is only valid as a pattern or value", loc);
                            return Error.InvalidAst;
                        },
                        .Object => {
                            printError("Object literal is only valid as a pattern or value", loc);
                            return Error.InvalidAst;
                        },
                        .Function => @panic("internal error"), // not produced by the parser
                    },
                }
            },
            .InfixNode => return Error.InvalidAst,
        }
    }

    fn writeGetVar(self: *Compiler, elem: Elem, loc: Location, context: enum { Parser, Pattern, Value }) !void {
        const varName = switch (elem) {
            .ParserVar => |sId| sId,
            .ValueVar => |sId| sId,
            .True => try self.vm.strings.insert("true"),
            .False => try self.vm.strings.insert("false"),
            .Null => try self.vm.strings.insert("null"),
            else => return Error.InvalidAst,
        };

        if (self.localSlot(varName)) |slot| {
            if (context == .Pattern) {
                try self.emitUnaryOp(.GetLocal, slot, loc);
            } else {
                try self.emitUnaryOp(.GetBoundLocal, slot, loc);
            }
        } else {
            const constId = try self.makeConstant(elem);
            try self.emitUnaryOp(.GetGlobal, constId, loc);
        }
    }

    fn writeArguments(self: *Compiler, nodeId: usize) Error!u8 {
        var argCount: u8 = 0;
        var argsNodeId = nodeId;

        while (true) {
            if (argCount == std.math.maxInt(u8)) {
                printError(
                    std.fmt.comptimePrint("Can't have more than {} parameters.", .{std.math.maxInt(u8)}),
                    self.ast.getLocation(nodeId),
                );
                return Error.MaxFunctionArgs;
            }

            argCount += 1;

            if (self.ast.getInfixOfType(argsNodeId, .ParamsOrArgs)) |infix| {
                try self.writeArgument(infix.left);
                argsNodeId = infix.right;
            } else {
                // This is the last arg
                try self.writeArgument(argsNodeId);
                break;
            }
        }

        return argCount;
    }

    fn writeArgument(self: *Compiler, nodeId: usize) !void {
        const loc = self.ast.getLocation(nodeId);

        switch (self.ast.getNode(nodeId)) {
            .InfixNode => {
                const function = try self.writeAnonymousFunction(nodeId);
                const constId = try self.makeConstant(function.dyn.elem());
                try self.emitUnaryOp(.GetConstant, constId, loc);
                try self.writeCaptureLocals(function, loc);
            },
            .ElemNode => |elem| switch (elem) {
                .ParserVar,
                .ValueVar,
                => try self.writeGetVar(elem, loc, .Value),
                else => {
                    const constId = try self.makeConstant(elem);
                    try self.emitUnaryOp(.GetConstant, constId, loc);
                },
            },
        }
    }

    fn writeAnonymousFunction(self: *Compiler, nodeId: usize) !*Elem.Dyn.Function {
        var function = try Elem.Dyn.Function.create(self.vm, .{
            .name = try self.nextAnonFunctionName(),
            .functionType = .AnonFunction,
            .arity = 0,
        });

        var compiler = try initWithFunction(self.vm, self.ast, function);
        defer compiler.deinit();

        try compiler.writeParser(nodeId, true);

        try compiler.emitOp(.End, compiler.ast.getLocation(nodeId));

        return compiler.function;
    }

    fn writeCaptureLocals(self: *Compiler, targetFunction: *Elem.Dyn.Function, loc: Location) !void {
        for (self.function.locals.items, 0..) |local, fromSlot| {
            if (targetFunction.localSlot(local.name())) |toSlot| {
                try self.emitOp(.CaptureLocal, loc);
                try self.emitByte(@as(u8, @intCast(fromSlot)), loc);
                try self.emitByte(toSlot, loc);
            }
        }
    }

    fn nextAnonFunctionName(self: *Compiler) !StringTable.Id {
        const id = self.vm.nextUniqueId();
        const name = try std.fmt.allocPrint(self.vm.allocator, "@fn{d}", .{id});
        defer self.vm.allocator.free(name);
        return self.vm.strings.insert(name);
    }

    fn writePattern(self: *Compiler, nodeId: usize) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Merge => {
                    try self.writePattern(infix.left);
                    try self.writePattern(infix.right);
                    try self.emitOp(.Merge, loc);
                },
                .ArrayHead => {
                    try self.writeArray(infix.left, infix.right);
                },
                .ArrayCons => @panic("internal error"),
                else => {
                    printError("Invalid infix operator in pattern", loc);
                    return Error.InvalidAst;
                },
            },
            .ElemNode => |elem| switch (elem) {
                .ParserVar => {
                    printError("parser is not valid in pattern", loc);
                    return Error.InvalidAst;
                },
                .ValueVar => {
                    try self.writeGetVar(elem, loc, .Pattern);
                },
                .String,
                .IntegerString,
                .FloatString,
                => {
                    const constId = try self.makeConstant(elem);
                    try self.emitUnaryOp(.GetConstant, constId, loc);
                },
                .True => try self.emitOp(.True, loc),
                .False => try self.emitOp(.False, loc),
                .Null => try self.emitOp(.Null, loc),
                .Integer,
                .Float,
                .Success,
                .Failure,
                => unreachable, // not produced by the parser
                .CharacterRange => {
                    printError("Character range is not valid in pattern", loc);
                    return Error.InvalidAst;
                },
                .IntegerRange => {
                    printError("Integer range is not valid in pattern", loc);
                    return Error.InvalidAst;
                },
                .Dyn => |d| switch (d.dynType) {
                    .String,
                    .Closure,
                    => unreachable, // not produced by the parser
                    .Array,
                    .Object,
                    => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                    },
                    .Function => {
                        printError("Function is not valid in pattern", loc);
                        return Error.InvalidAst;
                    },
                },
            },
        }
    }

    fn addPatternLocals(self: *Compiler, nodeId: usize, isPattern: bool) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Destructure => {
                    try self.addPatternLocals(infix.left, true);
                    try self.addPatternLocals(infix.right, false);
                },
                .ArrayHead => {
                    try self.addPatternLocals(infix.right, isPattern);
                },
                .ArrayCons,
                .Merge,
                => {
                    try self.addPatternLocals(infix.left, isPattern);
                    try self.addPatternLocals(infix.right, isPattern);
                },
                else => {
                    try self.addPatternLocals(infix.left, false);
                    try self.addPatternLocals(infix.right, false);
                },
            },
            .ElemNode => |elem| switch (elem) {
                .ValueVar => if (isPattern) {
                    // If the var in the pattern is new to the function scope
                    // then push the var onto the stack, create a new local for
                    // it and return the local's stack position. Then check to
                    // see if there's a global value with the same name, and if
                    // so update the local.
                    //
                    // Alternatively, The pattern var might already be defined
                    // as a local, for example in `is_eql(p, V) = V <- p` the
                    // `V` is a function param so the passed arg will already
                    // be bound to a local. In this case no bytecode is emitted.
                    const newLocalId = try self.addLocalIfUndefined(elem, loc);
                    if (newLocalId) |local| {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                        try self.emitUnaryOp(.TryResolveUnboundLocal, local, loc);
                    }
                },
                else => {},
            },
        }
    }

    fn writeValue(self: *Compiler, nodeId: usize) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Merge => {
                    try self.writeValue(infix.left);
                    try self.writeValue(infix.right);
                    try self.emitOp(.Merge, loc);
                },
                .ArrayHead => {
                    try self.writeArray(infix.left, infix.right);
                    try self.emitOp(.ResolveUnboundVars, loc);
                },
                .ArrayCons => @panic("internal error"),
                else => {
                    printError("Invalid infix operator in value", loc);
                    return Error.InvalidAst;
                },
            },
            .ElemNode => |elem| switch (elem) {
                .ParserVar => {
                    printError("Parser is not valid in value", loc);
                    return Error.InvalidAst;
                },
                .ValueVar => try self.writeGetVar(elem, loc, .Value),
                .String,
                .IntegerString,
                .FloatString,
                => {
                    const constId = try self.makeConstant(elem);
                    try self.emitUnaryOp(.GetConstant, constId, loc);
                },
                .True => try self.emitOp(.True, loc),
                .False => try self.emitOp(.False, loc),
                .Null => try self.emitOp(.Null, loc),
                .Integer,
                .Float,
                .Success,
                .Failure,
                => unreachable, // not produced by the parser
                .CharacterRange => {
                    printError("Character range is not valid in value", loc);
                    return Error.InvalidAst;
                },
                .IntegerRange => {
                    printError("Integer range is not valid in value", loc);
                    return Error.InvalidAst;
                },
                .Dyn => |d| switch (d.dynType) {
                    .String,
                    .Closure,
                    => unreachable, // not produced by the parser
                    .Array,
                    .Object,
                    => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                    },
                    .Function => {
                        printError("Function is not valid in value", loc);
                        return Error.InvalidAst;
                    },
                },
            },
        }
    }

    fn writeArray(self: *Compiler, startNodeId: usize, itemNodeId: usize) !void {
        // The first left node is the empty array
        var arrayElem = self.ast.getElem(startNodeId) orelse @panic("Internal Error");
        var arrayLoc = self.ast.getLocation(startNodeId);

        var array = arrayElem.asDyn().asArray();

        const constId = try self.makeConstant(arrayElem);
        try self.emitUnaryOp(.GetConstant, constId, arrayLoc);

        try self.appendArrayElems(array, itemNodeId);
    }

    fn appendArrayElems(self: *Compiler, array: *Elem.Dyn.Array, itemNodeId: usize) !void {
        var nodeId = itemNodeId;

        while (true) {
            const loc = self.ast.getLocation(nodeId);
            _ = loc;

            switch (self.ast.getNode(nodeId)) {
                .InfixNode => |infix| {
                    std.debug.assert(infix.infixType == .ArrayCons);

                    switch (self.ast.getNode(infix.left)) {
                        .InfixNode => |nestedInfix| switch (nestedInfix.infixType) {
                            .ArrayHead => {
                                var nestedArray = self.ast.getElem(nestedInfix.left) orelse @panic("Internal Error");
                                try self.appendArrayElems(
                                    nestedArray.asDyn().asArray(),
                                    nestedInfix.right,
                                );
                                try self.appendArrayElem(array, nestedArray);
                            },
                            .ArrayCons => @panic("internal error"),
                            else => @panic("todo"),
                        },
                        .ElemNode => |elem| try self.appendArrayElem(array, elem),
                    }

                    nodeId = infix.right;
                },
                .ElemNode => |elem| {
                    // The last array element
                    try self.appendArrayElem(array, elem);
                    break;
                },
            }
        }
    }

    fn appendArrayElem(self: *Compiler, array: *Elem.Dyn.Array, elem: Elem) !void {
        switch (elem) {
            .ValueVar => |name| {
                try array.addPatternElem(
                    name,
                    array.elems.items.len,
                    self.localSlot(name).?,
                );
            },
            else => {},
        }
        try array.append(elem);
    }

    fn chunk(self: *Compiler) *Chunk {
        return &self.function.chunk;
    }

    fn addLocal(self: *Compiler, elem: Elem, loc: Location) !?u8 {
        const local: Elem.Dyn.Function.Local = switch (elem) {
            .ParserVar => |sId| .{ .ParserVar = sId },
            .ValueVar => |sId| .{ .ValueVar = sId },
            else => return Error.InvalidAst,
        };

        if (self.isMetaVar(local.name())) {
            return Error.InvalidAst;
        }

        return self.function.addLocal(local) catch |err| switch (err) {
            error.MaxFunctionLocals => {
                printError(
                    std.fmt.comptimePrint(
                        "Can't have more than {} parameters and local variables.",
                        .{std.math.maxInt(u8)},
                    ),
                    loc,
                );
                return err;
            },
            else => return err,
        };
    }

    fn addLocalIfUndefined(self: *Compiler, elem: Elem, loc: Location) !?u8 {
        return self.addLocal(elem, loc) catch |err| switch (err) {
            error.VariableNameUsedInScope => return null,
            else => return err,
        };
    }

    pub fn localSlot(self: *Compiler, name: StringTable.Id) ?u8 {
        return self.function.localSlot(name);
    }

    fn isMetaVar(self: *Compiler, sId: StringTable.Id) bool {
        return self.vm.strings.get(sId)[0] == '@';
    }

    fn emitJump(self: *Compiler, op: OpCode, loc: Location) !usize {
        try self.emitOp(op, loc);
        // Dummy operands that will be patched later
        try self.chunk().writeShort(0xffff, loc);
        return self.chunk().nextByteIndex() - 2;
    }

    fn patchJump(self: *Compiler, offset: usize, loc: Location) !void {
        const jump = self.chunk().nextByteIndex() - offset - 2;

        std.debug.assert(self.chunk().read(offset) == 0xff);
        std.debug.assert(self.chunk().read(offset + 1) == 0xff);

        self.chunk().updateShortAt(offset, @as(u16, @intCast(jump))) catch |err| switch (err) {
            ChunkError.ShortOverflow => {
                printError("Too much code to jump over.", loc);
                return err;
            },
            else => return err,
        };
    }

    fn emitByte(self: *Compiler, byte: u8, loc: Location) !void {
        try self.chunk().write(byte, loc);
    }

    fn emitOp(self: *Compiler, op: OpCode, loc: Location) !void {
        try self.chunk().writeOp(op, loc);
    }

    fn emitUnaryOp(self: *Compiler, op: OpCode, byte: u8, loc: Location) !void {
        try self.emitOp(op, loc);
        try self.emitByte(byte, loc);
    }

    fn makeConstant(self: *Compiler, elem: Elem) !u8 {
        return self.chunk().addConstant(elem) catch |err| switch (err) {
            ChunkError.TooManyConstants => {
                logger.err("Too many constants in one chunk.", .{});
                return err;
            },
            else => return err,
        };
    }

    fn printError(message: []const u8, loc: Location) void {
        loc.print(logger.err);
        logger.err(" Error: {s}\n", .{message});
    }
};
