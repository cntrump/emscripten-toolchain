#!/usr/bin/env bash

set -eux

version=$1

if [ -z "${version}" ]; then
  echo "valid version is required, example: 105"
  exit -1
fi

if [ ! -d binaryen ]; then
  git clone --recursive https://github.com/WebAssembly/binaryen.git binaryen
fi

pushd binaryen
git clean -fdx
git reset --hard
git checkout main
git pull
git checkout tags/version_${version}
popd
