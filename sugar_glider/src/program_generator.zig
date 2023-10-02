const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const Parser = enum {
    String,
    CharacterRange,
    Number,
    IntegerRange,
    Or,
    TakeRight,
    TakeLeft,
    Merge,
    Backtrack,
    Destructure,
    Return,
    Sequence,
    Conditional,
    Group,
};

pub const ProgramGenerator = struct {
    arena: ArenaAllocator,
    seed: u64,
    rand: std.rand.Xoshiro256,

    pub fn init(alloc: Allocator, seed: u64) ProgramGenerator {
        return ProgramGenerator{
            .arena = std.heap.ArenaAllocator.init(alloc),
            .seed = seed,
            .rand = std.rand.DefaultPrng.init(seed),
        };
    }

    pub fn deinit(self: *ProgramGenerator) void {
        self.arena.deinit();
    }

    pub fn random(self: *ProgramGenerator) []const u8 {
        return self.gen(self.randomInfixParser());
    }

    fn gen(self: *ProgramGenerator, parser: Parser) []const u8 {
        return switch (parser) {
            .String => self.genString(),
            .CharacterRange => self.genCharacterRange(),
            .Number => self.genNumber(),
            .IntegerRange => self.genIntegerRange(),
            .Or => self.genBinary("|"),
            .TakeRight => self.genBinary(">"),
            .TakeLeft => self.genBinary("<"),
            .Merge => self.genBinary("+"),
            .Backtrack => self.genBinary("!"),
            .Destructure => self.genBinary("<-"),
            .Return => self.genBinary("$"),
            .Sequence => self.genBinary("&"),
            .Conditional => self.genTernary("?", ":"),
            .Group => self.genGroup(),
        };
    }

    fn randomParser(self: *ProgramGenerator) Parser {
        return switch (self.rand.random().int(u3)) {
            0, 1 => .String,
            2, 3 => .Number,
            4 => .CharacterRange,
            5 => .IntegerRange,
            6, 7 => self.randomInfixParser(),
        };
    }

    fn randomInfixParser(self: *ProgramGenerator) Parser {
        return switch (self.rand.random().int(u4)) {
            0, 1 => .Or,
            2, 3 => .TakeRight,
            4, 5 => .TakeLeft,
            6, 7 => .Merge,
            8 => .Backtrack,
            9, 10 => .Destructure,
            11, 12 => .Return,
            13, 14 => .Sequence,
            15 => .Conditional,
        };
    }

    fn genString(self: *ProgramGenerator) []const u8 {
        _ = self;
        return "\"foo\"";
    }

    fn genCharacterRange(self: *ProgramGenerator) []const u8 {
        _ = self;
        return "\"a\"..\"z\"";
    }

    fn genNumber(self: *ProgramGenerator) []const u8 {
        return self.buildString("{d}", .{self.rand.random().int(i64)});
    }

    fn genIntegerRange(self: *ProgramGenerator) []const u8 {
        _ = self;
        return "0..9";
    }

    fn genBinary(self: *ProgramGenerator, infix: []const u8) []const u8 {
        const left = self.gen(self.randomParser());
        const right = self.gen(self.randomParser());
        return self.buildString("{s} {s} {s}", .{ left, infix, right });
    }

    fn genTernary(self: *ProgramGenerator, infixA: []const u8, infixB: []const u8) []const u8 {
        const left = self.gen(self.randomParser());
        const center = self.gen(self.randomParser());
        const right = self.gen(self.randomParser());
        return self.buildString("{s} {s} {s} {s} {s}", .{ left, infixA, center, infixB, right });
    }

    fn genGroup(self: *ProgramGenerator) []const u8 {
        const inner = self.gen(self.randomInfixParser());
        return self.buildString("({s})", .{inner});
    }

    fn buildString(self: *ProgramGenerator, comptime fmt: []const u8, args: anytype) []const u8 {
        return std.fmt.allocPrint(self.arena.allocator(), fmt, args) catch unreachable;
    }
};
