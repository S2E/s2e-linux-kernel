######################### -*- Mode: Makefile-Gmake -*- ########################
## modules.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 18:08:29 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 14:22:30 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 1
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : deals with setting up variables, looking at
##                    directories, and creating a list of valid third party
##                    modules available for the kernel being built.
## 
## arch-tag: 9b687fd4-a7d0-4360-8ce6-3ce3a0e2cfac
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


# Deal with modules issues
ifeq ($(strip $(CONFDIR)),)
      $(eval $(which_debdir))
      CONFDIR     = $(DEBDIR)/Config
endif

# The file which has local configuration
$(eval $(which_debdir))
CONFIG_FILE := $(shell if test -e .config ; then \
                           echo .config; \
                       elif test -e $(DEBCONFIG) ; then \
                           echo $(DEBCONFIG); \
                       elif test -e $(CONFDIR)/config ; then \
                           echo $(CONFDIR)/config ; \
                       elif test -e $(DEBDIR)/config ; then \
                           echo $(DEBDIR)/config ; \
                       elif test -e /boot/config-$(KERNELRELEASE) ; then \
                           echo /boot/config-$(KERNELRELEASE) ; \
                       elif test -e /boot/config-$$(uname -r) ; then \
                           echo /boot/config-$$(uname -r) ; \
                       else echo /dev/null ; \
                       fi)


ifeq ($(DEB_HOST_ARCH_OS), linux)
  config = .config
else
  ifeq ($(DEB_HOST_ARCH_OS), kfreebsd)
    config = $(architecture)/conf/GENERIC
  endif
endif


# define MODULES_ENABLED if appropriate
ifneq ($(filter kfreebsd, $(DEB_HOST_ARCH_OS)):$(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),:)
  MODULES_ENABLED := YES
endif

# accept both space separated list of modules, as well as comma
# separated ones
valid_modules:=

# See what modules we are talking about
ifeq ($(strip $(MODULES_ENABLED)),YES)
ifneq ($(strip $(KPKG_SELECTED_MODULES)),)
canonical_modules=$(subst $(comma),$(space),$(KPKG_SELECTED_MODULES))
else
canonical_modules=$(shell test -e $(MODULE_LOC) && \
                       find $(MODULE_LOC) -follow -maxdepth 1 -type d -print |\
			   grep -E -v '^$(MODULE_LOC)/$$')
endif


# Now, if we have any modules at all, they are in canonical_modules
ifneq ($(strip $(canonical_modules)),)

# modules can have the full path, or just the name of the module. We
# make all the modules ahve absolute paths by fleshing them out.
path_modules   :=$(filter     /%, $(canonical_modules))
no_path_modules:=$(filter-out /%, $(canonical_modules))
fleshed_out    :=$(foreach mod,$(no_path_modules),$(MODULE_LOC)/$(mod))

# Hmmph. recreate the canonical modules; now everything has a full
# path name.

canonical_modules:=$(path_modules) $(fleshed_out)
# test to see if the dir names are real
valid_modules = $(shell for dir in $(canonical_modules); do \
                            if [ -d $$dir ] && [ -x $$dir/debian/rules ]; then \
                               echo $$dir;                  \
                            fi;                             \
                        done)


endif
endif


#Local variables:
#mode: makefile
#End:
