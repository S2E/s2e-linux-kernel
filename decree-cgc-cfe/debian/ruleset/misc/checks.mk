######################### -*- Mode: Makefile-Gmake -*- ########################
## checks.mk --- 
## Author	    : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On	    : Mon Oct 31 18:07:07 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Fri Dec  2 23:41:20 2005
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count	    : 3
## Status	    : Unknown, Use with caution!
## HISTORY	    : 
## Description	    : Various checks that would let the build process detect and
##                    abort on various error conditions.
## 
## arch-tag: 029ce463-a047-46a4-93c6-ad9549e04be4
## 
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##
###############################################################################


ifeq (,$(strip $(kimagedest)))
$(error Error. I do not know where the kernel image goes to [kimagedest undefined] \
 The usual case for this is that I could not determine which arch or subarch	   \
 this machine belongs to. Please specify a subarch, and try again.)
endif
ifeq (,$(strip $(kimagesrc)))
$(error Error. I do not know where the kernel image goes to [kimagesrc undefined] \
 The usual case for this is that I could not determine which arch or subarch	  \
 this machine belongs to. Please specify a subarch, and try again.)
endif

define checkroot
	@test $$(id -u) = 0 || (echo need root priviledges; exit 1)
endef

require_root=
warn_root=

ifeq ($(strip $(int_am_root)),)
  ifeq ($(strip $(ROOT_CMD)),)
    define require_root
	@echo need root privileges; exit 1
    endef
  endif
endif

ifeq ($(strip $(int_am_root)),)
  ifeq ($(strip $(ROOT_CMD)),)
   define warn_root
	@echo "You may need root privileges - some parts may fail."
   endef
  endif
endif

define checkdir
	@echo ""
endef

$(eval $(check_kernel_dir))
$(eval $(check_kernel_headers))
ifeq ($(strip $(IN_KERNEL_DIR)),)
  ifeq ($(strip $(IN_KERNEL_HEADERS)),)
    define checkdir
	@(echo Not in correct source directory; exit 1)
    endef
  endif
endif

#Local variables:
#mode: makefile
#End:
