#!/bin/bash

# S2E Selective Symbolic Execution Platform
#
# Copyright (c) 2017, Dependable Systems Laboratory, EPFL
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# Build and install the S2E Linux kernel

set -ex

S2E_INC=/tmp/include
KERNEL_SRC=/tmp/${S2E_KERNEL_DIR}

# Ensure that we are in the correct directory
cd /tmp

# Build the kernel
export C_INCLUDE_PATH=${S2E_INC}:${C_INCLUDE_PATH}

if [ ! -e ${KERNEL_SRC}/.config ]; then
    echo "No .config - generating the default config"
    make -C ${KERNEL_SRC} defconfig
else
    echo "Using existing .config"
fi

make -C ${KERNEL_SRC} -j4 deb-pkg LOCALVERSION=-s2e

# Install the kernel
dpkg -i *.deb
