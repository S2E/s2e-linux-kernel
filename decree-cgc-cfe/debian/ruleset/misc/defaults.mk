######################### -*- Mode: Makefile-Gmake -*- ########################
## defaults.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 17:43:59 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Tue Feb  7 09:24:07 2006
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 8
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : sets default values for variables _before_ the
##                    user configuration files are read.
## 
## arch-tag: a28f832f-5d67-427c-9370-0defffa8471c
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

# The maintainer information.
maintainer = Unknown Kernel Package Maintainer
email= unknown@unconfigured.in.etc.kernel-pkg.conf

pgp=$(maintainer)

# This package is what we get after removing the psuedo dirs we use in rules
this_pkg = $(filter-out %/,$(subst /,/ ,$@))

# Where we read our config information from
CONFLOC    :=$(shell if test -f ~/.kernel-pkg.conf; then \
                        echo ~/.kernel-pkg.conf;         \
                     else                                \
                        echo /etc/kernel-pkg.conf;       \
                     fi)
# Default location of the modules
ifeq ($(strip $(MODULE_LOC)),)
MODULE_LOC =/usr/src/modules
endif
#
DEBIAN_FILES = ChangeLog  Control  Control.bin86 config templates.in rules
DEBIAN_DIRS  = Config docs examples ruleset scripts pkg po

ifneq (,$(findstring Unknown,$(maintainer)))
  ifneq ($(strip $(DEBFULLNAME)),)
     maintainer = $(DEBFULLNAME)
  else
    ifneq ($(strip $(NAME)),)
     maintainer = $(NAME)
    endif
  endif
endif

ifneq (,$(findstring unknown,$(email)))
  ifneq ($(strip $(DEBEMAIL)),)
      email = $(DEBEMAIL)
  else
    ifneq ($(strip $(EMAIL)),) 
      email = $(EMAIL)
   endif
  endif
endif


#  Package specific stuff

# These are what are used in ruleset/targets/{common,image}.mk to
# build and install the default target. Change this at your
# peril. since the targets called isntead of these might subtly break
# the rest of the kerel package building. But, at least, this is a
# start to being able to build alternate targets, as long as theya re
# drop in replacements as far as packaging is concerned.
KPKG_KBUILD_DEFAULT_TARGET:=all
KPKG_KBUILD_INSTALL_TARGET:=install

# The version numbers for kernel-image, kernel-headers and
# kernel-source are deduced from the Makefile (see below,
# and footnote 1 for details)

# run make clean after build
do_clean := NO

# install uncompressed kernel ELF-image (for oprofile)
int_install_vmlinux := NO

# The default architecture (all if architecture independent)
CROSS_ARG:=


#
# VERSION=$(shell LC_ALL=C dpkg-parsechangelog | grep ^Version: | \
#                          sed 's/^Version: *//')
#'

# architecture is used mostly to select which arch specific snippet
# shall be loaded from the rulesets/arches/ directory, and for nothing
# else. The real variable that we use for calling make on the top level
# Makefile, for instance, really depends on KERNEL_ARCH, usually set by
# arch specific makefile snippets.
ifdef KPKG_ARCH
  architecture:=$(KPKG_ARCH)
else
  #architecture:=$(shell CC=$(HOSTCC) dpkg --print-gnu-build-architecture)
  #architecture:=$(DEB_HOST_ARCH)
  ifeq (,$(DEB_HOST_ARCH_CPU))
    architecture:=$(DEB_HOST_GNU_CPU)
  else
    architecture:=$(DEB_HOST_ARCH_CPU)
  endif
endif

ifndef CROSS_COMPILE
  ifeq ($(strip $(MAKING_VIRTUAL_IMAGE)),)
    ifneq ($(strip $(architecture)),$(strip $(word 1,$(DEB_BUILD_ARCH_CPU) $(DEB_BUILD_GNU_CPU))))
      #KERNEL_CROSS:=$(architecture)-$(strip $(DEB_HOST_ARCH_OS))-
      KERNEL_CROSS:=$(DEB_HOST_GNU_TYPE)-
      ifeq ($(architecture), amd64)
        KERNEL_CROSS:=$(architecture)-$(strip $(DEB_HOST_ARCH_OS))-
      endif
    endif
  endif
else
  KERNEL_CROSS:=$(CROSS_COMPILE)-
endif

KERNEL_CROSS:=$(shell echo $(KERNEL_CROSS) | sed -e 's,--$$,-,')

ifneq ($(strip $(KERNEL_CROSS)),)
  ifeq ($(KERNEL_CROSS),-)
    CROSS_ARG:=CROSS_COMPILE=''
  else
    CROSS_ARG:=CROSS_COMPILE=$(KERNEL_CROSS)
  endif
endif

DEBCONFIG = $(CONFDIR)/config
IMAGEDIR=/boot
DEBUGDIR=/usr/lib/debug

comma:= ,
empty:=
space:= $(empty) $(empty)

include $(DEBDIR)/ruleset/misc/kernel_arch.mk

ifeq ($(DEB_HOST_ARCH_OS), kfreebsd)
  PMAKE = PATH=/usr/lib/freebsd/:$(CURDIR)/bin:$(PATH) WERROR= MAKEFLAGS= freebsd-make
endif


ifneq ($(strip $(KPKG_STEM)),)
INT_STEM := $(KPKG_STEM)
else
INT_STEM := $(DEB_HOST_ARCH_OS)
endif


#Local variables:
#mode: makefile
#End:
