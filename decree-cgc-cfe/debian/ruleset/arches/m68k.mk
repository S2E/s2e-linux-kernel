######################### -*- Mode: Makefile-Gmake -*- ########################
## m68k.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 18:31:08 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 14:19:31 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 1
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : handle the architecture specific variables.
## 
## arch-tag: e9307322-5eaf-4c90-abb1-a2802d0b3efc
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

ifeq (,$(findstring /$(KPKG_SUBARCH)/,/amiga/atari/mac/mvme147/mvme16x/bvme6000/))
  GUESS_SUBARCH:=$(shell awk '/Model/ { print $$2}' /proc/hardware)
  ifneq (,$(findstring Motorola,$(GUESS_SUBARCH)))
   GUESS_SUBARCH:=$(shell awk '/Model/ { print $$3}' /proc/hardware)
   ifneq (,$(findstring MVME147,$(GUESS_SUBARCH)))
    KPKG_SUBARCH:=mvme147
   else
    KPKG_SUBARCH:=mvme16x
   endif
  else
   ifneq (,$(findstring BVME,$(GUESS_SUBARCH)))
    KPKG_SUBARCH:=bvme6000
   else
    ifneq (,$(findstring Amiga,$(GUESS_SUBARCH)))
     KPKG_SUBARCH:=amiga
    else
     ifneq (,$(findstring Atari,$(GUESS_SUBARCH)))
      KPKG_SUBARCH:=atari
     else
      ifneq (,$(findstring Mac,$(GUESS_SUBARCH)))
       KPKG_SUBARCH:=mac
      endif
     endif
    endif
   endif
  endif
endif
NEED_DIRECT_GZIP_IMAGE=NO
kimage := vmlinuz
target = zImage
kimagesrc = vmlinux.gz
kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(KERNELRELEASE)
kelfimagesrc = vmlinux
kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(KERNELRELEASE)
DEBCONFIG = $(CONFDIR)/config.$(KPKG_SUBARCH)

#Local variables:
#mode: makefile
#End:
