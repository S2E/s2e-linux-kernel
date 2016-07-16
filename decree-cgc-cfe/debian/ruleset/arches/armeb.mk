######################### -*- Mode: Makefile-Gmake -*- ########################
## armeb.mk --- 
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##
## arch-tag: 163976e0-339d-4830-b3c2-14d7a842cccd
##
###############################################################################

### ARM (big endian)
ifeq ($(strip $(architecture)),armeb)

  kimage := vmlinuz
  target = zImage
  NEED_DIRECT_GZIP_IMAGE=NO
  kimagesrc = arch/$(KERNEL_ARCH)/boot/zImage
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(KERNELRELEASE)
  DEBCONFIG = $(CONFDIR)/config.arm
  kelfimagesrc = vmlinux
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(KERNELRELEASE)
  KERNEL_ARCH = arm

endif
