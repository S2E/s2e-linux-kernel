######################### -*- Mode: Makefile-Gmake -*- ########################
## source.mk ---
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com )
## Created On       : Mon Oct 31 13:55:32 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 22:08:58 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 14
## Status           : Unknown, Use with caution!
## HISTORY          :
## Description      : This file is responsible forcreating the kernel-source packages
##
## arch-tag: 1a7fd804-128f-4f9d-9e3d-ce6bdb731823
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


debian/stamp/install/$(s_package):
	$(REASON)
	@echo "This is kernel package version $(kpkg_version)."
	rm -rf $(TMPTOP)
	@test -d debian/stamp/install || mkdir debian/stamp/install
	$(make_directory) $(SRCDIR)
	$(make_directory) $(DOCDIR)
	$(make_directory) $(TMPTOP)/etc/kernel/src_postinst.d
	$(make_directory) $(TMPTOP)/etc/kernel/src_preinst.d
	$(make_directory) $(TMPTOP)/etc/kernel/src_postrm.d
	$(make_directory) $(TMPTOP)/etc/kernel/src_prerm.d
	$(eval $(which_debdir))
######################################################################
#### Add documentation to /usr/share/doc
######################################################################
	$(install_file) README                         $(DOCDIR)/README
	$(install_file) debian/changelog               $(DOCDIR)/changelog.Debian
	$(install_file) $(DEBDIR)/docs/README          $(DOCDIR)/debian.README
	$(install_file) $(DEBDIR)/docs/README.modules  $(DOCDIR)/
	$(install_file) $(DEBDIR)/docs/Rationale       $(DOCDIR)/
	$(install_file) $(DEBDIR)/examples/sample.module.control               \
                                                       $(DOCDIR)/
	if test -f README.Debian ; then                                                 \
           $(install_file) README.Debian                $(DOCDIR)/README.Debian.1st;\
	fi
	gzip -9qfr                                     $(DOCDIR)/
	$(install_file) $(DEBDIR)/pkg/source/copyright $(DOCDIR)/copyright
	echo "This was produced by kernel-package version $(kpkg_version)." >  \
	                                               $(DOCDIR)/Buildinfo
######################################################################
####
######################################################################
ifneq ($(strip $(int_follow_symlinks_in_src)),)
	-tar cfh - $$(echo * | sed -e 's/ debian//g' -e 's/\.deb//g' ) |       \
	(cd $(SRCDIR); umask 000; tar xpsf -)
	(cd $(SRCDIR)/include; rm -rf asm ; )
else
	-tar cf - $$(echo * | sed -e 's/ debian//g' -e 's/\.deb//g' ) |         \
	(cd $(SRCDIR); umask 000; tar xspf -)
	(cd $(SRCDIR)/include; rm -f asm ; )
endif
	$(install_file) debian/changelog      $(SRCDIR)/Debian.src.changelog
	(cd $(SRCDIR);                                                          \
            $(MAKE) $(EXTRAV_ARG) $(CROSS_ARG) ARCH=$(KERNEL_ARCH) distclean)
	(cd $(SRCDIR);         rm -f stamp-building $(STAMPS_TO_CLEAN))
	(cd $(SRCDIR);                                                          \
         [ ! -d scripts/cramfs ]   || make -C scripts/cramfs distclean ; )
	sed -e 's/=V/$(KERNELRELEASE)/g' -e 's/=A/$(DEB_HOST_ARCH)/g'           \
             -e 's/=ST/$(INT_STEM)/g'  -e 's/=B/$(KERNEL_ARCH)/g'               \
                 $(DEBDIR)/pkg/source/README >  $(SRCDIR)/README.Debian ;
	if test -f README.Debian ; then                                         \
           $(install_file) README.Debian        $(DOCDIR)/README.Debian.1st;    \
	   gzip -9qf                            $(DOCDIR)/README.Debian.1st;    \
	fi
	test -d $(SRCDIR)/debian || mkdir $(SRCDIR)/debian
	for file in $(DEBIAN_FILES) control changelog; do                    \
            cp -f  $(DEBDIR)/$$file $(SRCDIR)/debian/;                       \
        done
	for dir  in $(DEBIAN_DIRS);  do                                      \
          cp -af $(DEBDIR)/$$dir  $(SRCDIR)/debian/;                         \
        done
	(cd $(SRCDIR); find . -type d -name .arch-ids -print0  | xargs -0r rm -rf {} \; )
	(cd $(SRCDIR); find . -type d -name .git -print0       | xargs -0r rm -rf {} \; )
	(cd $(SRCDIR); find . -type f -name .gitmodule -print0 | xargs -0r rm -f  {} \; )
