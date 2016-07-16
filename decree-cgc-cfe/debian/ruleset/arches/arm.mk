######################### -*- Mode: Makefile-Gmake -*- ########################
## arm.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Fri Dec  9 14:58:51 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 14:19:23 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 4
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
## 
## arch-tag: ac6e7f1e-b138-49a9-b007-abec5154ccf2
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

### ARM
ifeq ($(strip $(architecture)),arm)
  GUESS_SUBARCH:='netwinder'

  ifneq (,$(findstring $(KPKG_SUBARCH),netwinder))
    KPKG_SUBARCH:=$(GUESS_SUBARCH)
    kimage := vmlinuz
    target = Image
    kimagesrc = arch/$(KERNEL_ARCH)/boot/Image
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(KERNELRELEASE)
    NEED_DIRECT_GZIP_IMAGE=NO
    DEBCONFIG= $(CONFDIR)/config.netwinder
  else
    kimage := vmlinuz
    target = zImage
    NEED_DIRECT_GZIP_IMAGE=NO
    kimagesrc = arch/$(KERNEL_ARCH)/boot/zImage
    kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(KERNELRELEASE)
    DEBCONFIG = $(CONFDIR)/config.$(DEB_HOST_ARCH)
  endif
  kelfimagesrc = vmlinux
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(KERNELRELEASE)
endif

#Local variables:
#mode: makefile
#End:
