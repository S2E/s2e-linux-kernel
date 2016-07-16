######################### -*- Mode: Makefile-Gmake -*- ########################
## mips.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 18:31:07 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 14:19:06 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 1
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : handle the architecture specific variables.
## 
## arch-tag: 5af7feee-c1b9-497b-8985-2d6d15abefa9
## 
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
###############################################################################

# SGI ELF32: 64bit kernel, but firmware needs ELF32 for netboot
# (the on-disk loader could do both).
ifneq (,$(filter r4k-ip22 r5k-ip22 r5k-ip32 r10k-ip32,$(strip $(KPKG_SUBARCH))))
ifneq ($(shell if [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 6 ] &&    \
                  [ $(SUBLEVEL) -ge 11 ]; then echo new;                   \
             elif [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 7 ]; then \
                                          echo new;                        \
             elif [ $(VERSION)  -ge  3 ]; then echo new; fi),)
  kimage := vmlinux.32
else
  kimage := vmlinux
endif
endif
# SGI ELF64
ifneq (,$(filter r10k-ip27 r10k-ip28 r10k-ip30,$(strip $(KPKG_SUBARCH))))
# pre 2.6.11 the image name was vmlinux.64
ifneq ($(shell if [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 6 ] &&    \
                  [ $(SUBLEVEL) -ge 11 ]; then echo new;                   \
             elif [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 7 ]; then \
                                          echo new;                        \
             elif [ $(VERSION)  -ge  3 ]; then echo new; fi),)
  kimage := vmlinux
else
  kimage := vmlinux.64
endif
endif

# Default value
ifeq (,$(kimage))
  kimage := vmlinux
endif
ifeq (,$(kimagesrc))
  kimagesrc := $(kimage)
endif

NEED_DIRECT_GZIP_IMAGE = NO
kimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(KERNELRELEASE)

ifneq ($(shell if [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 5 ] &&    \
                  [ $(SUBLEVEL) -ge 41 ]; then echo new;                   \
             elif [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 6 ]; then \
                                          echo new;                        \
             elif [ $(VERSION)  -ge  3 ]; then echo new; fi),)
  target =
else
  target = boot
endif

ifneq (,$(filter mips64%,$(KPKG_SUBARCH)))
  KERNEL_ARCH = mips64
endif
ifneq (,$(filter %-64,$(KPKG_SUBARCH)))
  KERNEL_ARCH = mips64
endif

#Local variables:
#mode: makefile
#End:
