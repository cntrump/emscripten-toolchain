#!/usr/bin/env bash

set -eux

ver=$1

# to avoid OOMs or going into swap, permit only one link job per 15GB of RAM available on a 32GB machine, 
# specify -G Ninja -DLLVM_PARALLEL_LINK_JOBS=2.
CPU_NUM=`sysctl -n hw.physicalcpu`
[ "${CPU_NUM}" = "" ] && CPU_NUM=2
CPU_NUM=$((CPU_NUM/2))

pushd binaryen
[ -d build ] && rm -rf build
cmake -S . -B build -G Ninja \
      -DLLVM_PARALLEL_COMPILE_JOBS=${CPU_NUM} \
      -DLLVM_PARALLEL_LINK_JOBS=1 \
      -DCMAKE_INSTALL_PREFIX="$(pwd)/../binaryen-${ver}" \
      -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13 \
      -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_ASM_COMPILER=$(which clang) \
      -DCMAKE_C_COMPILER=$(which clang) \
      -DCMAKE_CXX_COMPILER=$(which clang++) \
      -DBUILD_TESTS=OFF

ninja -C build install
popd

pushd binaryen-${ver}
tar --uid 0 --gid 0 -cJvf ../binaryen-${ver}-universal-apple-darwin.tar.xz $(ls)
popd