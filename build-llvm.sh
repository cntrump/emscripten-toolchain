#!/usr/bin/env bash

set -eux

ver=$1

# to avoid OOMs or going into swap, permit only one link job per 15GB of RAM available on a 32GB machine, 
# specify -G Ninja -DLLVM_PARALLEL_LINK_JOBS=2.
CPU_NUM=`sysctl -n hw.physicalcpu`
[ "${CPU_NUM}" = "" ] && CPU_NUM=2
CPU_NUM=$((CPU_NUM/2))

pushd llvm-project
[ -d build ] && rm -rf build
cmake -S llvm -B build -G Ninja \
      -DLLVM_PARALLEL_COMPILE_JOBS=${CPU_NUM} \
      -DLLVM_PARALLEL_LINK_JOBS=1 \
      -DCMAKE_INSTALL_PREFIX="$(pwd)/../llvm-${ver}" \
      -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13 \
      -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_ASM_COMPILER=$(which clang) \
      -DCMAKE_C_COMPILER=$(which clang) \
      -DCMAKE_CXX_COMPILER=$(which clang++) \
      -DLLVM_ENABLE_PROJECTS='lld;clang' \
      -DLLVM_TARGETS_TO_BUILD="host;WebAssembly" \
      -DLLVM_INCLUDE_EXAMPLES=OFF \
      -DLLVM_INCLUDE_TESTS=OFF

ninja -C build install
popd

pushd llvm-${ver}
tar --uid 0 --gid 0 -cJvf ../llvm-${ver}-universal-apple-darwin.tar.xz $(ls)
popd
