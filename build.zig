const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Build ReleaseSmall binaries for two targets: macOS (arm64) and Linux (x86_64).
    const optimize = std.builtin.OptimizeMode.ReleaseSmall;

    const targets = [_]std.Target.Query{
        .{ .cpu_arch = .aarch64, .os_tag = .macos }, // macOS ARM
        .{ .cpu_arch = .x86_64, .os_tag = .linux }, // Linux x86_64
    };

    const root_src = b.path("src/main.zig");

    for (targets) |tgt| {
        const resolved = b.resolveTargetQuery(tgt);
        const exe = b.addExecutable(.{
            .name = blk: {
                const triple = tgt.zigTriple(b.allocator) catch unreachable;
                break :blk b.fmt("doppler-json-template-{s}", .{triple});
            },
            .root_source_file = root_src,
            .target = resolved,
            .optimize = optimize,
        });
        b.installArtifact(exe);
    }

    // After this, `zig build install` will drop both binaries into `zig-out/bin/`.

    // -----------------------------
    // Unit-test step (restored)
    // -----------------------------
    const unit_tests = b.addTest(.{
        .root_source_file = root_src,
        .target = b.graph.host, // run tests for the host platform
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
