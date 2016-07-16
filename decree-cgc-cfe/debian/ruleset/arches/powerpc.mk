######################### -*- Mode: Makefile-Gmake -*- ########################
## ppc.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 18:31:06 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 14:18:18 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 11
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : handle the architecture specific variables.
## 
## arch-tag: d59ba6c1-4d5e-46c2-aa8f-8c6e1d4a487b
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

$(eval $(which_debdir))
include $(DEBDIR)/ruleset/arches/what_is_ppc_called_today.mk

kimagesrc = vmlinux
kimage := vmlinux
kimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(KERNELRELEASE)
target := vmlinux
DEBCONFIG= $(CONFDIR)/config.$(KPKG_SUBARCH)

# 32bit generic powerpc subarches.
ifneq (,$(findstring $(KPKG_SUBARCH), prep powerpc powerpc32 ppc ppc32 ppc64 powerpc64))
  KPKG_SUBARCH:=powerpc
  NEED_IMAGE_POST_PROCESSING = YES
  IMAGE_POST_PROCESS_TARGET := mkvmlinuz_support_install
  IMAGE_POST_PROCESS_DIR    := arch/$(KERNEL_ARCH)/boot
  # INSTALL_MKVMLINUZ_PATH = /usr/lib/kernel-image-${version}
  INSTALL_MKVMLINUZ_PATH = /usr/lib/$(INT_STEM)-image-${version}
  define DO_IMAGE_POST_PROCESSING
	if grep $(IMAGE_POST_PROCESS_TARGET) $(IMAGE_POST_PROCESS_DIR)/Makefile 2>&1 \
                >/dev/null; then                                                     \
          if [ "$(KERNEL_ARCH_VERSION)" = "post-2.6.15" ] &&			     \
	     [ "$(KPKG_SUBARCH)" != "prep" ] ; then                                  \
            $(MAKE) INSTALL_MKVMLINUZ=$(TMPTOP)$(INSTALL_MKVMLINUZ_PATH)             \
               ARCH=$(KERNEL_ARCH) $(EXTRAV_ARG) $(CROSS_ARG)                        \
	       $(IMAGE_POST_PROCESS_TARGET);                                         \
          else                                                                       \
            $(MAKE) INSTALL_MKVMLINUZ=$(TMPTOP)$(INSTALL_MKVMLINUZ_PATH)             \
              ARCH=$(KERNEL_ARCH) -C $(IMAGE_POST_PROCESS_DIR)                       \
                $(IMAGE_POST_PROCESS_TARGET);                                        \
          fi;                                                                        \
        fi
  endef
  target := zImage
endif

# 64bit generic powerpc subarches.
ifneq (,$(findstring $(KPKG_SUBARCH), powerpc64 ppc64))
  KPKG_SUBARCH:=powerpc64
endif
# apus subarch
ifneq (,$(findstring $(KPKG_SUBARCH),APUs apus Amiga))
  KPKG_SUBARCH:=apus
endif
# nubus subarch
ifneq (,$(findstring $(KPKG_SUBARCH), NuBuS nubus))
  KPKG_SUBARCH := nubus
  KERNEL_ARCH:=ppc
  target := zImage
  kimagesrc = arch/$(KERNEL_ARCH)/appleboot/Mach\ Kernel
  kimage := vmlinux
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(KERNELRELEASE)
endif
# prpmc subarch
ifneq (,$(findstring $(KPKG_SUBARCH),PRPMC prpmc))
  KPKG_SUBARCH:=prpmc
  target = zImage
  kelfimagesrc = arch/$(KERNEL_ARCH)/boot/images/zImage.pplus
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(KERNELRELEASE)
endif
# mbx subarch
ifneq (,$(findstring $(KPKG_SUBARCH),MBX mbx))
  KPKG_SUBARCH:=mbx
  target = zImage
  kelfimagesrc = $(shell if [ -d arch/$(KERNEL_ARCH)/mbxboot ]; then \
        echo arch/$(KERNEL_ARCH)/mbxboot/$(kimage) ; else            \
        echo arch/$(KERNEL_ARCH)/boot/images/zvmlinux.embedded; fi)
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(KERNELRELEASE)
endif

#Local variables:
#mode: makefile
#End:
