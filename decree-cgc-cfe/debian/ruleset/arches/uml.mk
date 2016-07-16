######################### -*- Mode: Makefile-Gmake -*- ########################
## uml.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 18:30:26 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 14:19:00 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 1
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : handle the architecture specific variables.
## 
## arch-tag: 5d5079a2-4726-4e2d-8226-6e8edc22bea8
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

DEBCONFIG = $(CONFDIR)/config.um


ifneq ($(shell if [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge 6 ] &&    \
                  [ $(SUBLEVEL) -ge 9 ]; then echo new;                   \
             elif [ $(VERSION)  -ge  2 ]  && [ $(PATCHLEVEL) -ge r ]; then \
                                          echo new;                        \
             elif [ $(VERSION)  -ge  3 ]; then echo new; fi),)
  target  = vmlinux
  kimage := vmlinux
else
  target  = linux
  kimage := linux
endif


kimagesrc  = $(strip $(target))
INT_IMAGE_DESTDIR=$(DOCDIR)
IMAGEDIR = /usr/bin
kimagedest = $(TMPTOP)/$(IMAGEDIR)/linux-$(KERNELRELEASE)
KERNEL_ARCH = um
architecture = i386

#Local variables:
#mode: makefile
#End:
