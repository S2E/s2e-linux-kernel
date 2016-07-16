############################ -*- Mode: Makefile -*- ###########################
## kernel_version.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 18:12:22 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Sun Mar 26 19:53:50 2006
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 1
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
## 
## arch-tag: 8ae3064b-78fe-4dfb-9460-a43660d0e0ca
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

# The purpose of this snippet of makefile is to easily and accurately
# extract out the kernel version information.


MAKEFLAGS:=$(filter-out -w,$(MAKEFLAGS))
MFLAGS:=$(filter-out -w,$(FLAGS))

# Include the kernel makefile
override dot-config := 1
include Makefile
dot-config := 1

.PHONY: debian_VERSION debian_PATCHLEVEL debian_SUBLEVEL
.PHONY: debian_EXTRAVERSION debian_LOCALVERSION debian_TOPDIR


debian_KERNELRELEASE:
	@echo "$(strip $(KERNELRELEASE))"

debian_VERSION:
	@echo "$(strip $(VERSION))"

debian_PATCHLEVEL:
	@echo "$(strip $(PATCHLEVEL))"

debian_SUBLEVEL:
	@echo "$(strip $(SUBLEVEL))"

debian_EXTRAVERSION:
	@echo "$(strip $(EXTRAVERSION))"

debian_LOCALVERSION:
	@echo $(if $(strip $(localver-full)),"$(strip $(localver-full))", "$(strip $(LOCALVERSION))")

debian_TOPDIR:
# 2.6 kernels declared TOPDIR obsolete, so use srctree if it exists
	@echo $(if $(strip $(srctree)),"$(srctree)","$(TOPDIR)")


debian_conf_var:
	@echo "ARCH             = $(ARCH)"
	@echo "HOSTCC           = $(HOSTCC)"
	@echo "HOSTCFLAGS       = $(HOSTCFLAGS)"
	@echo "CROSS_COMPILE    = $(CROSS_COMPILE)"
	@echo "AS               = $(AS)"
	@echo "LD               = $(LD)"
	@echo "CC               = $(CC)"
	@echo "CPP              = $(CPP)"
	@echo "AR               = $(AR)"
	@echo "NM               = $(NM)"
	@echo "STRIP            = $(STRIP)"
	@echo "OBJCOPY          = $(OBJCOPY)"
	@echo "OBJDUMP          = $(OBJDUMP)"
	@echo "MAKE             = $(MAKE)"
	@echo "GENKSYMS         = $(GENKSYMS)"
	@echo "CFLAGS           = $(CFLAGS)"
	@echo "AFLAGS           = $(AFLAGS)"
	@echo "MODFLAGS         = $(MODFLAGS)"


# arch-tag: ecfa9843-6306-470e-8ab9-2dfca1d40613

#Local Variables:
#mode: makefile
#End:
