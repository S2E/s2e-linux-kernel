######################### -*- Mode: Makefile-Gmake -*- ########################
## kernel_arch.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Tue Feb  7 09:17:03 2006
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Tue Feb  7 09:19:34 2006
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 6
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
## 
## arch-tag: fe23148e-81e2-41f2-8be0-66048282d9d4
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

# This file is here to localize the various over rides of architecture
# required to match the arch name dpkg-architecture determines and what
# the kernel folks call that platform.

# Set the default. The arch specific snippets can override this
# Apparently, DEB_HOST_ARCH_CPU does not match what the kernel calls this. 
# However, DEB_HOST_GNU_CPU does. Anyway, we have to hack around it
KERNEL_ARCH:=$(architecture)
ifeq ($(architecture), amd64)
  KERNEL_ARCH:=x86_64
endif
ifeq ($(architecture), mipsel)
  KERNEL_ARCH:=mips
endif

ifneq (,$(filter mips64%,$(KPKG_SUBARCH)))
  KERNEL_ARCH = mips64
endif
ifneq (,$(filter %-64,$(KPKG_SUBARCH)))
  KERNEL_ARCH = mips64
endif

ifeq ($(strip $(architecture)),armeb)
  KERNEL_ARCH := arm
endif

ifeq ($(strip $(architecture)),hppa)
  KERNEL_ARCH := parisc
endif


#Local variables:
#mode: makefile
#End:
