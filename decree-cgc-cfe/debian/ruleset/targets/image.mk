######################### -*- Mode: Makefile-Gmake -*- ########################
## image.mk ---
## Author	    : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com )
## Created On	    : Mon Oct 31 16:47:18 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 20:39:21 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count	    : 47
## Status	    : Unknown, Use with caution!
## HISTORY	    :
## Description	    : This file is responsible for creating the kernel-image packages
##
## arch-tag: ad956b4e-0c5a-4689-b643-7051cc8857cf
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

debian/stamp/install/$(i_package):
	$(REASON)
	@echo "This is kernel package version $(kpkg_version)."
	$(if $(subst $(strip $(UTS_RELEASE_VERSION)),,$(strip $(KERNELRELEASE))), \
		echo "The UTS Release version in $(UTS_RELEASE_HEADER)"; \
		echo "	   \"$(strip $(UTS_RELEASE_VERSION))\" "; \
		echo "does not match current version:"; \
		echo "	   \"$(strip $(KERNELRELEASE))\" "; \
		echo "Please correct this."; \
		exit 2,)
	$(eval $(which_debdir))
	rm -f -r ./$(TMPTOP) ./$(TMPTOP).deb
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	$(make_directory) $(TMPTOP)/etc/kernel/postinst.d $(TMPTOP)/etc/kernel/preinst.d \
	                  $(TMPTOP)/etc/kernel/postrm.d $(TMPTOP)/etc/kernel/prerm.d
	$(make_directory) $(TMPTOP)/$(IMAGEDIR)
	$(make_directory) $(DOCDIR)/examples
######################################################################
###   Install documentation into /usr/share/doc
######################################################################
	$(install_file) debian/changelog	$(DOCDIR)/changelog.Debian
ifeq ($(DEB_HOST_ARCH_OS), linux)
	$(install_file) Documentation/Changes $(DOCDIR)/
endif
ifeq ($(strip $(KERNEL_ARCH)),um)
	$(make_directory) $(UML_DIR)
	$(make_directory) $(MAN1DIR)
	$(install_file) $(DEBDIR)/docs/linux.1 $(MAN1DIR)/linux-$(KERNELRELEASE).1
	gzip -9fq			       $(MAN1DIR)/linux-$(KERNELRELEASE).1
endif
	test ! -d $(DEBDIR)/examples/ ||                                     \
          (cd $(DEBDIR); tar cf - examples | (cd $(DOCDIR);  umask 000; tar xsf -)); 
	$(install_file) $(DEBDIR)/pkg/image/README    $(DOCDIR)/debian.README
ifeq ($(strip $(KERNEL_ARCH)),um)
	$(install_file) $(config)	 $(DOCDIR)/config-$(KERNELRELEASE)
else
	$(install_file) $(config)	 $(TMPTOP)/$(IMAGEDIR)/config-$(KERNELRELEASE)
endif
	test ! -f debian/stamp/conf/vars                || \
          $(install_file) debian/stamp/conf/vars  	$(DOCDIR)/conf.vars
	echo "This was produced by kernel-package version $(kpkg_version)." > \
		   $(DOCDIR)/Buildinfo
	chmod 0644 $(DOCDIR)/Buildinfo
	test ! -f       debian/stamp/build/info || \
	 $(install_file) debian/stamp/build/info $(DOCDIR)/buildinfo
	if test -f README.Debian ; then \
	   $(install_file) README.Debian $(DOCDIR)/README.Debian.1st;\
	fi
	if test -f Debian.src.changelog; then		    \
	  $(install_file) Debian.src.changelog	$(DOCDIR)/; \
	fi
ifeq ($(strip $(HAVE_EXTRA_DOCS)),YES)
	$(install_file) $(extra_docs)		 $(DOCDIR)/
endif
	gzip -9qfr			  $(DOCDIR)
	$(install_file) $(DEBDIR)/pkg/image/copyright $(DOCDIR)/copyright
######################################################################
###   For linux, if modules are defined, install modules
######################################################################
ifneq ($(filter kfreebsd, $(DEB_HOST_ARCH_OS)):$(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),:)
  ifeq	($(DEB_HOST_ARCH_OS):$(strip $(HAVE_NEW_MODLIB)),linux:)
	$(old_mod_inst_cmds)
  else
# could have also said DEPMOD=/bin/true instead of moving files
    ifeq ($(DEB_HOST_ARCH_OS), linux)
      ifneq ($(strip $(KERNEL_CROSS)),)
	mv System.map System.precious
      endif
	$(restore_upstream_debianization)
	$(MAKE) $(EXTRAV_ARG) INSTALL_MOD_PATH=$(INSTALL_MOD_PATH)	              \
		INSTALL_FW_PATH=$(INSTALL_MOD_PATH)/lib/firmware/$(KERNELRELEASE)     \
		$(CROSS_ARG) ARCH=$(KERNEL_ARCH) INSTALL_MOD_STRIP=1 modules_install
	$(MAKE) $(EXTRAV_ARG) INSTALL_MOD_PATH=$(TMPTOP)$(DEBUGDIR)                   \
                $(CROSS_ARG) ARCH=$(KERNEL_ARCH) modules_install
	find $(TMPTOP)$(DEBUGDIR) -type f -name \*.ko |                               \
              while read file; do                                                     \
                origfile=`echo $$file | sed -e 's,$(DEBUGDIR),,g'`;                   \
                echo $(OBJCOPY) --only-keep-debug   $$file;                              \
                $(OBJCOPY) --only-keep-debug   $$file;                                   \
                echo $(OBJCOPY) --add-gnu-debuglink=$$file $$origfile;                   \
                $(OBJCOPY) --add-gnu-debuglink=$$file $$origfile;                        \
             done
	rm -rf $(TMPTOP)$(DEBUGDIR)
      ifneq ($(strip $(KERNEL_CROSS)),)
	mv System.precious System.map
      endif
      ifneq ($(strip ($CONFIG_LGUEST)),)
	test ! -f $(LGUEST_SUBDIR)/lguest ||			     \
	    $(install_file) $(LGUEST_SUBDIR)/lguest $(TMPTOP)/lib/modules/$(KERNELRELEASE)/lguest
	test ! -f $(TMPTOP)/lib/modules/$(KERNELRELEASE)/lguest ||		   \
	    chmod 755 $(TMPTOP)/lib/modules/$(KERNELRELEASE)/lguest
      endif
    else
      ifeq ($(DEB_HOST_ARCH_OS), kfreebsd)
	mkdir -p $(INSTALL_MOD_PATH)/boot/defaults
	install -o root -g root -m 644			      \
		$(architecture)/conf/GENERIC.hints	      \
		$(INSTALL_MOD_PATH)/boot/device.hints
	$(PMAKE) -C $(architecture)/compile/GENERIC install \
		    DESTDIR=$(INSTALL_MOD_PATH)
      endif
    endif
  endif
