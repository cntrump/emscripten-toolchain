#!/usr/bin/env bash

set -eux

version_emscripten=3.1.15
version_binaryen=105
version_llvm=14.0.6

./checkout-binaryen.sh ${version_binaryen}
./checkout-llvm.sh ${version_llvm}

./build-binaryen.sh ${version_binaryen}
./build-llvm.sh ${version_llvm}

./checkout-emscripten.sh ${version_emscripten}
