const std = @import("std");
const Allocator = std.mem.Allocator;
const builtin = @import("builtin");

pub const IS_WASM_FREESTANDING = builtin.target.isWasm() and builtin.target.os.tag == .freestanding;

pub const Env = struct {
    printScanner: bool,
    printParser: bool,
    printAst: bool,
    printCompiledBytecode: bool,
    printExecutedBytecode: bool,
    printVM: bool,
    runVM: bool,

    pub fn init() Env {
        return Env{
            .printScanner = false,
            .printParser = false,
            .printAst = false,
            .printCompiledBytecode = false,
            .printExecutedBytecode = false,
            .printVM = false,
            .runVM = true,
        };
    }

    pub fn fromOS(allocator: Allocator) !Env {
        return Env{
            .printScanner = try getFlag(allocator, "PRINT_SCANNER", false),
            .printParser = try getFlag(allocator, "PRINT_PARSER", false),
            .printAst = try getFlag(allocator, "PRINT_AST", false),
            .printCompiledBytecode = try getFlag(allocator, "PRINT_COMPILED_BYTECODE", false),
            .printExecutedBytecode = try getFlag(allocator, "PRINT_EXECUTED_BYTECODE", false),
            .printVM = try getFlag(allocator, "PRINT_VM", false),
            .runVM = try getFlag(allocator, "RUN_VM", true),
        };
    }

    fn getFlag(allocator: Allocator, key: []const u8, default: bool) !bool {
        const value = std.process.getEnvVarOwned(allocator, key) catch |err| switch (err) {
            error.EnvironmentVariableNotFound => return default,
            else => |e| return e,
        };
        defer allocator.free(value);

        return std.mem.eql(u8, value, "true");
    }
};
