const std = @import("std");
const rlz = @import("raylib_zig");

pub fn build(b: *std.Build) void {
    const exe_name = "Tetotari";

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create module for entry point
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add raylib dependency
    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
        .shared = true,
        .rmodels = false,
        .platform = rlz.PlatformBackend.glfw,
        // Wayland backend does a weird thing where it's offset by about 20 pixels
        // down on launch
        .linux_display_backend = rlz.LinuxDisplayBackend.X11,
    });

    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");
    raylib_artifact.root_module.addCMacro("SUPPORT_CUSTOM_FRAME_CONTROL", "1");

    // Add raylib to root module
    exe_mod.addImport("raylib", raylib);

    const exe = b.addExecutable(.{
        .name = exe_name,
        .root_module = exe_mod,
    });

    // Link raylib C lib to exe
    exe.linkLibrary(raylib_artifact);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // Copy the resources directory to the build output
    b.installDirectory(.{
        .source_dir = b.path("resources/"),
        .install_dir = .{ .prefix = {} },
        .install_subdir = "bin/resources",
    });

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // This creates another `std.Build.Step.Compile` for ZLS build on save diagnostics
    const exe_check = b.addExecutable(.{
        .name = exe_name,
        .root_module = exe_mod,
    });

    // Link raylib C lib to check exe
    exe_check.linkLibrary(raylib_artifact);

    const check = b.step("check", "Check if executable compiles");
    check.dependOn(&exe_check.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
