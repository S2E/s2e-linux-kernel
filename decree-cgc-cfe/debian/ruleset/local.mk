######################### -*- Mode: Makefile-Gmake -*- ########################
## local.mk<ruleset> --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Fri Oct 28 00:37:46 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 20:33:37 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 36
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
## 
## arch-tag: d047cfca-c918-4f47-b6e2-8c7df9778b26
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##
###############################################################################
testdir:
	$(checkdir)

$(eval $(which_debdir))
include $(DEBDIR)/ruleset/targets/common.mk

debian/stamp/pre-config-common: 
debian/stamp/pre-config-indep:  debian/stamp/conf/kernel-conf
configure: debian/stamp/conf/common
debian/stamp/pre-build-common:  sanity_check debian/stamp/conf/vars
debian/stamp/BUILD/$(i_package): debian/stamp/build/kernel

debian/stamp/INST/$(s_package): debian/stamp/install/$(s_package)
debian/stamp/INST/$(i_package): debian/stamp/install/$(i_package)
debian/stamp/INST/$(d_package): debian/stamp/install/$(d_package)
debian/stamp/INST/$(m_package): debian/stamp/install/$(m_package)
debian/stamp/INST/$(h_package): debian/stamp/install/$(h_package)
debian/stamp/INST/$(b_package): debian/stamp/install/$(b_package)

debian/stamp/BIN/$(s_package): debian/stamp/binary/pre-$(s_package)
debian/stamp/BIN/$(i_package): debian/stamp/binary/pre-$(i_package)
debian/stamp/BIN/$(d_package): debian/stamp/binary/pre-$(d_package)
debian/stamp/BIN/$(m_package): debian/stamp/binary/pre-$(m_package)
debian/stamp/BIN/$(h_package): debian/stamp/binary/pre-$(h_package)
debian/stamp/BIN/$(b_package): debian/stamp/binary/pre-$(b_package)


CLN-common:: real_stamp_clean

CLEAN/$(s_package)::
	test ! -d $(TMPTOP) || rm -rf $(TMPTOP)
CLEAN/$(i_package)::
	test ! -d $(TMPTOP) || rm -rf $(TMPTOP)
ifneq ($(strip $(KERNEL_ARCH)),um)
  ifeq  ($(strip $(CONFIG_XEN)),)
	test ! -d ./debian || test ! -e stamp-building ||             \
	sed -e 's/=V/$(KERNELRELEASE)/g' -e 's/=ST/$(INT_STEM)/g'     \
            -e 's/=K/$(kimage)/g'        -e 's@=A@$(DEB_HOST_ARCH)@g' \
            -e 's/=I/$(INITRD)/g'        -e 's,=D,$(IMAGEDIR),g'      \
            -e 's@=B@$(KERNEL_ARCH)@g'     \
          $(DEBDIR)/templates.in   > ./debian/templates.master
	test ! -d ./debian || test ! -e stamp-building || $(INSTALL_TEMPLATE)
  endif
endif

CLEAN/$(d_package)::
	test ! -d $(TMPTOP) || rm -rf $(TMPTOP)
CLEAN/$(m_package)::
	test ! -d $(TMPTOP) || rm -rf $(TMPTOP)
CLEAN/$(h_package)::
	test ! -d $(TMPTOP) || rm -rf $(TMPTOP)
CLEAN/$(b_package)::
	test ! -d $(TMPTOP) || rm -rf $(TMPTOP)

buildpackage: debian/stamp/build/buildpackage

# All of these are targets that insert themselves into the normal flow
# of policy specified targets, so they must hook themselves into the
# stream.            
debian:  debian/stamp/pre-config-common

# For the following, that means that we must make sure that the configure and 
# corresponding build targets are all done before the packages are built.
linux-source  linux_source  kernel-source  kernel_source:
	$(eval $(deb_rule))
	$(root_run_command) 	 debian/stamp/binary/pre-$(s_package)
linux-doc     linux_doc     kernel-doc     kernel_doc:
	$(eval $(deb_rule))
	$(root_run_command) 	 debian/stamp/binary/pre-$(d_package)
linux-headers linux_headers kernel-headers kernel_headers: debian/stamp/build/kernel
	$(eval $(deb_rule))
	$(root_run_command) 	 debian/stamp/binary/pre-$(h_package)
linux-image   linux_image   kernel-image   kernel_image:   debian/stamp/build/kernel 
	$(eval $(deb_rule))
	$(root_run_command) 	debian/stamp/binary/pre-$(i_package)
linux-debug   linux_debug   kernel-debug   kernel_debug:   debian/stamp/build/kernel 
	$(eval $(deb_rule))
	$(root_run_command) 	debian/stamp/binary/pre-$(b_package)
kernel-manual kernel_manual:  debian/stamp/build/kernel 
	$(eval $(deb_rule))
	$(root_run_command) 	 debian/stamp/binary/pre-$(m_package)
kernel-image-deb :  debian/stamp/build/kernel 
	$(eval $(deb_rule))
	$(root_run_command) 	debian/stamp/binary/pre-$(i_package)

libc-kheaders libc_kheaders: 
	$(REASON)
	@echo "This is kernel package version $(kpkg_version)."
	@echo This target is now obsolete.


$(eval $(which_debdir))
include $(DEBDIR)/ruleset/modules.mk

#Local variables:
#mode: makefile
#End:
