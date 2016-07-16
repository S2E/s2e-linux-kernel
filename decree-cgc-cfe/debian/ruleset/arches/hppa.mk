######################### -*- Mode: Makefile-Gmake -*- ########################
## hppa.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 18:31:10 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 14:19:56 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 1
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : handle the architecture specific variables.
## 
## arch-tag: e9f24b0e-ce5f-48c6-87f5-ab44b059be3d
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

kimage := vmlinux
target=vmlinux
NEED_DIRECT_GZIP_IMAGE=NO
# Override arch name because hppa uses arch/parisc not arch/hppa
KERNEL_ARCH := parisc
kimagesrc=vmlinux
kimagedest=$(INT_IMAGE_DESTDIR)/vmlinux-$(KERNELRELEASE)
# This doesn't seem to work, but the other archs do it...
DEBCONFIG=$(CONFDIR)/config.$(KPKG_SUBARCH)

#Local variables:
#mode: makefile
#End:
