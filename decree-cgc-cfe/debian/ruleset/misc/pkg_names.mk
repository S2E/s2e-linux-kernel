######################### -*- Mode: Makefile-Gmake -*- ########################
## pkg_names.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 17:45:52 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 14:33:01 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 5
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : sets up package names for the packages we can
##                    build (based on kernel version), the locations under
##                    ./debian where these packages shall be built, and the
##                    corresponding relative directory paths
## 
## arch-tag: c0247c14-1314-4245-9d18-6687ac9a9262
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


# KPKG_SUBARCH is used to distinguish Amiga, Atari, Macintosh, etc. kernels
# for Debian/m68k.  INT_SUBARCH is used in the names of the image file
# produced. It only affects the naming of the kernel-image as the
# source and doc packages are architecture independent and the
# kernel-headers do not vary from one sub-architecture to the next.

# This is the default
INT_SUBARCH :=

ifneq ($(strip $(ARCH_IN_NAME)),)
ifneq ($(strip $(KPKG_SUBARCH)),)
INT_SUBARCH := -$(KPKG_SUBARCH)
endif
endif

# The name of the package (for example, 'emacs').
s_package  = $(INT_STEM)-source-$(KERNELRELEASE)
h_package  = $(INT_STEM)-headers-$(KERNELRELEASE)
ifeq ($(strip $(KERNEL_ARCH)),um)
	i_package  = $(INT_STEM)-uml-$(KERNELRELEASE)$(INT_SUBARCH)
	b_package  = $(INT_STEM)-uml-$(KERNELRELEASE)$(INT_SUBARCH)-dbg
else
	i_package  = $(INT_STEM)-image-$(KERNELRELEASE)$(INT_SUBARCH)
	b_package  = $(INT_STEM)-image-$(KERNELRELEASE)$(INT_SUBARCH)-dbg
endif
d_package  = $(INT_STEM)-doc-$(KERNELRELEASE)
m_package  = $(INT_STEM)-manual-$(KERNELRELEASE)

SRCTOP     = $(shell if [ "$$PWD" != "" ]; then echo $$PWD; else pwd; fi)

TMPTOP     = $(SRCTOP)/debian/$(package)
LINTIANDIR = $(TMPTOP)/usr/share/lintian/overrides
DOCBASEDIR = $(TMPTOP)/usr/share/doc-base
MENUDIR    = $(TMPTOP)/usr/share/menu

BINDIR  = $(TMPTOP)/usr/bin
LIBDIR  = $(TMPTOP)/usr/lib
MANDIR  = $(TMPTOP)/usr/share/man
DOCTOP  = $(TMPTOP)/usr/share/doc
DOCDIR  = $(TMPTOP)/usr/share/doc/$(package)
SRCDIR  = $(TMPTOP)/usr/src/$(package)
MAN1DIR = $(MANDIR)/man1
MAN9DIR = $(MANDIR)/man9
INFODIR = $(TMPTOP)/usr/share/info

UML_DIR        = $(TMPTOP)/usr/lib/uml/modules/$(KERNELRELEASE)

TMP_MAN        = $(SRCTOP)/debian/tmp_man
DIRS_TO_CLEAN += $(TMP_MAN)

# The destination of all .deb files
# (suggested by Rob Browning <osiris@cs.utexas.edu>)
DEB_DEST ?= ..
INSTALL_MOD_PATH=$(TMPTOP)
KPKG_DEST_DIR ?= $(SRCTOP)/$(DEB_DEST)

#Local variables:
#mode: makefile
#End:
