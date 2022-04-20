#!/usr/bin/env bash

set -eux

prefix=$1
[ -z ${prefix} ] && prefix=/opt/local

toolchain=emsdk

version_binaryen=105
version_llvm=14.0.1

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

[ -d ${prefix}/${toolchain}/llvm ] && sudo rm -rf ${prefix}/${toolchain}/llvm
sudo mkdir -p ${prefix}/${toolchain}/llvm
sudo tar -xvf ${prebuilt_llvm} -C ${prefix}/${toolchain}/llvm

[ -d ${prefix}/${toolchain}/binaryen ] && sudo rm -rf ${prefix}/${toolchain}/binaryen
sudo mkdir -p ${prefix}/${toolchain}/binaryen
sudo tar -xvf ${prebuilt_binaryen} -C ${prefix}/${toolchain}/binaryen

[ -d ${prefix}/${toolchain}/emscripten ] && sudo rm -rf ${prefix}/${toolchain}/emscripten
sudo cp -r emscripten ${prefix}/${toolchain}/

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
EMSCRIPTEN_ROOT = '${prefix}/${toolchain}/emscripten' # directory

LLVM_ROOT = '${prefix}/${toolchain}/llvm/bin' # directory
BINARYEN_ROOT = '${prefix}/${toolchain}/binaryen' # directory

# Location of the node binary to use for running the JS parts of the compiler.
# This engine must exist, or nothing can be compiled.
NODE_JS = '$(which node)' # executable

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