ifneq ($(strip $(source_clean_hook)),)
	(cd $(SRCDIR); test -x $(source_clean_hook) && $(source_clean_hook))
endif
	(cd $(SRCDIR) && cd .. &&                                            \
           tar $(TAR_COMPRESSION) -cf $(package).tar.$(TAR_SUFFIX) $(package) && \
             rm -rf $(package);)
	@echo done > $@

debian/stamp/binary/$(s_package):
	$(REASON)
	$(checkdir)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir debian/stamp/binary
	@echo "This is kernel package version $(kpkg_version)."
	$(eval $(which_debdir))
	$(make_directory) $(TMPTOP)/DEBIAN
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'   \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
            -e 's/=K/$(kimage)/g'           \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=MD/$(initrddep)/g' -e 's/=P/$(package)/g'         \
            -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
            -e 's/=S/$(no_symlink)/g'  -e 's@=B@$(LINK_ARCH)@g'    \
		$(DEBDIR)/pkg/source/postinst >        $(TMPTOP)/DEBIAN/preinst
	chmod 755                                       $(TMPTOP)/DEBIAN/preinst
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'   \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
            -e 's/=K/$(kimage)/g'          \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=MD/$(initrddep)/g' -e 's/=P/$(package)/g'         \
            -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
            -e 's/=S/$(no_symlink)/g'  -e 's@=B@$(LINK_ARCH)@g'    \
		$(DEBDIR)/pkg/source/postinst >        $(TMPTOP)/DEBIAN/postinst
	chmod 755                                       $(TMPTOP)/DEBIAN/postinst
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'   \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
            -e 's/=K/$(kimage)/g'          \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=MD/$(initrddep)/g' -e 's/=P/$(package)/g'         \
            -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
            -e 's/=S/$(no_symlink)/g'  -e 's@=B@$(LINK_ARCH)@g'    \
		$(DEBDIR)/pkg/source/postinst >        $(TMPTOP)/DEBIAN/prerm
	chmod 755                                       $(TMPTOP)/DEBIAN/prerm
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'   \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
            -e 's/=K/$(kimage)/g'            \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=MD/$(initrddep)/g' -e 's/=P/$(package)/g'         \
            -e 's@=MK@$(initrdcmd)@g' -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=M@$(MKIMAGE)@g'    -e 's/=OF/$(AM_OFFICIAL)/g'    \
            -e 's/=S/$(no_symlink)/g'  -e 's@=B@$(LINK_ARCH)@g'    \
		$(DEBDIR)/pkg/source/postinst >        $(TMPTOP)/DEBIAN/postrm
	chmod 755                                       $(TMPTOP)/DEBIAN/postrm
	chmod -R og=rX                               $(TMPTOP)
	chown -R root:root                           $(TMPTOP)
	dpkg-gencontrol -isp -p$(package)          -P$(TMPTOP)/
	$(create_md5sum)                            $(TMPTOP)
	chmod -R og=rX                               $(TMPTOP)
	chown -R root:root                           $(TMPTOP)
	dpkg --build                                 $(TMPTOP) $(DEB_DEST)
	@echo done > $@


debian/stamp/binary/pre-$(s_package): debian/stamp/install/$(s_package)
	$(REASON)
	$(checkdir)
	@echo "This is kernel package version $(kpkg_version)."
	@test -d debian/stamp/binary || mkdir debian/stamp/binary
	$(require_root)
	$(eval $(deb_rule))
	$(root_run_command) debian/stamp/binary/$(s_package)
	@echo done > $@



#Local variables:
#mode: makefile
#End:
