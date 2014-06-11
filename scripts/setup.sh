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


# Install required packages

set -ex

APT_PACKAGES="
gdb
libc6-dbg
python
strace
vim
"

APT_BUILD_DEPS="
linux-image-$(uname -r)
"

# Install required packages
apt-get -y update
apt-get -y install ${APT_PACKAGES}
apt-get -y build-dep ${APT_BUILD_DEPS}

# Enable access to the serial port
usermod -aG dialout ${S2E_USER}

# Enable password-less sudo
echo "${S2E_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Mount /tmp as ramdisk
echo "none /tmp tmpfs defaults 0 0" >> /etc/fstab

# Reduce network timeout on boot when no network is available - should reduce
# boot times
echo -e "\n[Serivce]\nTimeoutStartSec=15" >> /lib/systemd/system/networking.service.d/network-pre.conf

# Enable systemd auto-login
if [ -f /lib/systemd/system/getty@.service ]; then
    sed -i "s/^ExecStart=\(.* --noclear\)/ExecStart=\1 --autologin ${S2E_USER}/g" /lib/systemd/system/getty@.service
fi

# Automatically start the S2E launch script at login
echo "SNAPSHOT_NAME=${S2E_SNAPSHOT_NAME} /bin/bash \${HOME}/launch.sh" > /home/${S2E_USER}/.bash_profile