######################################################################
###   Now run depmod for the modules
######################################################################
	test ! -e $(TMPTOP)/lib/modules/$(KERNELRELEASE)/source ||			  \
	   mv $(TMPTOP)/lib/modules/$(KERNELRELEASE)/source ./debian/source-link
	test ! -e $(TMPTOP)/lib/modules/$(KERNELRELEASE)/build ||			  \
	   mv $(TMPTOP)/lib/modules/$(KERNELRELEASE)/build ./debian/build-link
  ifeq ($(strip $(KERNEL_ARCH)),um)
	-/sbin/depmod -q -FSystem.map -b $(TMPTOP) \
	   $(KERNELRELEASE)-$$(sed q $(UTS_RELEASE_HEADER) | sed s/\"//g | awk -F\- '{print $$2}')
# copy thse modules to the proper place for UML
	if [ -d $(INSTALL_MOD_PATH)/lib/modules/$(KERNELRELEASE) ] ; then    \
	  (cd $(INSTALL_MOD_PATH)/lib/modules/$(KERNELRELEASE);		     \
	   tar cf - . | (cd $(UML_DIR)/; umask 000; tar xsf -));       \
	fi
	rm -rf $(INSTALL_MOD_PATH)/lib
  else
	test ! -e ./debian/source-link ||					       \
	   mv ./debian/source-link $(TMPTOP)/lib/modules/$(KERNELRELEASE)/source
	test ! -e  ./debian/build-link ||					       \
	   mv  ./debian/build-link $(TMPTOP)/lib/modules/$(KERNELRELEASE)/build
    ifeq ($(DEB_BUILD_GNU_TYPE),$(DEB_HOST_GNU_TYPE))
	-/sbin/depmod -q -FSystem.map -b $(TMPTOP) $(KERNELRELEASE);
    endif
  endif
endif
######################################################################
###   INSTALL system.map and image
######################################################################
ifeq ($(strip $(KERNEL_ARCH)),um)
	cp $(kimagesrc) $(kimagedest)
else
  ifeq ($(strip $(HAVE_INST_PATH)),)
	test ! -f System.map ||	 cp System.map			       \
			$(TMPTOP)/$(IMAGEDIR)/System.map-$(KERNELRELEASE);
	test ! -f System.map ||	 chmod 644			       \
			$(TMPTOP)/$(IMAGEDIR)/System.map-$(KERNELRELEASE);
	cp $(kimagesrc) $(kimagedest)
  else
	$(restore_upstream_debianization)
	$(MAKE) $(EXTRAV_ARG) INSTALL_MOD_PATH=$(INSTALL_MOD_PATH)	     \
		INSTALL_FW_PATH=$(INSTALL_MOD_PATH)/lib/firmware/$(KERNELRELEASE)  \
		INSTALL_PATH=$(INT_IMAGE_DESTDIR) $(CROSS_ARG) $(KPKG_KBUILD_INSTALL_TARGET)
  endif
endif
ifeq ($(strip $(HAVE_COFF_IMAGE)),YES)
	cp $(coffsrc)	$(coffdest)
	chmod 644	$(coffdest)
endif
ifeq ($(strip $(int_install_vmlinux)),YES)
  ifneq ($(strip $(kelfimagesrc)),)
	cp $(kelfimagesrc) $(kelfimagedest)
	chmod 644 $(kelfimagedest)
  endif
endif
######################################################################
###   Post-processing
######################################################################
ifeq ($(strip $(NEED_DIRECT_GZIP_IMAGE)),YES)
	gzip -9fq $(kimagedest)
	test ! -f $(kimagedest).gz || mv -f $(kimagedest).gz $(kimagedest)
endif
# Set permissions on the image
ifeq ($(strip $(KERNEL_ARCH)),um)
	chmod 755 $(kimagedest);
  ifeq (,$(findstring nostrip,$(DEB_BUILD_OPTIONS)))
	strip --strip-unneeded --remove-section=.note --remove-section=.comment	 $(kimagedest);
  endif
else
	chmod 644 $(kimagedest);
endif
######################################################################
###   Hooks and information
######################################################################

	if test -d $(SRCTOP)/debian/image.d ; then			  \
	     TMPTOP=$(TMPTOP) version=$(KERNELRELEASE) IMAGE_TOP=$(TMPTOP)	\
		   run-parts --verbose $(SRCTOP)/debian/image.d ;	  \
	 fi
	if [ -x debian/post-install ]; then				  \
		TMPTOP=$(TMPTOP) STEM=$(INT_STEM) version=$(KERNELRELEASE)	\
		IMAGE_TOP=$(TMPTOP) debian/post-install;		  \
	fi
ifeq ($(strip $(NEED_IMAGE_POST_PROCESSING)),YES)
	$(DO_IMAGE_POST_PROCESSING)
endif
# For LKCD enabled kernels
	test ! -f Kerntypes ||	cp Kerntypes				       \
			$(TMPTOP)/$(IMAGEDIR)/Kerntypes-$(KERNELRELEASE)
	test ! -f Kerntypes ||	chmod 644				       \
			$(TMPTOP)/$(IMAGEDIR)/Kerntypes-$(KERNELRELEASE)
ifeq ($(strip $(delete_build_link)),YES)
	rm -f $(TMPTOP)/lib/modules/$(KERNELRELEASE)/build
endif
	@echo done > $@

debian/stamp/binary/$(i_package):
	$(REASON)
	$(checkdir)
	$(TESTROOT)
	@echo "This is kernel package version $(kpkg_version)."
	$(make_directory) $(TMPTOP)/DEBIAN
ifneq ($(strip $(KERNEL_ARCH)),um)
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g' \
	    -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
	    -e 's/=K/$(kimage)/g'   	     \
	    -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'	     \
	    -e 's@=A@$(DEB_HOST_ARCH)@g'   \
	    -e 's@=B@$(KERNEL_ARCH)@g'     \
	  $(DEBDIR)/pkg/image/postinst > $(TMPTOP)/DEBIAN/postinst
	chmod 755 $(TMPTOP)/DEBIAN/postinst
	sed -e 's/=V/$(KERNELRELEASE)/g'	   -e 's/=IB/$(link_in_boot)/g' \
	    -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
	    -e 's/=K/$(kimage)/g'   	     \
	    -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'	     \
	    -e 's@=A@$(DEB_HOST_ARCH)@g'   \
	    -e 's@=B@$(KERNEL_ARCH)@g'    \
	 $(DEBDIR)/pkg/image/config > $(TMPTOP)/DEBIAN/config
	chmod 755 $(TMPTOP)/DEBIAN/config
	sed -e 's/=V/$(KERNELRELEASE)/g'	   -e 's/=IB/$(link_in_boot)/g' \
	    -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
	    -e 's/=K/$(kimage)/g'  	     \
	    -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'	     \
	    -e 's/=MD/$(initrddep)/g'				     \
	    -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
	    -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
	    -e 's/=S/$(no_symlink)/g' -e 's@=B@$(KERNEL_ARCH)@g'     \
	 $(DEBDIR)/pkg/image/postrm > $(TMPTOP)/DEBIAN/postrm
	chmod 755 $(TMPTOP)/DEBIAN/postrm
	sed -e 's/=V/$(KERNELRELEASE)/g'	   -e 's/=IB/$(link_in_boot)/g'	   \
	    -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
	    -e 's/=K/$(kimage)/g'  	     \
	    -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'	     \
	    -e 's/=MD/$(initrddep)/g'				     \
	    -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
	    -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
	    -e 's/=S/$(no_symlink)/g' -e 's@=B@$(KERNEL_ARCH)@g'     \
	 $(DEBDIR)/pkg/image/preinst > $(TMPTOP)/DEBIAN/preinst
	chmod 755 $(TMPTOP)/DEBIAN/preinst
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'    \
	    -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
	    -e 's/=K/$(kimage)/g'  	     \
	    -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'	     \
	    -e 's/=MD/$(initrddep)/g'				     \
	    -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
	    -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
	    -e 's/=S/$(no_symlink)/g' -e 's@=B@$(KERNEL_ARCH)@g'     \
	 $(DEBDIR)/pkg/image/prerm > $(TMPTOP)/DEBIAN/prerm
	chmod 755 $(TMPTOP)/DEBIAN/prerm
	$(INSTALL_TEMPLATE)
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'    \
	    -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
	    -e 's/=K/$(kimage)/g'           \
	    -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
	    -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
	    -e 's/=MD/$(initrddep)/g'                                \
	    -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
	    -e 's/=S/$(no_symlink)/g' -e 's@=B@$(KERNEL_ARCH)@g'     \
	 $(DEBDIR)/templates.l10n   > ./debian/templates.master
	$(install_file) ./debian/templates.master $(TMPTOP)/DEBIAN/templates
else
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'    \
	    -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
	    -e 's/=K/$(kimage)/g'       \
	    -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'	     \
	    -e 's/=MD/$(initrddep)/g'				     \
	    -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
	    -e 's@=M@$(MKIMAGE)@g'    -e 's@=B@$(KERNEL_ARCH)@g'     \
	    -e 's/=S/$(no_symlink)/g' -e 's/=OF/$(AM_OFFICIAL)/g'    \
	  $(DEBDIR)/pkg/virtual/um/postinst > $(TMPTOP)/DEBIAN/postinst
	chmod 755 $(TMPTOP)/DEBIAN/postinst
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'    \
	    -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
	    -e 's/=K/$(kimage)/g'   	     \
	    -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'	     \
	    -e 's/=MD/$(initrddep)/g'				     \
	    -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
	    -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
	    -e 's/=S/$(no_symlink)/g' -e 's@=B@$(KERNEL_ARCH)@g'     \
	  $(DEBDIR)/pkg/virtual/um/prerm > $(TMPTOP)/DEBIAN/prerm
	chmod 755 $(TMPTOP)/DEBIAN/prerm
endif
ifneq ($(strip $(image_clean_hook)),)
	(cd $(TMPTOP); test -x $(image_clean_hook) && $(image_clean_hook))
endif
	dpkg-gencontrol -DArchitecture=$(DEB_HOST_ARCH) -isp	     \
			-p$(package) -P$(TMPTOP)/
	$(create_md5sum)	       $(TMPTOP)
	chmod -R og=rX		       $(TMPTOP)
	chown -R root:root	       $(TMPTOP)
	dpkg --build		       $(TMPTOP) $(DEB_DEST)
ifeq ($(strip $(do_clean)),YES)
# just to be sure we are not nuking ./debian
	$(MAKE) $(EXTRAV_ARG) $(FLAV_ARG) $(CROSS_ARG) ARCH=$(KERNEL_ARCH) clean
  ifneq ($(LGUEST_SUBDIR),)
	$(MAKE) $(EXTRAV_ARG) $(FLAV_ARG) $(CROSS_ARG) ARCH=$(KERNEL_ARCH)	\
	       -C $(LGUEST_SUBDIR) clean
  endif
	rm -f stamp-$(package)
endif
	@echo done > $@

debian/stamp/binary/pre-$(i_package): debian/stamp/install/$(i_package)
	$(REASON)
	$(checkdir)
	@echo "This is kernel package version $(kpkg_version)."
	@test -d debian/stamp/binary || mkdir debian/stamp/binary
	$(require_root)
	$(eval $(deb_rule))
	$(root_run_command) debian/stamp/binary/$(i_package)
	@echo done > $@



#Local variables:
#mode: makefile
#End:
