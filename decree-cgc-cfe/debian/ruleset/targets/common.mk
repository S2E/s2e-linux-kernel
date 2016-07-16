######################### -*- Mode: Makefile-Gmake -*- ########################
## target.mk ---
## Author	    : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com )
## Created On	    : Mon Oct 31 10:41:41 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Mon Apr 13 01:21:30 2009
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count	    : 97
## Status	    : Unknown, Use with caution!
## HISTORY	    :
## Description	    : This file provides the commands commaon to a number of
##		      packages built, and also includes the files providing
##		      commands to build each of the packages we create.
##
## arch-tag: 254cf803-a899-4234-ba83-8d032e970c38
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

# fakeroot has a bad interaction with parrallel builds and the
# buildpackage target
SERIAL_BUILD_OPTIONS=$(DEB_BUILD_OPTIONS)
ifneq (,$(filter parallel=%,$(DEB_BUILD_OPTIONS)))
  ifeq (fakeroot,$(strip $(root_cmd)))
    SERIAL_BUILD_OPTIONS=$(strip $(filter-out parallel=%,$(DEB_BUILD_OPTIONS)))
  endif
endif

# Find out whether we need to have a pre-defined .config
NEED_CONFIG = $(shell if [ $(VERSION) -lt 2 ]; then			   \
			   echo "";					   \
	   elif [ $(VERSION) -eq 2 ] && [ $(PATCHLEVEL) -lt 6 ]; then	   \
			   echo "";					   \
	   elif [ $(VERSION) -eq 2 ] && [ $(PATCHLEVEL) -eq 6 ] &&	   \
		   [ $(SUBLEVEL) -lt 18 ]; then				   \
			   echo "";					   \
	   else								   \
			   echo "YES";					   \
	   fi)

USE_KBUILD=$(shell if [ $(VERSION) -lt 2 ]; then			   \
			   echo "";					   \
	   elif [ $(VERSION) -eq 2 ] && [ $(PATCHLEVEL) -lt 6 ]; then	   \
			   echo "";					   \
	   elif [ $(VERSION) -eq 2 ] && [ $(PATCHLEVEL) -eq 6 ] &&	   \
		   [ $(SUBLEVEL) -lt 22 ]; then				   \
			   echo "";					   \
	   else								   \
			   echo "YES";					   \
	   fi)

LGUEST_SUBDIR = $(word 1,$(wildcard Documentation/lguest Documentation/virtual/lguest tools/lguest))

define save_upstream_debianization
@echo save_upstream_debianization
test ! -e scripts/package/builddeb || mv -f scripts/package/builddeb scripts/package/builddeb.kpkg-dist
test ! -e scripts/package/Makefile ||					  \
    test -f scripts/package/Makefile.kpkg-dist ||			  \
    (mv -f scripts/package/Makefile scripts/package/Makefile.kpkg-dist && \
       (echo "# Dummy file "; echo "help:") >  scripts/package/Makefile)
endef

define restore_upstream_debianization
@echo restore_upstream_debianization
test ! -f scripts/package/builddeb.kpkg-dist ||	mv -f scripts/package/builddeb.kpkg-dist scripts/package/builddeb
test ! -f scripts/package/Makefile.kpkg-dist ||	mv -f scripts/package/Makefile.kpkg-dist scripts/package/Makefile
endef

sanity_check:
ifeq ($(strip $(IN_KERNEL_DIR)),)
	@echo "Not in correct source directory"
	@echo "You should invoke this command from the top level directory of"
	@echo "a linux kernel source directory tree, and as far as I can tell,"
	@echo "the current directory:"
	@echo "	$(SRCTOP)"
	@echo "is not a top level linux kernel source directory. "
	@echo ""
	@echo "	(If I am wrong then kernel-packages and the linux kernel"
	@echo "	 are so out sync that you'd better get the latest versions"
	@echo "	 of the kernel-package package and the Linux sources)"
	@echo ""
	@echo "Please change directory to wherever linux kernel sources"
	@echo "reside and try again."
	exit 1
endif
ifneq ($(strip $(HAVE_VALID_PACKAGE_VERSION)),YES)
	@echo "Problems ecountered with the version number $(debian)."
	@echo "$(HAVE_VALID_PACKAGE_VERSION)"
	@echo ""
	@echo "Please re-read the README file and try again."
	exit 2
endif
ifeq ($(strip $(STOP_FOR__BIN86)),YES)
	@echo "You Need to install the package bin86 before you can "
	@echo "compile the kernel on this machine"
	@echo ""
	@echo "Please install bin86 and try again."
	exit 3
endif
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@echo "The changelog says we are creating $(saved_version)"
	@echo "However, I thought the version is $(KERNELRELEASE)"
	exit 4
endif





.config:
	$(REASON)
	$(checkdir)
ifneq ($(strip $(use_saved_config)),NO)
	test -f .config || test ! -f .config.save || \
			    cp -pf .config.save .config
endif
	test -f .config || test ! -f $(CONFIG_FILE) || \
			    cp -pf $(CONFIG_FILE) .config
	$(eval $(which_debdir))
	test -f .config || test ! -f $(DEBDIR)/config || \
			    cp -pf $(DEBDIR)/config  .config
ifeq ($(strip $(have_new_config_target)),)
  ifneq ($(strip $(NEED_CONFIG)),)
	test -f .config || $(MAKE) defconfig
  endif
	test -f .config || (echo "*** Need a config file .config" && false)
endif
# if $(have_new_config_target) is set, then we need not have a .config
# file at this point


debian/stamp/conf/vars:
	$(REASON)
	$(checkdir)
	@test -d ./debian          || mkdir debian
	@test -d debian/stamp	   || mkdir debian/stamp
	@test -d debian/stamp/conf || mkdir debian/stamp/conf
	@rm -f debian/stamp/conf/mak
	@touch debian/stamp/conf/mak
	@echo "This is kernel package version $(kpkg_version)." >> debian/stamp/conf/mak
	@echo "VERSION		= $(VERSION)"	    >> debian/stamp/conf/mak
	@echo "PATCHLEVEL	= $(PATCHLEVEL)"    >> debian/stamp/conf/mak
	@echo "SUBLEVEL		= $(SUBLEVEL)"	    >> debian/stamp/conf/mak
	@echo "EXTRAVERSION	= $(EXTRAVERSION)"  >> debian/stamp/conf/mak
ifneq ($(strip $(iatv)),)
	@echo "APPEND_TO_VERSION = $(iatv)"	    >> debian/stamp/conf/mak
endif
ifeq ($(strip $(MODULES_ENABLED)),YES)
	@echo "KPKG_SELECTED_MODULES = $(KPKG_SELECTED_MODULES)" >> debian/stamp/conf/mak
endif
	@echo "Debian Revision	= $(debian)"	    >> debian/stamp/conf/mak
	@echo "KPKG_ARCH	= $(KPKG_ARCH)"	       >> debian/stamp/conf/mak
# Fetch the rest of the information from the kernel's Makefile
	$(eval $(which_debdir))
ifeq ($(DEB_HOST_ARCH_OS), linux)
	@$(MAKE) --no-print-directory -sf $(DEBDIR)/ruleset/kernel_version.mk  \
	  ARCH=$(KERNEL_ARCH) $(CROSS_ARG) debian_conf_var >> debian/stamp/conf/mak
endif
	@echo "do_parallel	= $(do_parallel)"   >> debian/stamp/conf/mak
	@echo "fast_dep		= $(fast_dep)"	    >> debian/stamp/conf/mak
#	@sed -e 's%$(TOPDIR)%$$(TOPDIR)%g' debian/stamp/conf/mak	    > debian/stamp/conf/vars
# Use the kernel's Makefile to calculate the TOPDIR.
# TOPDIR is obsolete in 2.6 kernels, so the kernel_version.mk
# will get us the right answer
	@echo $(shell $(MAKE) --no-print-directory -sf $(DEBDIR)/ruleset/kernel_version.mk debian_TOPDIR 2>/dev/null | tail -n 1) >/dev/null
	@sed -e 's%$(shell $(MAKE) --no-print-directory -sf $(DEBDIR)/ruleset/kernel_version.mk debian_TOPDIR 2>/dev/null | tail -n 1)%$$(TOPDIR)%g' debian/stamp/conf/mak     > debian/stamp/conf/vars
	@rm -f debian/stamp/conf/mak
	@touch debian/stamp/conf/vars

debian/stamp/conf/kernel-conf:
	$(REASON)
	@test -d debian/stamp	   || mkdir debian/stamp
	@test -d debian/stamp/conf || mkdir debian/stamp/conf
	$(eval $(which_debdir))
	$(eval $(deb_rule))
