######################### -*- Mode: Makefile-Gmake -*- ########################
## mipsel.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 18:31:07 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 14:19:28 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 1
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : handle the architecture specific variables.
## 
## arch-tag: f915bec1-7531-49cb-8f58-edae7faaeb47
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

# xxs1500
ifneq (,$(filter xxs1500,$(strip $(KPKG_SUBARCH))))
  kimage := vmlinux
  kimagesrc = $(strip arch/$(KERNEL_ARCH)/boot/$(kimage).srec)
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

KERNEL_ARCH = mips
ifneq (,$(filter mips64el%,$(KPKG_SUBARCH)))
  KERNEL_ARCH = mips64
endif
ifneq (,$(filter %-64,$(KPKG_SUBARCH)))
  KERNEL_ARCH = mips64
endif

#Local variables:
#mode: makefile
#End:
