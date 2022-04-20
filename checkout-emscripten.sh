#!/usr/bin/env bash

set -eux

version=$1
if [ -z "${version}" ]; then
  echo "valid version is required, example: 3.0.0"
  exit -1
fi

if [ ! -d emscripten ]; then
  git clone https://github.com/emscripten-core/emscripten.git
fi

pushd emscripten
git clean -fdx
git reset --hard
git checkout main
git pull
git checkout tags/${version}
popd
