const std = @import("std");
const Builder = std.build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    {
        var raylib = b.addStaticLibrary("raylib", null);
        raylib.setTarget(target);
        raylib.setBuildMode(mode);
        raylib.linkLibC();
        if (target.getOsTag() == .linux) {
            raylib.linkSystemLibrary("X11");
        }
        // } else if (target.getOsTag() == .macos) {
        //     raylib.linkFramework("Foundation");
        //     raylib.linkFramework("Cocoa");
        //     raylib.linkFramework("OpenGL");
        //     raylib.linkFramework("CoreAudio");
        //     raylib.linkFramework("CoreVideo");
        //     raylib.linkFramework("IOKit");
        // }

        const raylibFlags = &[_][]const u8{ "-std=c99", "-DPLATFORM=DESKTOP", "-DPLATFORM_DESKTOP", "-DGRAPHICS=GRAPHICS_API_OPENGL_33", "-D_DEFAULT_SOURCE", "-Iraylib/src", "-Iraylib/src/external/glfw/include", "-Iraylib/src/external/glfw/deps" };
        raylib.addCSourceFiles(&.{ "raylib/src/raudio.c", "raylib/src/rcore.c", "raylib/src/rmodels.c", "raylib/src/rglfw.c", "raylib/src/rshapes.c", "raylib/src/rtext.c", "raylib/src/rtextures.c", "raylib/src/utils.c" }, raylibFlags);

        var exe = b.addExecutable("main", "example/main.zig");
        exe.setTarget(target);
        exe.linkLibrary(raylib);
        exe.addIncludeDir("raylib/src");
        exe.setBuildMode(mode);
        switch (exe.target.toTarget().os.tag) {
            .windows => {
                exe.linkSystemLibrary("winmm");
                exe.linkSystemLibrary("gdi32");
                exe.linkSystemLibrary("opengl32");
                exe.addIncludeDir("external/glfw/deps/mingw");
            },
            .linux => {
                exe.linkSystemLibrary("GL");
                exe.linkSystemLibrary("rt");
                exe.linkSystemLibrary("dl");
                exe.linkSystemLibrary("m");
                exe.linkSystemLibrary("X11");
            },
            .macos => {
                exe.linkFramework("Foundation");
                exe.linkFramework("Cocoa");
                exe.linkFramework("OpenGL");
                exe.linkFramework("CoreAudio");
                exe.linkFramework("CoreVideo");
                exe.linkFramework("IOKit");
            },
            else => {
                @panic("Unsupported OS");
            },
        }
        exe.install();
        b.default_step.dependOn(&exe.step);

        b.installArtifact(exe);

        const play = b.step("example", "Play example");
        const run = exe.run();
        play.dependOn(&run.step);
    }
}
