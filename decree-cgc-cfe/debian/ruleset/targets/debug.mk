######################### -*- Mode: Makefile-Gmake -*- ########################
## debug.mk --- 
## Author           : Manoj Srivastava ( srivasta@anzu.internal.golden-gryphon.com ) 
## Created On       : Thu Apr  9 01:54:37 2009
## Created On Node  : anzu.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Mon Apr 13 12:18:32 2009
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 18
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
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

debian/stamp/install/$(b_package):
	$(REASON)
	@echo "This is kernel package version $(kpkg_version)."
	$(if $(subst $(strip $(UTS_RELEASE_VERSION)),,$(strip $(KERNELRELEASE))), \
		echo "The UTS Release version in $(UTS_RELEASE_HEADER)"; \
		echo "     \"$(strip $(UTS_RELEASE_VERSION))\" "; \
		echo "does not match current version:"; \
		echo "     \"$(strip $(KERNELRELEASE))\" "; \
		echo "Please correct this."; \
		exit 2,)
	rm -rf $(TMPTOP)
	@test -d debian/stamp/install || mkdir debian/stamp/install
	$(eval $(which_debdir))
	$(make_directory) $(DOCDIR)
	$(make_directory) $(TMPTOP)/$(DEBUGDIR)
######################################################################
#### Add documentation to /usr/share/doc
######################################################################
	$(install_file) debian/changelog                $(DOCDIR)/changelog.Debian
	$(install_file) $(DEBDIR)/pkg/headers/README    $(DOCDIR)/debian.README
	$(install_file) $(config)  	                $(DOCDIR)/config-$(KERNELRELEASE)
	test ! -f debian/stamp/conf/vars                || \
          $(install_file) debian/stamp/conf/vars  	$(DOCDIR)/conf.vars
	$(install_file) CREDITS                         $(DOCDIR)/
	$(install_file) MAINTAINERS                     $(DOCDIR)/
	$(install_file) REPORTING-BUGS                  $(DOCDIR)/
	$(install_file) README                          $(DOCDIR)/
	if test -f README.Debian ; then                                                 \
           $(install_file) README.Debian                $(DOCDIR)/README.Debian.1st;\
	fi
	gzip -9qfr                                      $(DOCDIR)/
	echo "This was produced by kernel-package version: $(kpkg_version)." >         \
	                                                   $(DOCDIR)/Buildinfo
	chmod 0644                                         $(DOCDIR)/Buildinfo
	$(install_file) $(DEBDIR)/pkg/headers/copyright    $(DOCDIR)/copyright
#####################################################################
###   For linux, if modules are defined, install modules
######################################################################
ifneq ($(filter kfreebsd, $(DEB_HOST_ARCH_OS)):$(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),:)
  ifneq ($(strip $(KERNEL_ARCH)),um)
	$(restore_upstream_debianization)
	$(MAKE) $(EXTRAV_ARG) INSTALL_MOD_PATH=$(TMPTOP)$(DEBUGDIR)                   \
                $(CROSS_ARG) ARCH=$(KERNEL_ARCH) modules_install
	find $(TMPTOP)$(DEBUGDIR) -type f -name \*.ko |                               \
              while read file; do                                                     \
                $(OBJCOPY) --only-keep-debug $$file;                                     \
             done
	test ! -f System.map ||	 cp System.map			                      \
			$(TMPTOP)/$(DEBUGDIR)/lib/modules/$(KERNELRELEASE)/System.map;
	test ! -f System.map ||	 chmod 644			                      \
			$(TMPTOP)/$(DEBUGDIR)/lib/modules/$(KERNELRELEASE)/System.map;
#	test ! -L $(TMPTOP)$(DEBUGDIR)/lib/modules/$(KERNELRELEASE)/build  ||         \
#            rm -f $(TMPTOP)$(DEBUGDIR)/lib/modules/$(KERNELRELEASE)/build 
#	test ! -L $(TMPTOP)$(DEBUGDIR)/lib/modules/$(KERNELRELEASE)/source ||         \
#            rm -f $(TMPTOP)$(DEBUGDIR)/lib/modules/$(KERNELRELEASE)/source
  endif
	$(install_file) $(SRCTOP)/vmlinux                                             \
                       $(TMPTOP)/$(DEBUGDIR)/lib/modules/$(KERNELRELEASE)/vmlinux
######################################################################
###   INSTALL system.map and image
######################################################################
endif
	@echo done > $@

debian/stamp/binary/$(b_package): 
	$(REASON)
	@echo "This is kernel package version $(kpkg_version)."
	$(checkdir)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir debian/stamp/binary
	$(make_directory) $(TMPTOP)/DEBIAN
	$(eval $(deb_rule))
	dpkg-gencontrol -isp -DArchitecture=$(DEB_HOST_ARCH) -p$(package) \
                                          -P$(TMPTOP)/
	$(create_md5sum)                   $(TMPTOP)
	chown -R root:root                  $(TMPTOP)
	chmod -R og=rX                      $(TMPTOP)
	dpkg --build                        $(TMPTOP) $(DEB_DEST)
	@echo done > $@

debian/stamp/binary/pre-$(b_package): debian/stamp/install/$(b_package)
	$(REASON)
	$(checkdir)
	@echo "This is kernel package version $(kpkg_version)."
	@test -d debian/stamp/binary || mkdir debian/stamp/binary
	$(require_root)
	$(eval $(deb_rule))
	$(root_run_command) debian/stamp/binary/$(b_package)
	@echo done > $@


#Local variables:
#mode: makefile
#End:
