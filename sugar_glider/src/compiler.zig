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
    functions: ArrayList(*Elem.Dyn.Function),

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
        InvalidGlobalValue,
        InvalidGlobalParser,
        AliasCycle,
        UnknownVariable,
        UndefinedVariable,
        FunctionCallTooManyArgs,
        FunctionCallTooFewArgs,
    };

    pub fn init(vm: *VM, ast: Ast) !Compiler {
        var main = try Elem.Dyn.Function.create(vm, .{
            .name = try vm.strings.insert("@main"),
            .functionType = .Main,
            .arity = 0,
        });

        var functions = ArrayList(*Elem.Dyn.Function).init(vm.allocator);
        try functions.append(main);

        return Compiler{
            .vm = vm,
            .ast = ast,
            .functions = functions,
        };
    }

    pub fn deinit(self: *Compiler) void {
        self.functions.deinit();
    }

    pub fn compile(self: *Compiler) !*Elem.Dyn.Function {
        try self.declareGlobals();
        try self.validateGlobals();
        try self.resolveGlobalAliases();
        try self.compileGlobalFunctions();
        try self.compileMain();
        return self.functions.pop();
    }

    pub fn compileLib(self: *Compiler) !void {
        try self.declareGlobals();
        try self.validateGlobals();
        try self.resolveGlobalAliases();
        try self.compileGlobalFunctions();
    }

    fn declareGlobals(self: *Compiler) !void {
        for (self.ast.roots.items) |nodeId| {
            if (self.ast.getInfixOfType(nodeId, .DeclareGlobal)) |infix| {
                try self.declareGlobal(infix.left, infix.right);
            }
        }
    }

    fn validateGlobals(self: *Compiler) !void {
        for (self.ast.roots.items) |nodeId| {
            if (self.ast.getInfixOfType(nodeId, .DeclareGlobal)) |infix| {
                try self.validateGlobal(infix.left);
            }
        }
    }

    fn resolveGlobalAliases(self: *Compiler) !void {
        for (self.ast.roots.items) |nodeId| {
            if (self.ast.getInfixOfType(nodeId, .DeclareGlobal)) |infix| {
                try self.resolveGlobalAlias(infix.left);
            }
        }
    }

    fn compileGlobalFunctions(self: *Compiler) !void {
        for (self.ast.roots.items) |nodeId| {
            if (self.ast.getInfixOfType(nodeId, .DeclareGlobal)) |infix| {
                try self.compileGlobalFunction(infix.left, infix.right);
            }
        }
    }

    fn compileMain(self: *Compiler) !void {
        var mainNodeId: ?usize = null;

        for (self.ast.roots.items) |nodeId| {
            if (self.ast.getInfixOfType(nodeId, .DeclareGlobal) == null) {
                if (mainNodeId == null) {
                    mainNodeId = nodeId;
                } else {
                    return Error.MultipleMainParsers;
                }
            }
        }

        if (mainNodeId) |nodeId| {
            try self.addValueLocals(nodeId);
            try self.writeParser(nodeId, false);
            try self.emitOp(.End, self.ast.endLocation);
        } else {
            return Error.NoMainParser;
        }
    }

    fn declareGlobal(self: *Compiler, headNodeId: usize, bodyNodeId: usize) !void {
        switch (self.ast.getNode(headNodeId)) {
            .InfixNode => |infix| switch (infix.infixType) {
                .CallOrDefineFunction => {
                    // A function with params
                    const nameNodeId = infix.left;
                    const paramsNodeId = infix.right;
                    try self.declareGlobalFunction(nameNodeId, paramsNodeId);
                },
                else => return Error.InvalidAst,
            },
            .ElemNode => |nameElem| switch (self.ast.getNode(bodyNodeId)) {
                .InfixNode => {
                    // A function without params
                    try self.declareGlobalFunction(headNodeId, null);
                },
                .ElemNode => |bodyElem| {
                    try self.declareGlobalAlias(nameElem, bodyElem);
                },
            },
        }
    }

    fn declareGlobalFunction(self: *Compiler, nameNodeId: usize, paramsNodeId: ?usize) !void {
        // Create a new function and add the params to the function struct.
        // Leave the function's bytecode chunk empty for now.
        // Add the function to the globals namespace.

        const nameElem = self.ast.getElem(nameNodeId) orelse return Error.InvalidAst;
        const nameVar = try self.elemToVar(nameElem) orelse return Error.InvalidAst;
        const name = switch (nameVar) {
            .ValueVar => |sId| sId,
            .ParserVar => |sId| sId,
            else => return Error.InvalidAst,
        };
        const functionType: Elem.Dyn.FunctionType = switch (nameVar) {
            .ValueVar => .NamedValue,
            .ParserVar => .NamedParser,
            else => return Error.InvalidAst,
        };

        var function = try Elem.Dyn.Function.create(self.vm, .{
            .name = name,
            .functionType = functionType,
            .arity = 0,
        });

        try self.vm.globals.put(name, function.dyn.elem());

        try self.functions.append(function);

        if (paramsNodeId) |firstParamNodeId| {
            var paramNode = self.ast.getNode(firstParamNodeId);
            var paramLoc = self.ast.getLocation(firstParamNodeId);

            while (true) {
                switch (paramNode) {
                    .InfixNode => |infix| {
                        if (infix.infixType == .ParamsOrArgs) {
                            if (self.ast.getElem(infix.left)) |leftElem| {
                                _ = try self.addLocal(
                                    leftElem,
                                    self.ast.getLocation(infix.left),
                                );
                                function.arity += 1;
                            } else {
                                return Error.InvalidAst;
                            }
                        } else {
                            return Error.InvalidAst;
                        }

                        paramNode = self.ast.getNode(infix.right);
                        paramLoc = self.ast.getLocation(infix.right);
                    },
                    .ElemNode => |elem| {
                        // This is the last param
                        _ = try self.addLocal(elem, paramLoc);
                        function.arity += 1;
                        break;
                    },
                }
            }
        }

        _ = self.functions.pop();
    }

    fn declareGlobalAlias(self: *Compiler, nameElem: Elem, bodyElem: Elem) !void {
        // Add an alias to the global namespace. Set the given body element as the alias's value.
        const nameVar = try self.elemToVar(nameElem) orelse return Error.InvalidAst;
        const name = switch (nameVar) {
            .ValueVar => |sId| sId,
            .ParserVar => |sId| sId,
            else => return Error.InvalidAst,
        };

        try self.vm.globals.put(name, bodyElem);
    }

    fn validateGlobal(self: *Compiler, headNodeId: usize) !void {
        const nameElem = switch (self.ast.getNode(headNodeId)) {
            .InfixNode => |infix| self.ast.getElem(infix.left) orelse return Error.InvalidAst,
            .ElemNode => |elem| elem,
        };
        const nameVar = try self.elemToVar(nameElem) orelse return Error.InvalidAst;

        switch (nameVar) {
            .ValueVar => |name| switch (self.vm.globals.get(name).?) {
                .ValueVar,
                .String,
                .Integer,
                .Float,
                .IntegerString,
                .FloatString,
                .True,
                .False,
                .Null,
                => {},
                .ParserVar,
                .CharacterRange,
                .IntegerRange,
                => return Error.InvalidGlobalValue,
                .Dyn => |dyn| switch (dyn.dynType) {
                    .String,
                    .Array,
                    .Object,
                    => {},
                    .Function => {
                        if (dyn.asFunction().functionType != .NamedValue) {
                            return Error.InvalidGlobalValue;
                        }
                    },
                    .Closure => @panic("Internal Error"),
                },
                .Success,
                .Failure,
                => @panic("Internal Error"),
            },
            .ParserVar => |name| switch (self.vm.globals.get(name).?) {
                .ParserVar,
                .String,
                .Integer,
                .Float,
                .IntegerString,
                .FloatString,
                .CharacterRange,
                .IntegerRange,
                => {},
                .ValueVar => return Error.InvalidGlobalParser,
                .Dyn => |dyn| switch (dyn.dynType) {
                    .String => {},
                    .Array,
                    .Object,
                    => return Error.InvalidGlobalParser,
                    .Function => {
                        if (dyn.asFunction().functionType != .NamedParser) {
                            return Error.InvalidGlobalParser;
                        }
                    },
                    .Closure => @panic("Internal Error"),
                },
                .Success,
                .Failure,
                .True,
                .False,
                .Null,
                => @panic("Internal Error"),
            },
            else => @panic("Internal Error"),
        }
    }

    fn resolveGlobalAlias(self: *Compiler, headNodeId: usize) !void {
        const globalName = try self.getGlobalName(headNodeId);
        var aliasName = globalName;
        var value = self.vm.globals.get(aliasName);

        if (!value.?.isType(.ValueVar) and !value.?.isType(.ParserVar)) {
            return;
        }

        var path = ArrayList(StringTable.Id).init(self.vm.allocator);
        defer path.deinit();

        while (true) {
            if (value) |foundValue| {
                try path.append(aliasName);

                aliasName = switch (foundValue) {
                    .ValueVar => |name| name,
                    .ParserVar => |name| name,
                    else => {
                        try self.vm.globals.put(globalName, foundValue);
                        break;
                    },
                };

                for (path.items) |aliasVisited| {
                    if (aliasName == aliasVisited) {
                        return Error.AliasCycle;
                    }
                }

                value = self.vm.globals.get(aliasName);
            } else {
                return Error.UnknownVariable;
            }
        }
    }

    fn compileGlobalFunction(self: *Compiler, headNodeId: usize, bodyNodeId: usize) !void {
        const globalName = try self.getGlobalName(headNodeId);
        const globalVal = self.vm.globals.get(globalName).?;

        // Exit early if the node is an alias, not a function def
        switch (self.ast.getNode(headNodeId)) {
            .ElemNode => switch (self.ast.getNode(bodyNodeId)) {
                .InfixNode => {},
                .ElemNode => return,
            },
            .InfixNode => {},
        }

        if (globalVal.isDynType(.Function)) {
            var function = globalVal.asDyn().asFunction();

            try self.functions.append(function);

            if (function.functionType == .NamedParser) {
                try self.addValueLocals(bodyNodeId);
                try self.writeParser(bodyNodeId, true);
            } else {
                try self.writeValueFunction(bodyNodeId, true);
            }

            try self.emitOp(.End, self.ast.getLocation(bodyNodeId));

            _ = self.functions.pop();
        }
    }

    fn getGlobalName(self: *Compiler, headNodeId: usize) !StringTable.Id {
        const nameElem = switch (self.ast.getNode(headNodeId)) {
            .InfixNode => |infix| self.ast.getElem(infix.left) orelse return Error.InvalidAst,
            .ElemNode => |elem| elem,
        };
        const nameVar = try self.elemToVar(nameElem) orelse return Error.InvalidAst;
        const name = switch (nameVar) {
            .ValueVar => |sId| sId,
            .ParserVar => |sId| sId,
            else => return Error.InvalidAst,
        };
        return name;
    }

    fn writeParser(self: *Compiler, nodeId: usize, isTailPosition: bool) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

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
                    try self.writeValue(infix.right, true);
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
                    try self.writeParserFunctionCall(infix.left, infix.right, isTailPosition);
                },
                .ParamsOrArgs => @panic("internal error"), // always handled via CallOrDefineFunction
                .ArrayHead,
                .ArrayCons,
                => return Error.InvalidAst,
            },
            .ElemNode => try self.writeParserElem(nodeId),
        }
    }

    fn writeParserFunctionCall(self: *Compiler, functionNodeId: usize, argsNodeId: usize, isTailPosition: bool) !void {
        const functionElem = self.ast.getElem(functionNodeId) orelse @panic("internal error");
        const functionLoc = self.ast.getLocation(functionNodeId);

        const functionName = switch (functionElem) {
            .ParserVar => |sId| sId,
            .True => try self.vm.strings.insert("true"),
            .False => try self.vm.strings.insert("false"),
            .Null => try self.vm.strings.insert("null"),
            else => return Error.InvalidAst,
        };

        var function: ?*Elem.Dyn.Function = null;

        if (self.localSlot(functionName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, functionLoc);
        } else {
            if (self.vm.globals.get(functionName)) |global| {
                function = global.asDyn().asFunction();
                const constId = try self.makeConstant(global);
                try self.emitUnaryOp(.GetConstant, constId, functionLoc);
            } else {
                return Error.UndefinedVariable;
            }
        }

        const argCount = try self.writeParserFunctionArguments(argsNodeId, function);

        if (isTailPosition) {
            try self.emitUnaryOp(.CallTailFunction, argCount, functionLoc);
        } else {
            try self.emitUnaryOp(.CallFunction, argCount, functionLoc);
        }
    }

    fn writeParserElem(self: *Compiler, nodeId: usize) !void {
        const loc = self.ast.getLocation(nodeId);

        switch (self.ast.getNode(nodeId)) {
            .ElemNode => |elem| {
                switch (elem) {
                    .ParserVar => {
                        try self.writeGetVar(elem, loc, .Parser);
                        try self.emitUnaryOp(.CallFunction, 0, loc);
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
                        try self.emitUnaryOp(.CallFunction, 0, loc);
                    },
                    .True => {
                        // In this context `true` could be a zero-arg function call
                        try self.writeGetVar(elem, loc, .Parser);
                        try self.emitUnaryOp(.CallFunction, 0, loc);
                    },
                    .False => {
                        // In this context `false` could be a zero-arg function call
                        try self.writeGetVar(elem, loc, .Parser);
                        try self.emitUnaryOp(.CallFunction, 0, loc);
                    },
                    .Null => {
                        // In this context `null` could be a zero-arg function call
                        try self.writeGetVar(elem, loc, .Parser);
                        try self.emitUnaryOp(.CallFunction, 0, loc);
                    },
                    .Integer,
                    .Float,
                    .Success,
                    .Failure,
                    => unreachable, // not produced by the parser
                    .Dyn => @panic("internal error"), // not produced by the parser
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
            if (self.vm.globals.get(varName)) |globalElem| {
                const constId = try self.makeConstant(globalElem);
                try self.emitUnaryOp(.GetConstant, constId, loc);
            } else {
                return Error.UndefinedVariable;
            }
        }
    }

    fn elemToVar(self: *Compiler, elem: Elem) !?Elem {
        return switch (elem) {
            .ParserVar,
            .ValueVar,
            => elem,
            .True => Elem.parserVar(try self.vm.strings.insert("true")),
            .False => Elem.parserVar(try self.vm.strings.insert("false")),
            .Null => Elem.parserVar(try self.vm.strings.insert("null")),
            else => null,
        };
    }

    const ArgType = enum { Parser, Value, Unspecified };

    fn writeParserFunctionArguments(self: *Compiler, nodeId: usize, function: ?*Elem.Dyn.Function) Error!u8 {
        var argCount: u8 = 0;
        var argsNodeId = nodeId;
        var argType: ArgType = .Unspecified;

        while (true) {
            if (argCount == std.math.maxInt(u8)) {
                printError(
                    std.fmt.comptimePrint("Can't have more than {} parameters.", .{std.math.maxInt(u8)}),
                    self.ast.getLocation(nodeId),
                );
                return Error.MaxFunctionArgs;
            }

            argCount += 1;

            if (function) |f| {
                if (f.arity < argCount) return Error.FunctionCallTooManyArgs;

                const argPos = argCount - 1;
                switch (f.localVar(argPos)) {
                    .ParserVar => argType = .Parser,
                    .ValueVar => argType = .Value,
                }
            } else {
                argType = .Unspecified;
            }

            if (self.ast.getInfixOfType(argsNodeId, .ParamsOrArgs)) |infix| {
                try self.writeParserFunctionArgument(infix.left, argType);
                argsNodeId = infix.right;
            } else {
                // This is the last arg
                try self.writeParserFunctionArgument(argsNodeId, argType);
                break;
            }
        }

        if (function) |f| {
            if (f.arity != argCount) return Error.FunctionCallTooFewArgs;
        }

        return argCount;
    }

    fn writeParserFunctionArgument(self: *Compiler, nodeId: usize, argType: ArgType) !void {
        const loc = self.ast.getLocation(nodeId);

        if (argType == .Parser) {
            switch (self.ast.getNode(nodeId)) {
                .InfixNode => {
                    const function = try self.writeAnonymousFunction(nodeId);
                    const constId = try self.makeConstant(function.dyn.elem());
                    try self.emitUnaryOp(.GetConstant, constId, loc);
                    try self.writeCaptureLocals(function, loc);
                },
                .ElemNode => |elem| switch (elem) {
                    .ParserVar => try self.writeGetVar(elem, loc, .Value),
                    else => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                    },
                },
            }
        } else if (argType == .Value) {
            try self.writeValue(nodeId, false);
        } else {
            @panic("todo");
        }
    }

    fn writeAnonymousFunction(self: *Compiler, nodeId: usize) !*Elem.Dyn.Function {
        const loc = self.ast.getLocation(nodeId);

        var function = try Elem.Dyn.Function.create(self.vm, .{
            .name = try self.nextAnonFunctionName(),
            .functionType = .AnonParser,
            .arity = 0,
        });

        try self.functions.append(function);

        try self.addClosureLocals(nodeId);

        if (function.locals.items.len > 0) {
            try self.emitOp(.SetClosureCaptures, loc);
        }

        try self.writeParser(nodeId, true);
        try self.emitOp(.End, loc);

        return self.functions.pop();
    }

    fn writeCaptureLocals(self: *Compiler, targetFunction: *Elem.Dyn.Function, loc: Location) !void {
        for (self.currentFunction().locals.items, 0..) |local, fromSlot| {
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
                .CallOrDefineFunction => {
                    try self.writeValueFunctionCall(infix.left, infix.right, false);
                },
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
                .ValueVar => |name| {
                    if (self.localSlot(name)) |slot| {
                        try self.emitUnaryOp(.GetLocal, slot, loc);
                    } else if (self.vm.globals.get(name)) |globalElem| {
                        const constId = try self.makeConstant(globalElem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                        if (globalElem.isDynType(.Function) and globalElem.asDyn().asFunction().arity == 0) {
                            try self.emitUnaryOp(.CallFunction, 0, loc);
                        }
                    } else {
                        return Error.UndefinedVariable;
                    }
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
                    .Function,
                    .Closure,
                    => @panic("Internal Error"), // not produced by the parser
                    .Array,
                    .Object,
                    => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                    },
                },
            },
        }
    }

    fn addValueLocals(self: *Compiler, nodeId: usize) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        switch (node) {
            .InfixNode => |infix| {
                try self.addValueLocals(infix.left);
                try self.addValueLocals(infix.right);
            },
            .ElemNode => |elem| switch (elem) {
                .ValueVar => |varName| if (self.vm.globals.get(varName) == null) {
                    const newLocalId = try self.addLocalIfUndefined(elem, loc);
                    if (newLocalId) |_| {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                    }
                },
                else => {},
            },
        }
    }

    fn addClosureLocals(self: *Compiler, nodeId: usize) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        switch (node) {
            .InfixNode => |infix| {
                try self.addClosureLocals(infix.left);
                try self.addClosureLocals(infix.right);
            },
            .ElemNode => |elem| {
                const varName = switch (elem) {
                    .ValueVar => |name| name,
                    .ParserVar => |name| name,
                    else => null,
                };

                if (varName) |name| {
                    if (self.parentFunction().localSlot(name) != null) {
                        const newLocalId = try self.addLocalIfUndefined(elem, loc);
                        if (newLocalId) |_| {
                            const constId = try self.makeConstant(elem);
                            try self.emitUnaryOp(.GetConstant, constId, loc);
                        }
                    }
                }
            },
        }
    }

    fn writeValue(self: *Compiler, nodeId: usize, isTailPosition: bool) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Merge => {
                    try self.writeValue(infix.left, false);
                    try self.writeValue(infix.right, false);
                    try self.emitOp(.Merge, loc);
                },
                .ArrayHead => {
                    try self.writeArray(infix.left, infix.right);
                    try self.emitOp(.ResolveUnboundVars, loc);
                },
                .ArrayCons => @panic("internal error"),
                .CallOrDefineFunction => {
                    try self.writeValueFunctionCall(infix.left, infix.right, isTailPosition);
                },
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
                .ValueVar => |name| {
                    if (self.localSlot(name)) |slot| {
                        // This local will either be a concrete value or
                        // unbound, it won't be a function. Value functions are
                        // all defined globally and called immediately. This
                        // means that if a function takes a value function as
                        // an arg then the value function will be called before
                        // the outer function, and the value used when calling
                        // the outer function will be concrete.
                        try self.emitUnaryOp(.GetBoundLocal, slot, loc);
                    } else if (self.vm.globals.get(name)) |globalElem| {
                        const constId = try self.makeConstant(globalElem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                        if (globalElem.isDynType(.Function) and globalElem.asDyn().asFunction().arity == 0) {
                            if (isTailPosition) {
                                try self.emitUnaryOp(.CallTailFunction, 0, loc);
                            } else {
                                try self.emitUnaryOp(.CallFunction, 0, loc);
                            }
                        }
                    } else {
                        return Error.UndefinedVariable;
                    }
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
                    printError("Character range is not valid in value", loc);
                    return Error.InvalidAst;
                },
                .IntegerRange => {
                    printError("Integer range is not valid in value", loc);
                    return Error.InvalidAst;
                },
                .Dyn => |d| switch (d.dynType) {
                    .String,
                    .Function,
                    .Closure,
                    => @panic("Internal Error"), // not produced by the parser
                    .Array,
                    .Object,
                    => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                    },
                },
            },
        }
    }

    fn writeValueFunction(self: *Compiler, nodeId: usize, isTailPosition: bool) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .ArrayHead => {
                    try self.writeArray(infix.left, infix.right);
                    try self.emitOp(.ResolveUnboundVars, loc);
                },
                .Backtrack => {
                    try self.writeValueFunction(infix.left, false);
                    const jumpIndex = try self.emitJump(.Backtrack, loc);
                    try self.writeValueFunction(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Merge => {
                    try self.writeValueFunction(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeValueFunction(infix.right, false);
                    try self.emitOp(.Merge, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .TakeLeft => {
                    try self.writeValueFunction(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeValueFunction(infix.right, false);
                    try self.emitOp(.TakeLeft, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .TakeRight => {
                    try self.writeValueFunction(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, loc);
                    try self.writeValueFunction(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Destructure => {
                    try self.writePattern(infix.left);
                    try self.writeValueFunction(infix.right, false);
                    try self.emitOp(.Destructure, loc);
                },
                .Or => {
                    try self.writeValueFunction(infix.left, false);
                    const jumpIndex = try self.emitJump(.Or, loc);
                    try self.writeValueFunction(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Return => {
                    try self.writeValueFunction(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, loc);
                    try self.writeValueFunction(infix.right, true);
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

                    try self.writeValueFunction(ifNodeId, false);
                    const ifThenJumpIndex = try self.emitJump(.ConditionalThen, loc);
                    try self.writeValueFunction(thenNodeId, isTailPosition);
                    const thenElseJumpIndex = try self.emitJump(.ConditionalElse, thenElseLoc);
                    try self.patchJump(ifThenJumpIndex, loc);
                    try self.writeValueFunction(elseNodeId, isTailPosition);
                    try self.patchJump(thenElseJumpIndex, thenElseLoc);
                },
                .CallOrDefineFunction => {
                    try self.writeValueFunctionCall(infix.left, infix.right, isTailPosition);
                },
                .ArrayCons, // handled by writeArray
                .ConditionalThenElse, // handled by ConditionalIfThen
                .DeclareGlobal, // handled by top-level compiler functions
                .ParamsOrArgs, // handled by CallOrDefineFunction
                => @panic("internal error"),
            },
            .ElemNode => try self.writeValue(nodeId, isTailPosition),
        }
    }

    fn writeValueFunctionCall(self: *Compiler, functionNodeId: usize, argsNodeId: usize, isTailPosition: bool) !void {
        const functionElem = self.ast.getElem(functionNodeId) orelse @panic("internal error");
        const functionLoc = self.ast.getLocation(functionNodeId);

        const functionName = switch (functionElem) {
            .ValueVar => |sId| sId,
            else => return Error.InvalidAst,
        };

        var function: ?*Elem.Dyn.Function = null;

        if (self.localSlot(functionName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, functionLoc);
        } else {
            if (self.vm.globals.get(functionName)) |global| {
                function = global.asDyn().asFunction();
                const constId = try self.makeConstant(global);
                try self.emitUnaryOp(.GetConstant, constId, functionLoc);
            } else {
                return Error.UndefinedVariable;
            }
        }

        const argCount = try self.writeValueFunctionArguments(argsNodeId, function);

        if (isTailPosition) {
            try self.emitUnaryOp(.CallTailFunction, argCount, functionLoc);
        } else {
            try self.emitUnaryOp(.CallFunction, argCount, functionLoc);
        }
    }

    fn writeValueFunctionArguments(self: *Compiler, nodeId: usize, function: ?*Elem.Dyn.Function) Error!u8 {
        var argCount: u8 = 0;
        var argsNodeId = nodeId;
        var loc: Location = undefined;

        while (true) {
            loc = self.ast.getLocation(nodeId);

            if (argCount == std.math.maxInt(u8)) {
                printError(
                    std.fmt.comptimePrint("Can't have more than {} parameters.", .{std.math.maxInt(u8)}),
                    self.ast.getLocation(nodeId),
                );
                return Error.MaxFunctionArgs;
            }

            argCount += 1;

            if (self.ast.getInfixOfType(argsNodeId, .ParamsOrArgs)) |infix| {
                try self.writeValue(infix.left, false);
                argsNodeId = infix.right;
            } else {
                // This is the last arg
                try self.writeValue(argsNodeId, false);
                break;
            }
        }

        if (function) |f| {
            if (f.arity < argCount) return Error.FunctionCallTooManyArgs;
            if (f.arity > argCount) return Error.FunctionCallTooFewArgs;
        }

        return argCount;
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
        return &self.currentFunction().chunk;
    }

    fn currentFunction(self: *Compiler) *Elem.Dyn.Function {
        return self.functions.items[self.functions.items.len - 1];
    }

    fn parentFunction(self: *Compiler) *Elem.Dyn.Function {
        var parentIndex = self.functions.items.len - 2;
        while (true) {
            if (self.functions.items[parentIndex].functionType == .AnonParser) {
                parentIndex -= 1;
            } else {
                return self.functions.items[parentIndex];
            }
        }
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

        return self.currentFunction().addLocal(local) catch |err| switch (err) {
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
        return self.currentFunction().localSlot(name);
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
