const std = @import("std");
const Build = std.Build;
const SemanticVersion = std.SemanticVersion;

const version: SemanticVersion = .{ .major = 0, .minor = 4, .patch = 0 };

pub fn build(b: *Build) void {
    const version_string = b.fmt("{d}.{d}.{d}", .{ version.major, version.minor, version.patch });

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const library_opts = .{ .target = target, .optimize = optimize };

    const wasm_target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });

    // Dependencies

    const clap_module = b.dependency("clap", library_opts).module("clap");

    // CLI

    const cli = b.addExecutable(.{
        .name = "possum",
        .root_source_file = .{ .path = "src/cli.zig" },
        .target = target,
        .optimize = optimize,
    });
    cli.root_module.addImport("clap", clap_module);

    cli.root_module.addAnonymousImport("docs/cli", .{
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

        cli.root_module.addAnonymousImport(output_name, .{
            .root_source_file = output,
        });
    }

    const cli_options = b.addOptions();
    cli.root_module.addOptions("build_options", cli_options);
    cli_options.addOption([]const u8, "version", version_string);

    const run_cli = b.addRunArtifact(cli);
    run_cli.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cli.addArgs(args);

    const run_step = b.step("run", "Run the possum cli app");
    run_step.dependOn(&run_cli.step);

    b.installArtifact(cli);

    // WASM

    const wasm_lib = b.addExecutable(.{
        .name = "possum",
        .root_source_file = .{ .path = "src/wasm-lib.zig" },
        .target = wasm_target,
        .optimize = .ReleaseSmall,
    });
    wasm_lib.entry = .disabled;
    wasm_lib.rdynamic = true;
    wasm_lib.root_module.addImport("clap", clap_module);

    b.installArtifact(wasm_lib);

    // Tests

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/tests.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
