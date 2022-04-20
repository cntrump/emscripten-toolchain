# Emscripten toolchain

Emscripten toolchain for macOS.

Included:
- Emscripten: `3.0.0`
- LLVM: `14.0.1`
- binaryen: `105`

Requried preinstall:
- [NodeJS](https://nodejs.org/)

## How to install

```bash
./install.sh /opt/local
```

After installed, add `emscripten` to `$PATH`:

```bash
export PATH=/opt/local/emsdk/emscripten:$PATH
```

## How to build

```bash
./build.sh
```
