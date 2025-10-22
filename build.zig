const std = @import("std");
const rlz = @import("raylib_zig");

var target: ?std.Build.ResolvedTarget = null;
var optimize: ?std.builtin.OptimizeMode = null;

pub fn build(b: *std.Build) void {
  target = b.standardTargetOptions(.{});
  optimize = b.standardOptimizeOption(.{});

  const mod = b.addModule("vox", .{
    .root_source_file = b.path("src/root.zig"),
    .target = target.?,
    .optimize = optimize.?,
  });

  const exe = b.addExecutable(.{
    .name = "vox",
    .root_module = b.createModule(.{
      .root_source_file = b.path("src/main.zig"),
      .target = target.?,
      .optimize = optimize.?,
      .imports = &.{
        .{ .name = "vox", .module = mod },
      },
    }),
  });

  addRaylib(b, exe);

  _ = setupRunStep(b, exe);
  _ = setupTestStep(b, exe, mod);
}

fn addRaylib(b: *std.Build, exe: *std.Build.Step.Compile) void {
  const raylib_dep = b.dependency("raylib_zig", .{
    .target = target,
    .optimize = optimize,
    .opengl_version = rlz.OpenglVersion.gl_2_1,
  });

  const raylib = raylib_dep.module("raylib"); // main raylib module
  const raygui = raylib_dep.module("raygui"); // raygui module
  const raylib_artifact = raylib_dep.artifact("raylib"); // raylib C library
  // raylib_artifact.root_module.addCMacro("SUPPORT_FILEFORMAT_JPG", "");

  exe.linkLibrary(raylib_artifact);
  exe.root_module.addImport("raylib", raylib);
  exe.root_module.addImport("raygui", raygui);
}

fn setupRunStep(b: *std.Build, exe: *std.Build.Step.Compile) void {
  const step = b.step("run", "Run the app");
  const cmd = b.addRunArtifact(exe);

  step.dependOn(&cmd.step);
  cmd.step.dependOn(b.getInstallStep());

  if (b.args) |args| cmd.addArgs(args);
}

fn setupTestStep(b: *std.Build, exe: *std.Build.Step.Compile, mod: *std.Build.Module) *std.Build.Step {
  const mod_tests = b.addTest(.{
    .root_module = mod,
  });

  const run_mod_tests = b.addRunArtifact(mod_tests);

  const exe_tests = b.addTest(.{
    .root_module = exe.root_module,
  });

  const run_exe_tests = b.addRunArtifact(exe_tests);
  const step = b.step("test", "Run tests");
  step.dependOn(&run_mod_tests.step);
  step.dependOn(&run_exe_tests.step);

  return step;
}
