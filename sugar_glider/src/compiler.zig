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
    locals: ArrayList(StringTable.Id),
    function: *Elem.Dyn.Function,

    const Error = error{
        InvalidAst,
        ChunkWriteFailure,
        NoMainParser,
        MultipleMainParsers,
        MaxFunctionArgs,
        MaxFunctionParams,
        OutOfMemory,
        TooManyConstants,
        ShortOverflow,
    };

    pub fn initMain(vm: *VM, ast: Ast) !Compiler {
        var main = try Elem.Dyn.Function.create(vm, .{
            .name = try vm.addString("@main"),
            .functionType = .Main,
            .arity = 0,
        });

        return try init(vm, ast, main);
    }

    pub fn init(vm: *VM, ast: Ast, function: *Elem.Dyn.Function) !Compiler {
        var locals = ArrayList(StringTable.Id).init(vm.allocator);

        // Frame slot 0 is reserved by the VM for the current function value.
        // This means we can't store a local in this position. Create a
        // placeholder local which is never referenced so that locals on the
        // stack are offset by 1.
        const placeholderName = try vm.strings.insert("@localPlaceholder");
        try locals.append(placeholderName);

        return Compiler{
            .vm = vm,
            .ast = ast,
            .locals = locals,
            .function = function,
        };
    }

    pub fn deinit(self: *Compiler) void {
        self.locals.deinit();
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

    fn compileMainParser(self: *Compiler, nodeId: usize) !void {
        try self.writeParser(nodeId);
        try self.emitOp(.End, self.ast.endLocation);

        if (logger.debugCompiler) {
            self.function.disassemble(self.vm.strings);
        }
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
                .ValueVar => try self.compileGlobalValue(headNodeId, bodyNodeId),
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

        const nameLoc = self.ast.getLocation(nameNodeId);
        const bodyLoc = self.ast.getLocation(bodyNodeId);

        const nameConstId = try self.makeConstant(Elem.parserVar(globalName));

        // Simple no-param single elem case
        if (paramsNodeId == null) {
            if (self.ast.getElem(bodyNodeId)) |bodyElem| {
                const parserConstId = try self.makeConstant(bodyElem);

                try self.emitUnaryOp(.GetConstant, parserConstId, bodyLoc);
                try self.emitUnaryOp(.SetGlobal, nameConstId, nameLoc);

                return;
            }
        }

        // Otherwise create a new function
        const function = try self.writeFunction(parserName, paramsNodeId, bodyNodeId);

        const functionConstId = try self.makeConstant(function.dyn.elem());

        try self.emitUnaryOp(.GetConstant, functionConstId, bodyLoc);
        try self.emitUnaryOp(.SetGlobal, nameConstId, nameLoc);
    }

    fn compileGlobalValue(self: *Compiler, nameNodeId: usize, bodyNodeId: usize) !void {
        const nameElem = switch (self.ast.getNode(nameNodeId)) {
            .ElemNode => |elem| switch (elem) {
                .ValueVar => elem,
                else => return Error.InvalidAst,
            },
            else => return Error.InvalidAst,
        };

        const nameLoc = self.ast.getLocation(nameNodeId);

        const nameConstId = try self.makeConstant(nameElem);

        try self.writeValue(bodyNodeId);
        try self.emitUnaryOp(.SetGlobal, nameConstId, nameLoc);
    }

    fn writeFunction(self: *Compiler, functionName: StringTable.Id, paramsNodeId: ?usize, bodyNodeId: usize) !*Elem.Dyn.Function {
        var function = try Elem.Dyn.Function.create(self.vm, .{
            .name = functionName,
            .functionType = .NamedFunction,
            .arity = 0,
        });

        var compiler = try init(self.vm, self.ast, function);
        defer compiler.deinit();

        if (paramsNodeId) |nodeId| {
            var paramsNode = compiler.ast.getNode(nodeId);

            while (true) {
                if (function.arity == std.math.maxInt(u8)) {
                    printError(
                        std.fmt.comptimePrint("Can't have more than {} parameters.", .{std.math.maxInt(u8)}),
                        self.ast.getLocation(nodeId),
                    );
                    return Error.MaxFunctionParams;
                }

                compiler.function.arity += 1;

                switch (paramsNode) {
                    .ElemNode => |elem| {
                        // This is the last param
                        try compiler.addLocalElem(elem);
                        break;
                    },
                    .InfixNode => |infix| {
                        if (infix.infixType == .ParamsOrArgs) {
                            if (self.ast.getElem(infix.left)) |leftElem| {
                                try compiler.addLocalElem(leftElem);
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

        try compiler.writeParser(bodyNodeId);

        try compiler.emitOp(.End, compiler.ast.getLocation(bodyNodeId));

        if (logger.debugCompiler) {
            compiler.function.disassemble(compiler.vm.strings);
        }

        return compiler.function;
    }

    fn writeParser(self: *Compiler, nodeId: usize) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Backtrack => {
                    try self.writeParser(infix.left);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.emitOp(.Backtrack, loc);
                    try self.writeParser(infix.right);
                    try self.patchJump(jumpIndex, loc);
                },
                .Merge,
                .TakeLeft,
                .TakeRight,
                => {
                    try self.writeParser(infix.left);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeParser(infix.right);
                    try self.writeParserOp(infix.infixType, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .Destructure => {
                    try self.writePattern(infix.left);
                    try self.writeParser(infix.right);
                    try self.writeParserOp(infix.infixType, loc);
                },
                .Or => {
                    try self.writeParser(infix.left);
                    const jumpIndex = try self.emitJump(.JumpIfSuccess, loc);
                    try self.writeParser(infix.right);
                    try self.writeParserOp(infix.infixType, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .Return => {
                    try self.writeParser(infix.left);
                    try self.writeValue(infix.right);
                    try self.writeParserOp(infix.infixType, loc);
                },
                .ConditionalIfThen => {
                    // Then/Else is always the right-side node
                    const thenElseOp = self.ast.getInfixOfType(infix.right, .ConditionalThenElse).?;
                    const thenElseLoc = self.ast.getLocation(infix.right);

                    // Get each part of `ifNodeId ? thenNodeId : elseNodeId`
                    const ifNodeId = infix.left;
                    const thenNodeId = thenElseOp.left;
                    const elseNodeId = thenElseOp.right;

                    try self.writeParser(ifNodeId);
                    const failureJumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeParser(thenNodeId);
                    try self.emitOp(.TakeRight, self.ast.getLocation(thenNodeId));
                    const successJumpIndex = try self.emitJump(.JumpIfSuccess, thenElseLoc);
                    try self.patchJump(failureJumpIndex, loc);
                    try self.writeParser(elseNodeId);
                    try self.emitOp(.Or, self.ast.getLocation(elseNodeId));
                    try self.patchJump(successJumpIndex, thenElseLoc);
                },
                .ConditionalThenElse => @panic("internal error"), // always handled via ConditionalIfThen
                .DeclareGlobal => unreachable,
                .CallOrDefineFunction => {
                    try self.writeGetParser(infix.left);
                    const argCount = try self.writeArguments(infix.right);
                    try self.emitUnaryOp(.CallParser, argCount, loc);
                },
                .ParamsOrArgs => @panic("internal error"), // always handled via CallOrDefineFunction
            },
            .ElemNode => try self.writeParserElem(nodeId),
        }
    }

    fn writeParserOp(self: *Compiler, infixType: Ast.InfixType, loc: Location) !void {
        const opCode: OpCode = switch (infixType) {
            .Backtrack => .Backtrack,
            .Destructure => .Destructure,
            .Merge => .MergeParsed,
            .Or => .Or,
            .Return => .Return,
            .TakeLeft => .TakeLeft,
            .TakeRight => .TakeRight,
            .ConditionalIfThen,
            .ConditionalThenElse,
            .CallOrDefineFunction,
            .DeclareGlobal,
            .ParamsOrArgs,
            => unreachable, // No eqivalent OpCode
        };

        try self.emitOp(opCode, loc);
    }

    fn writeParserElem(self: *Compiler, nodeId: usize) !void {
        const loc = self.ast.getLocation(nodeId);

        switch (self.ast.getNode(nodeId)) {
            .ElemNode => |elem| {
                switch (elem) {
                    .ParserVar => |sId| {
                        try self.writeGetParserWithName(sId, loc);
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
                        try self.emitOp(.RunParser, loc);
                    },
                    .True => {
                        // In this context `true` could be a zero-arg function call
                        const sId = try self.vm.addString("true");
                        try self.writeGetParserWithName(sId, loc);
                        try self.emitUnaryOp(.CallParser, 0, loc);
                    },
                    .False => {
                        // In this context `false` could be a zero-arg function call
                        const sId = try self.vm.addString("false");
                        try self.writeGetParserWithName(sId, loc);
                        try self.emitUnaryOp(.CallParser, 0, loc);
                    },
                    .Null => {
                        // In this context `null` could be a zero-arg function call
                        const sId = try self.vm.addString("null");
                        try self.writeGetParserWithName(sId, loc);
                        try self.emitUnaryOp(.CallParser, 0, loc);
                    },
                    .Character,
                    .Integer,
                    .Float,
                    => unreachable, // not produced by the parser
                    .Dyn => |d| switch (d.dynType) {
                        .String => unreachable, // not produced by the parser
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

    fn writeGetParser(self: *Compiler, nodeId: usize) !void {
        const parserName = switch (self.ast.getNode(nodeId)) {
            .ElemNode => |elem| switch (elem) {
                .ParserVar => |sId| sId,
                .ValueVar => |sId| sId,
                .True => try self.vm.strings.insert("true"),
                .False => try self.vm.strings.insert("false"),
                .Null => try self.vm.strings.insert("null"),
                else => return Error.InvalidAst,
            },
            .InfixNode => return Error.InvalidAst,
        };

        const loc = self.ast.getLocation(nodeId);

        try self.writeGetParserWithName(parserName, loc);
    }

    fn writeGetParserWithName(self: *Compiler, parserName: StringTable.Id, loc: Location) !void {
        if (self.resolveLocal(parserName)) |local| {
            try self.emitUnaryOp(.GetLocal, @as(u8, @intCast(local)), loc);
        } else {
            const constId = try self.makeConstant(Elem.parserVar(parserName));
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
        switch (self.ast.getNode(nodeId)) {
            .InfixNode => try self.writeAnonymousFunction(nodeId),
            .ElemNode => |elem| {
                const loc = self.ast.getLocation(nodeId);
                const constId = try self.makeConstant(elem);
                try self.emitUnaryOp(.GetConstant, constId, loc);
            },
        }
    }

    fn writeAnonymousFunction(self: *Compiler, nodeId: usize) !void {
        _ = nodeId;
        _ = self;
        @panic("todo");
    }

    fn writePattern(self: *Compiler, nodeId: usize) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Merge => {
                    try self.writePattern(infix.left);
                    try self.writePattern(infix.right);
                    try self.emitOp(.MergeElems, loc);
                },
                else => {
                    printError("Invalid infix operator in pattern", loc);
                    return Error.InvalidAst;
                },
            },
            .ElemNode => |elem| try self.writePatternElem(elem, loc),
        }
    }

    fn writePatternElem(self: *Compiler, elem: Elem, loc: Location) !void {
        switch (elem) {
            .ParserVar => {
                printError("parser is not valid in pattern", loc);
                return Error.InvalidAst;
            },
            .ValueVar,
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
            .Character,
            .Integer,
            .Float,
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
                .String => unreachable, // not produced by the parser
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
                    try self.emitOp(.MergeElems, loc);
                },
                else => {
                    printError("Invalid infix operator in value", loc);
                    return Error.InvalidAst;
                },
            },
            .ElemNode => |elem| try self.writeValueElem(elem, loc),
        }
    }

    fn writeValueElem(self: *Compiler, elem: Elem, loc: Location) !void {
        switch (elem) {
            .ParserVar => {
                printError("Parser is not valid in value", loc);
                return Error.InvalidAst;
            },
            .ValueVar => {
                const constId = try self.makeConstant(elem);
                try self.emitUnaryOp(.GetConstant, constId, loc);
                try self.emitOp(.SubstituteValue, loc);
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
            .Character,
            .Integer,
            .Float,
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
                .String => unreachable, // not produced by the parser
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
        }
    }

    fn chunk(self: *Compiler) *Chunk {
        return &self.function.chunk;
    }

    fn addLocalElem(self: *Compiler, elem: Elem) !void {
        const sId = switch (elem) {
            .ParserVar => |sId| sId,
            .ValueVar => |sId| sId,
            else => return Error.InvalidAst,
        };

        try self.addLocal(sId);
    }

    fn addLocal(self: *Compiler, name: StringTable.Id) !void {
        for (self.locals.items) |local| {
            if (name == local) {
                return error.VariableNameUsedInScope;
            }
        }

        try self.locals.append(name);
    }

    pub fn resolveLocal(self: *Compiler, name: StringTable.Id) ?usize {
        var i = self.locals.items.len;
        while (i > 0) {
            i -= 1;

            if (self.locals.items[i] == name) {
                return i;
            }
        }

        return null;
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
