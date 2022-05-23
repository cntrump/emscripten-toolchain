#!/usr/bin/env bash

set -eux

prefix=$1
[ -z ${prefix} ] && prefix=/opt/local

toolchain=emsdk

version_emscripten=3.1.11
version_binaryen=105
version_llvm=14.0.3
version_nodejs=16.14.2

./checkout-emscripten.sh ${version_emscripten}

prebuilt_binaryen=binaryen-${version_binaryen}-universal-apple-darwin.tar.xz
prebuilt_llvm=llvm-${version_llvm}-universal-apple-darwin.tar.xz

function download_if_needed() {
  local file=$1
    if [ ! -f ${file} ]; then
      curl -OL https://github.com/cntrump/emscripten-toolchain/releases/download/prebuilt/${file}
    fi
}

download_if_needed ${prebuilt_binaryen}
download_if_needed ${prebuilt_llvm}

if [ ! -d ${prefix}/${toolchain} ]; then
  sudo mkdir -p ${prefix}/${toolchain}
fi

function install_nodejs() {
  if [ ! -f "node-v${version_nodejs}.pkg" ]; then
    curl -OL https://nodejs.org/dist/v${version_nodejs}/node-v${version_nodejs}.pkg
  fi

  [ -d ${prefix}/${toolchain}/nodejs ] && sudo rm -rf ${prefix}/${toolchain}/nodejs
  sudo mkdir -p ${prefix}/${toolchain}/nodejs

  [ -d node-v${version_nodejs} ] && sudo rm -rf node-v${version_nodejs}
  pkgutil --expand-full node-v${version_nodejs}.pkg node-v${version_nodejs}
  pushd node-v${version_nodejs}
  sudo cp -a ./node-v16.14.2.pkg/Payload/usr/local/* ${prefix}/${toolchain}/nodejs
  # install npm
  sudo cp -a ./npm-v8.5.0.pkg/Payload/usr/local/* ${prefix}/${toolchain}/nodejs
  pushd ${prefix}/${toolchain}/nodejs/bin
  sudo ln -sf ../lib/node_modules/npm/bin/npm-cli.js npm
  sudo ln -sf ../lib/node_modules/npm/bin/npx-cli.js npx
  # enable corepack
  local temp_path=$PATH
  PATH=${prefix}/${toolchain}/nodejs/bin:${PATH}
  sudo ./corepack enable
  PATH=${temp_path}
  popd
  popd
}

install_nodejs

[ -d ${prefix}/${toolchain}/llvm ] && sudo rm -rf ${prefix}/${toolchain}/llvm
sudo mkdir -p ${prefix}/${toolchain}/llvm
sudo tar -xvf ${prebuilt_llvm} -C ${prefix}/${toolchain}/llvm

[ -d ${prefix}/${toolchain}/binaryen ] && sudo rm -rf ${prefix}/${toolchain}/binaryen
sudo mkdir -p ${prefix}/${toolchain}/binaryen
sudo tar -xvf ${prebuilt_binaryen} -C ${prefix}/${toolchain}/binaryen

[ -d ${prefix}/${toolchain}/emscripten ] && sudo rm -rf ${prefix}/${toolchain}/emscripten
sudo cp -a emscripten ${prefix}/${toolchain}/

sudo sed -i'.bak' 's/EXPECTED_LLVM_VERSION = "15.0"/EXPECTED_LLVM_VERSION = "14.0"/g' ${prefix}/${toolchain}/emscripten/tools/shared.py

# generate emscripten_configuration
EMSCRIPTEN_ROOT="${prefix}/${toolchain}/emscripten"
LLVM_ROOT="${prefix}/${toolchain}/llvm/bin"
BINARYEN_ROOT="${prefix}/${toolchain}/binaryen"
NODE_JS="${prefix}/${toolchain}/nodejs/bin/node"

cat <<EOF > ~/.emscripten
# Note: If you put paths relative to the home directory, do not forget
# os.path.expanduser
#
# Any config setting <KEY> in this file can be overridden by setting the
# EM_<KEY> environment variable. For example, settings EM_LLVM_ROOT override
# the setting in this file.
#
# Note: On Windows, remember to escape backslashes! I.e. LLVM='c:\llvm\'
# is not valid, but LLVM='c:\\llvm\\' and LLVM='c:/llvm/'
# are.

# This is used by external projects in order to find emscripten.  It is not used
# by emscripten itself.
EMSCRIPTEN_ROOT = '${EMSCRIPTEN_ROOT}' # directory

LLVM_ROOT = '${LLVM_ROOT}' # directory
BINARYEN_ROOT = '${BINARYEN_ROOT}' # directory

# Location of the node binary to use for running the JS parts of the compiler.
# This engine must exist, or nothing can be compiled.
NODE_JS = '${NODE_JS}' # executable

JAVA = 'java' # executable

################################################################################
#
# Test suite options:
#
# Alternative JS engines to use during testing:
#
# SPIDERMONKEY_ENGINE = ['js'] # executable
# V8_ENGINE = 'd8' # executable
#
# All JS engines to use when running the automatic tests. Not all the engines in
# this list must exist (if they don't, they will be skipped in the test runner).
#
# JS_ENGINES = [NODE_JS] # add V8_ENGINE or SPIDERMONKEY_ENGINE if you have them installed too.
#
# import os
# WASMER = os.path.expanduser(os.path.join('~', '.wasmer', 'bin', 'wasmer'))
# WASMTIME = os.path.expanduser(os.path.join('~', 'wasmtime'))
#
# Wasm engines to use in STANDALONE_WASM tests.
#
# WASM_ENGINES = [] # add WASMER or WASMTIME if you have them installed
#
################################################################################
#
# Other options
#
# FROZEN_CACHE = True # never clears the cache, and disallows building to the cache
EOF

pushd ${EMSCRIPTEN_ROOT}
PATH=$(dirname ${NODE_JS}):${PATH}
sudo yarn add acorn html-minifier-terser
popd

set +ux

cat <<EOF

====== Install finised ======
  Created: ~/.emscripten
  EMSCRIPTEN_ROOT="${EMSCRIPTEN_ROOT}"
  LLVM_ROOT="${LLVM_ROOT}"
  BINARYEN_ROOT="${BINARYEN_ROOT}"
  NODE_JS="${NODE_JS}"
=============================

You need add ${EMSCRIPTEN_ROOT} to PATH manually.
EOF
