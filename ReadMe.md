# Emscripten Toolchain

[Emscripten](https://emscripten.org/) toolchain for macOS.

Included:
- Emscripten: `3.0.0`
- LLVM: `14.0.1`
- binaryen: `102`
- NodeJS: `16.14.2`

## How to install toolchain

Install toolchain:

```bash
./install.sh /opt/local
```

After installed, add `emscripten` to `$PATH`:

```bash
export PATH=/opt/local/emsdk/emscripten:$PATH
```

## How to build toolchain

Requried preinstall:

- Xcode or [Command Line Tools For Xcode](https://developer.apple.com/download/all/)
- [CMake](https://cmake.org/)
- [Ninja](https://ninja-build.org/)

```bash
./build.sh
```

## How to use toolchain

main.c

```c
#include <stdio.h>

int main() {
    printf("Hello World!");
    return 0;
}
```

Build `main.c`:

```bash
emcc main.c \
     -s EXIT_RUNTIME=1 \
     -o index.html
```

Test:

```bash
python3 -m http.server
```

Visit http://127.0.0.1:8000/ , You will see `Hello World!` printed.

### Build release version

Build `main.c` with `-Os` option:

```bash
emcc -Os main.c -s EXIT_RUNTIME=1 -o index.html
```

### Clear cache

```bash
emcc --clear-cache
```
