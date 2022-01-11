# Zig + Raylib
An experimental repository that cross-compile raylib with zig.

## Usage
```sh
zig build example
# for cross-compile from linux to x86_64-windows-gnu
zig build -Dtarget=x86_64-windows-gnu
```
*Note*: `build_c.zig` is used for compiling `core_input_mouse.c`, which is from `raylib/examples/core`

## Why raylib?
1. Multi-platform game library \
I can compile it to various platforms, not only Windows or Linux.
2. NO external dependency \
It is bundled with all required libraries.
3. Easy-to-use\
It's simple to demonstrate. 
## Why Zig?
1. General-purpose simple programming language\
It is easier than it looks. [You can read the one-page document.](https://ziglang.org/documentation/master/)
2. Powerful cross compiler\
Check [this article](https://andrewkelley.me/post/zig-cc-powerful-drop-in-replacement-gcc-clang.html). It includes `libc`, so it can easily compile `raylib`.
3. C interoperability\
Like other languages, `Zig` can interoperate with C by design.\
However, there are some issues yet. [Like this.](https://github.com/ziglang/zig/issues/10560)
4. Easy-to-use build system\
`Zig`'s build system is very powerful. You can build even C/C++ project with `Zig`. No special grammar is required.\
However, the build system is not fully operational yet and not documented well. Here are some useful articles. [zig.news](https://zig.news/xq/zig-build-explained-part-1-59lf) [ziglearn.org](https://ziglearn.org/chapter-3/) 
## Credits
[raylib](https://github.com/raysan5/raylib): Copyright (c) 2013-2022 Ramon Santamaria (@raysan5)

[Zig](https://github.com/ziglang/zig): Copyright (c) 2015-2022, Zig contributors