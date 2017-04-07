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

# Sets up a DECREE VM

set -ex

APT_PACKAGES="
python-crypto
python-daemon
python-lockfile
python-lxml
python-matplotlib
python-yaml
tcpdump
"

CGC_PACKAGES="
binutils-cgc-i386_2.24-10551-cfe-rc8_i386.deb
cgc2elf_10551-cfe-rc8_i386.deb
libcgcef0_10551-cfe-rc8_i386.deb
libcgcdwarf_10551-cfe-rc8_i386.deb
readcgcef_10551-cfe-rc8_i386.deb
python-defusedxml_10551-cfe-rc8_all.deb
libcgc_10551-cfe-rc8_i386.deb
cgc-network-appliance_10551-cfe-rc8_all.deb
cgc-service-launcher_10551-cfe-rc8_i386.deb
poll-generator_10551-cfe-rc8_all.deb
cb-testing_10551-cfe-rc8_all.deb
cgc-release-documentation_10560-cfe-rc8_all.deb
cgcef-verify_10551-cfe-rc8_all.deb
cgc-pov-xml2c_10551-cfe-rc8_i386.deb
strace-cgc_4.5.20-10551-cfe-rc8_i386.deb
libpov_10551-cfe-rc8_i386.deb
clang-cgc_3.4-10551-cfe-rc8_i386.deb
cgc-virtual-competition_10551-cfe-rc8_all.deb
magic-cgc_10551-cfe-rc8_all.deb
services-cgc_10551-cfe-rc8_all.deb
linux-image-3.13.11-ckt32-cgc_10551-cfe-rc8_i386.deb
linux-libc-dev_10551-cfe-rc8_i386.deb
"

# Ensure that we are in the correct directory
cd /tmp

# Install the prerequisites
apt-get -y install ${APT_PACKAGES}

# Install the CGC packages
for PACKAGE in ${CGC_PACKAGES}; do
    wget https://cgcdist.s3.amazonaws.com/release-final/deb/${PACKAGE}
    dpkg -i --force-confnew ${PACKAGE}
    rm -f ${PACKAGE}
done
