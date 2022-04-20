# Emscripten toolchain

[Emscripten](https://emscripten.org/) toolchain for macOS.

Included:
- Emscripten: `3.0.0`
- LLVM: `14.0.1`
- binaryen: `105`

Requried preinstall:
- [NodeJS](https://nodejs.org/)

## How to install

Checkout latest Emscripten:

```bash
./checkout-emscripten.sh 3.0.0
```

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

- [CMake](https://cmake.org/)
- [Ninja](https://ninja-build.org/)

```bash
./build.sh
```
