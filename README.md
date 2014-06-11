# S2E Linux Source

This repo contains modified versions of the Linux kernel that are suitable for
use with the [S2E](http://s2e.systems) software analysis platform. Different
kernels with various modifications are available.

## Prerequisites

Building a QEMU image suitable for S2E requires the [Packer](https://packer.io)
tool.

## Building an image

To build a QEMU image using an existing kernel from this repo, simply run
`packer build -var 's2e_install=/path/to/s2e/install/dir' $KERNEL.json`, where
`$KERNEL` is one of the kernels availale in this repository.

Some options are configurable, for example setting the username and password.
Run `packer inspect $KERNEL.json` to view configurable options.

## Building the kernel

If you just want to build the kernel without building a complete S2E image
(e.g. if you want to experiment with kernel changes without rebuilding a new
image each time), then you can do the following:

```
sudo apt-get build-dep fakeroot linux-image$(uname -r)

cd $KERNEL_DIR
make defconfig

# This will generate a default config that you can make changes to as
# necessary. For example, you may want to enable the S2E debug option.

# Build the kernel in a fakeroot environment
C_INCLUDE_PATH=../include:$C_INCLUDE_PATH fakeroot -- make deb-pkg LOCALVERSION=-s2e

cd ..
```

You can then transfer the generated deb files to your image and install with
`dpkg -i`.

## Extending

We recommend that you follow these steps for modifying your own kernel for use
with S2E:

1. Add the kernel source code directory at the root of this repo

2. Copy `include/s2e/*/*_monitor.h` from an existing kernel

3. Add/remove/modify any commands (and their invoke functions) that you require
   in `include/s2e/*/*_monitor.h`

4. Modify the relevant kernel code to call the invoke function and issue the
   command to S2E

5. Write an S2E plugin that includes the same `*_monitor.h` file. The
   plugin class should extend the `BaseLinuxMonitor` class and implement the
   virtual `handleCommand` method to handle a command sent from the modified
   kernel

6. Write a `$KERNEL.json` file to build and install your kernel into a QEMU
   image. To use your image template with
   [s2e-env](https://github.com/dslab-epfl/s2e-env.git) you must specify the
   `manifest` post-processor