ifeq ($(DEB_HOST_ARCH_OS), kfreebsd)
	mkdir -p bin
	ln -sf `which gcc-3.4` bin/cc
	cd $(architecture)/conf && freebsd-config GENERIC
endif
######################################################################
### Prepare the version number
######################################################################
ifeq ($(DEB_HOST_ARCH_OS), linux)
	$(MAKE) $(EXTRAV_ARG) $(FLAV_ARG) $(CROSS_ARG) ARCH=$(KERNEL_ARCH) \
                    $(config_target);
  ifeq ($(shell if   [ $(VERSION) -gt 2 ]; then				   \
		   echo new;						   \
		elif [ $(VERSION) -ge 2 ] && [ $(PATCHLEVEL) -ge 5 ]; then \
		  echo new;						   \
		fi),)
	+$(MAKE) $(EXTRAV_ARG) $(FLAV_ARG) $(CROSS_ARG) \
				 ARCH=$(KERNEL_ARCH) $(fast_dep) dep
	$(MAKE) $(EXTRAV_ARG) $(FLAV_ARG) $(CROSS_ARG) ARCH=$(KERNEL_ARCH) clean
  else
    ifeq ($(strip $(MAKING_VIRTUAL_IMAGE)),)
	$(MAKE) $(EXTRAV_ARG) $(FLAV_ARG) $(CROSS_ARG) ARCH=$(KERNEL_ARCH) prepare
    endif
  endif
else
  ifeq ($(DEB_HOST_ARCH_OS), kfreebsd)
	+$(PMAKE) -C $(architecture)/compile/GENERIC depend
  endif
endif
	echo done > $@


debian/control debian/changelog debian/rules debian/stamp/conf/full-changelog:
	$(REASON)
	@test -f $(LIBLOC)/rules   || echo Error: Could not find $(LIBLOC)/rules
	@test -f $(LIBLOC)/rules   || exit 4
	@test -d debian/stamp	   || mkdir debian/stamp
	@test -d debian/stamp/conf || mkdir debian/stamp/conf
	for file in $(DEBIAN_FILES); do				\
	     cp -f  $(LIBLOC)/$$file ./debian/;			\
	done
	for dir  in $(DEBIAN_DIRS);	do				\
	   cp -af $(LIBLOC)/$$dir  ./debian/;				\
	done
	install -p -m 755 $(LIBLOC)/rules debian/rules
	sed         -e 's/=V/$(KERNELRELEASE)/g'  \
                -e 's/=D/$(debian)/g'         -e 's/=A/$(DEB_HOST_ARCH)/g'  \
		-e 's/=SA/$(INT_SUBARCH)/g'  \
		-e 's/=I/$(initrddep)/g'				    \
		-e 's/=CV/$(VERSION).$(PATCHLEVEL)/g'			    \
		-e 's/=M/$(maintainer) <$(email)>/g'			    \
		-e 's/=ST/$(INT_STEM)/g'      -e 's/=B/$(KERNEL_ARCH)/g'    \
                  $(CONTROL) > debian/control
	sed -e 's/=V/$(KERNELRELEASE)/g' -e 's/=D/$(debian)/g'	      \
	    -e 's/=A/$(DEB_HOST_ARCH)/g' -e 's/=M/$(maintainer) <$(email)>/g' \
	    -e 's/=ST/$(INT_STEM)/g'	 -e 's/=B/$(KERNEL_ARCH)/g'	      \
		$(LIBLOC)/changelog > debian/changelog
ifneq (,$(strip $(KPKG_OVERLAY_DIR)))
	test ! -d $(strip $(KPKG_OVERLAY_DIR))  ||                          \
          (cd $(strip $(KPKG_OVERLAY_DIR)); tar cf - . | (cd $(SRCTOP)/debian; umask 000; tar xsf -))
	test ! -f $(strip $(KPKG_OVERLAY_DIR))/Control ||                   \
                sed         -e 's/=V/$(KERNELRELEASE)/g'  \
                -e 's/=D/$(debian)/g'         -e 's/=A/$(DEB_HOST_ARCH)/g'  \
		-e 's/=SA/$(INT_SUBARCH)/g'  \
		-e 's/=I/$(initrddep)/g'				    \
		-e 's/=CV/$(VERSION).$(PATCHLEVEL)/g'			    \
		-e 's/=M/$(maintainer) <$(email)>/g'			    \
		-e 's/=ST/$(INT_STEM)/g'      -e 's/=B/$(KERNEL_ARCH)/g'    \
                  $(strip $(KPKG_OVERLAY_DIR))/Control > debian/control
	test ! -f $(strip $(KPKG_OVERLAY_DIR))/changelog ||                 \
            sed -e 's/=V/$(KERNELRELEASE)/g'       \
            -e 's/=D/$(debian)/g'        -e 's/=A/$(DEB_HOST_ARCH)/g'       \
            -e 's/=ST/$(INT_STEM)/g'     -e 's/=B/$(KERNEL_ARCH)/g'         \
            -e 's/=M/$(maintainer) <$(email)>/g'                            \
             $(strip $(KPKG_OVERLAY_DIR))/changelog > debian/changelog
	test ! -x $(strip $(KPKG_OVERLAY_DIR))/post-install ||              \
            (cd debian; $(strip $(KPKG_OVERLAY_DIR))/post-install)
