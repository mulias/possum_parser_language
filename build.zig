const std = @import("std");
const Build = std.Build;
const Target = std.Target;
const SemanticVersion = std.SemanticVersion;

pub fn build(b: *Build) void {
    const t = b.standardTargetOptions(.{});
    const o = b.standardOptimizeOption(.{});

    runStep(b, t, o);
    checkStep(b, t, o);
    testStep(b, t, o);
    releaseStep(b);
}

const version: SemanticVersion = .{ .major = 0, .minor = 4, .patch = 0 };

fn versionString(b: *Build) []const u8 {
    return b.fmt("{d}.{d}.{d}", .{ version.major, version.minor, version.patch });
}

fn addCliExecutable(b: *Build, name: []const u8, target: anytype, optimize: anytype) *Build.Step.Compile {
    const clap_module = b.dependency("clap", .{
        .target = target,
        .optimize = optimize,
    }).module("clap");

    const cli = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = "src/cli.zig" },
        .target = target,
        .optimize = optimize,
    });
    cli.root_module.addImport("clap", clap_module);

    addDocImports(b, cli);
    addBuildOptions(b, cli);

    return cli;
}

fn addWasmExecutable(b: *Build, name: []const u8) *Build.Step.Compile {
    const wasm = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = "src/wasm-lib.zig" },
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
        }),
        .optimize = .ReleaseSmall,
    });
    wasm.entry = .disabled;
    wasm.rdynamic = true;

    return wasm;
}

fn addDocImports(b: *Build, exe: *Build.Step.Compile) void {
    exe.root_module.addAnonymousImport("docs/cli", .{
        .root_source_file = .{ .path = "docs/cli.txt" },
    });

    const markdown_docs = [_][]const u8{ "advanced", "language", "overview", "stdlib" };
    for (markdown_docs) |filename| {
        const input_file = b.fmt("docs/{s}.md", .{filename});
        const output_name = b.fmt("docs/{s}", .{filename});

        // Convert from github flavored markdown to plain text
        const pandoc = b.addSystemCommand(&.{"pandoc"});
        pandoc.addArgs(&.{ "-f", "gfm", "-t", "plain" });
        pandoc.addFileArg(b.path(input_file));

        const output = pandoc.captureStdOut();

        exe.root_module.addAnonymousImport(output_name, .{
            .root_source_file = output,
        });
    }
}

fn addBuildOptions(b: *Build, exe: *Build.Step.Compile) void {
    const options = b.addOptions();
    exe.root_module.addOptions("build_options", options);
    options.addOption([]const u8, "version", versionString(b));
}

fn runStep(b: *Build, target: anytype, optimize: anytype) void {
    const run_step = b.step("run", "Run CLI app");

    const cli = addCliExecutable(b, "possum", target, optimize);

    b.installArtifact(cli);

    const run_cli = b.addRunArtifact(cli);
    run_cli.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cli.addArgs(args);

    run_step.dependOn(&run_cli.step);
}

fn checkStep(b: *Build, target: anytype, optimize: anytype) void {
    const check_step = b.step("check", "Check for compilation errors");
    const check_cli = addCliExecutable(b, "possum", target, optimize);
    check_step.dependOn(&check_cli.step);
}

fn testStep(b: *Build, target: anytype, optimize: anytype) void {
    const test_step = b.step("test", "Run unit tests");

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/tests.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    test_step.dependOn(&run_unit_tests.step);
}

fn releaseStep(b: *Build) void {
    const release_step = b.step("release", "Build release binaries");

    const wasm = addWasmExecutable(b, "possum");
    const wasm_output = b.addInstallArtifact(wasm, .{});
    release_step.dependOn(&wasm_output.step);

    const targets: []const Target.Query = &.{
        .{ .cpu_arch = .aarch64, .os_tag = .macos },
        .{ .cpu_arch = .x86_64, .os_tag = .macos },
        .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu },
        .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
    };

    for (targets) |query| {
        const target = b.resolveTargetQuery(query);
        const target_string = query.zigTriple(b.allocator) catch @panic("OOM");
        const name = b.fmt("possum_{s}", .{target_string});

        const cli = addCliExecutable(b, name, target, .ReleaseSafe);
        cli.root_module.strip = true;
        const target_output = b.addInstallArtifact(cli, .{});
        release_step.dependOn(&target_output.step);
    }
}
