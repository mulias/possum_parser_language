const std = @import("std");
const builtin = @import("builtin");
const GoalStage = @import("frontend/goal_ast.zig").Stage;

pub const IS_WASM_FREESTANDING = builtin.target.cpu.arch.isWasm() and builtin.target.os.tag == .freestanding;

pub const Env = struct {
    printScanner: bool,
    printParser: bool,
    printAst: bool,
    printGoalAst: ?GoalStage,
    printCompiledBytecode: bool,
    printExecutedBytecode: bool,
    printVM: bool,
    runVM: bool,
    printGC: bool,
    stressTestGC: bool,
    disableRcFastPaths: bool,
    printMemoryReport: bool,

    pub fn init() Env {
        return Env{
            .printScanner = false,
            .printParser = false,
            .printAst = false,
            .printGoalAst = null,
            .printCompiledBytecode = false,
            .printExecutedBytecode = false,
            .printVM = false,
            .printGC = false,
            .stressTestGC = false,
            .disableRcFastPaths = false,
            .printMemoryReport = false,
            .runVM = true,
        };
    }

    pub fn fromOS(env_map: *const std.process.Environ.Map) Env {
        return Env{
            .printScanner = getFlag(env_map, "PRINT_SCANNER", false),
            .printParser = getFlag(env_map, "PRINT_PARSER", false),
            .printAst = getFlag(env_map, "PRINT_AST", false),
            .printGoalAst = getGoalStage(env_map, "PRINT_GOAL_AST"),
            .printCompiledBytecode = getFlag(env_map, "PRINT_COMPILED_BYTECODE", false),
            .printExecutedBytecode = getFlag(env_map, "PRINT_EXECUTED_BYTECODE", false),
            .printVM = getFlag(env_map, "PRINT_VM", false),
            .printGC = getFlag(env_map, "PRINT_GC", false),
            .stressTestGC = getFlag(env_map, "STRESS_TEST_GC", false),
            .disableRcFastPaths = getFlag(env_map, "DISABLE_RC_FAST_PATHS", false),
            .printMemoryReport = getFlag(env_map, "PRINT_MEMORY_REPORT", false),
            .runVM = getFlag(env_map, "RUN_VM", true),
        };
    }

    fn getFlag(env_map: *const std.process.Environ.Map, key: []const u8, default: bool) bool {
        const value = env_map.get(key) orelse return default;
        return std.mem.eql(u8, value, "true");
    }

    // A stage name selects where in the goal pipeline to print; "true"
    // prints the latest implemented stage.
    fn getGoalStage(env_map: *const std.process.Environ.Map, key: []const u8) ?GoalStage {
        const value = env_map.get(key) orelse return null;
        if (std.mem.eql(u8, value, "true")) return .bound;
        return std.meta.stringToEnum(GoalStage, value);
    }
};