endif
	chmod 0644 debian/control debian/changelog
	$(MAKE) -f debian/rules debian/stamp/conf/kernel-conf
	@echo done > debian/stamp/conf/full-changelog

debian/stamp/conf/common: debian/stamp/conf/full-changelog
	$(REASON)
	@test -d debian/stamp	   || mkdir debian/stamp
	@test -d debian/stamp/conf || mkdir debian/stamp/conf
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@echo "The changelog says we are creating $(saved_version)."
	@echo "However, I thought the version is $(KERNELRELEASE)"
	exit 3
endif
	echo done >  $@


debian/stamp/build/kernel: debian/stamp/conf/vars
	$(REASON)
	@test -d debian/stamp	   || mkdir debian/stamp
	@test -d debian/stamp/build || mkdir debian/stamp/build
	@echo "This is kernel package version $(kpkg_version)."
# Builds the binary package.
# debian.config contains the current idea of what the image should
# have.
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@echo "The changelog says we are creating $(saved_version)"
	@echo "However, I thought the version is $(KERNELRELEASE)"
	exit 1
endif
# Here, we check to see if what we think is the UTS_RELEASE_VERSION matches the version
# If not, we re-extract the uts release version from the header, to see if our understanding
# of UTS_RELEASE_VERSION is correct. This probably does not work right.
	$(if $(strip $(subst $(strip $(UTS_RELEASE_VERSION)),,$(strip $(KERNELRELEASE)))),	  \
	  if [ -f $(UTS_RELEASE_HEADER) ]; then						  \
	     uts_ver=$$(grep 'define UTS_RELEASE' $(UTS_RELEASE_HEADER) |		  \
		perl -nle  'm/^\s*\#define\s+UTS_RELEASE\s+("?)(\S+)\1/g && print $$2;'); \
	    if [ "X$$uts_ver" != "X$(strip $(UTS_RELEASE_VERSION))" ]; then		  \
		echo "The UTS Release version in $(UTS_RELEASE_HEADER)";		  \
		echo "	   \"$$uts_ver\" ";						  \
		echo "does not match current version " ;				  \
		echo "	   \"$(strip $(KERNELRELEASE))\" " ;					  \
		echo "Reconfiguring." ;							  \
		touch Makefile;								  \
	     fi;									  \
	  fi)
