# Zig + Raylib
Experimental repository that cross-compile raylib with zig.

## Usage
```sh
zig build example
# for cross-compile from linux to x86_64-windows-gnu
zig build -Dtarget=x86_64-windows-gnu
```

*Note*: `build_c.zig` is used for compiling `core_input_mouse.c`, which is from `raylib/examples/core`
## Credits
[Raylib](https://github.com/raysan5/raylib): Copyright (c) 2013-2022 Ramon Santamaria (@raysan5)