# Emscripten toolchain

[Emscripten](https://emscripten.org/) toolchain for macOS.

Included:
- Emscripten: `3.0.0`
- LLVM: `14.0.1`
- binaryen: `105`
- NodeJS: `16.14.2`

## How to install

Install toolchain:

```bash
./install.sh /opt/local
```

After installed, add `emscripten` to `$PATH`:

```bash
export PATH=/opt/local/emsdk/emscripten:$PATH
```

## How to build

Requried preinstall:

- Xcode or [Command Line Tools For Xcode](https://developer.apple.com/download/all/)
- [CMake](https://cmake.org/)
- [Ninja](https://ninja-build.org/)

```bash
./build.sh
```