ifeq ($(DEB_HOST_ARCH_OS), linux)
	$(restore_upstream_debianization)
  ifeq ($(strip $(USE_KBUILD)),yes)
	$(MAKE) $(do_parallel) $(EXTRAV_ARG) $(FLAV_ARG) ARCH=$(KERNEL_ARCH) \
			    $(CROSS_ARG) $(KPKG_KBUILD_DEFAULT_TARGET)
  else
	$(MAKE) $(do_parallel) $(EXTRAV_ARG) $(FLAV_ARG) ARCH=$(KERNEL_ARCH) \
			    $(CROSS_ARG) $(target)
    ifneq ($(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),)
	$(MAKE) $(do_parallel) $(EXTRAV_ARG) $(FLAV_ARG) ARCH=$(KERNEL_ARCH) \
			    $(CROSS_ARG) modules
    endif
  endif
  ifneq ($(strip $(shell grep -E ^[^\#]*CONFIG_LGUEST $(CONFIG_FILE))),)
    ifeq ($(LGUEST_SUBDIR),)
	$(error Cannot find lguest tools)
    endif
	$(MAKE) $(do_parallel) $(EXTRAV_ARG) $(FLAV_ARG) ARCH=$(KERNEL_ARCH) \
			    $(CROSS_ARG) -C $(LGUEST_SUBDIR)
  endif
else
  ifeq ($(DEB_HOST_ARCH_OS), kfreebsd)
	$(PMAKE) -C $(architecture)/compile/GENERIC
  endif
endif
	COLUMNS=150 dpkg -l 'gcc*' perl dpkg 'libc6*' binutils make dpkg-dev |\
	 awk '$$1 ~ /[hi]i/ { printf("%s-%s\n", $$2, $$3) }'> debian/stamp/build/info
	@echo this was built on a machine with the kernel: >> debian/stamp/build/info
	uname -a >> debian/stamp/build/info
	echo using the compiler: >> debian/stamp/build/info
	if [ -f include/generated/compile.h ]; then                      \
	   grep LINUX_COMPILER include/generated/compile.h |             \
	     sed -e 's/.*LINUX_COMPILER "//' -e 's/"$$//' >>             \
               debian/stamp/build/info;                                  \
        elif [ -f include/linux/compile.h  ]; then                       \
	    grep LINUX_COMPILER include/linux/compile.h |                \
	      sed -e 's/.*LINUX_COMPILER "//' -e 's/"$$//' >>            \
                debian/stamp/build/info;                                 \
         fi
ifneq ($(strip $(shell test -f version.Debian && cat version.Debian)),)
	echo kernel source package used: >> debian/stamp/build/info
	echo $(INT_STEM)-source-$(shell cat version.Debian) >> debian/stamp/build/info
endif
	echo done > $@


real_stamp_clean: 
	$(REASON)
	@echo running clean
ifeq ($(strip $(DEB_HOST_ARCH_OS)), linux)
	$(save_upstream_debianization)
	test ! -f .config  || cp -pf .config ,,precious
  ifneq ($(LGUEST_SUBDIR),)
	$(MAKE) $(FLAV_ARG) $(EXTRAV_ARG) $(CROSS_ARG)   \
           ARCH=$(KERNEL_ARCH) -C $(LGUEST_SUBDIR) clean
  endif
	test ! -f Makefile || \
	    $(MAKE) $(FLAV_ARG) $(EXTRAV_ARG) $(CROSS_ARG)    \
                ARCH=$(KERNEL_ARCH) distclean
	test ! -f ,,precious || mv -f ,,precious .config
	$(restore_upstream_debianization)
else
	rm -f .config
  ifeq ($(DEB_HOST_ARCH_OS), kfreebsd)
	rm -rf bin
	if test -e $(architecture)/compile/GENERIC ; then     \
	  $(PMAKE) -C $(architecture)/compile/GENERIC clean ; \
	fi
  endif
endif
	$(eval $(deb_rule))
	test -f stamp-building || rm -rf debian
	rm -f $(FILES_TO_CLEAN) $(STAMPS_TO_CLEAN)
	rm -rf $(DIRS_TO_CLEAN)



debian/stamp/build/buildpackage: debian/stamp/pre-config-common
	$(REASON)
	@test -d debian/stamp	   || mkdir debian/stamp
	@test -d debian/stamp/build || mkdir debian/stamp/build
	@echo "This is kernel package version $(kpkg_version)."
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@echo "The changelog says we are creating $(saved_version)"
	@echo "However, I thought the version is $(KERNELRELEASE)"
	exit 1
endif
	echo 'Building Package' > stamp-building
# work around idiocy in recent kernel versions
# However, this makes it harder to use git versions of the kernel
	$(save_upstream_debianization)
	DEB_BUILD_OPTIONS="$(SERIAL_BUILD_OPTIONS)" CONCURRENCY_LEVEL=1     \
          dpkg-buildpackage $(strip $(int_root_cmd)) $(strip $(int_us))     \
            $(strip $(int_uc)) -j1 -k"$(pgp)"  -m"$(maintainer) <$(email)>"
	rm -f stamp-building
	$(restore_upstream_debianization)
	echo done >  $@


$(eval $(which_debdir))
include $(DEBDIR)/ruleset/targets/source.mk
include $(DEBDIR)/ruleset/targets/headers.mk
include $(DEBDIR)/ruleset/targets/manual.mk
include $(DEBDIR)/ruleset/targets/doc.mk
include $(DEBDIR)/ruleset/targets/image.mk
include $(DEBDIR)/ruleset/targets/debug.mk

#Local variables:
#mode: makefile
#End:
