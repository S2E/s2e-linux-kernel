######################### -*- Mode: Makefile-Gmake -*- ########################
## headers.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 16:23:51 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 22:09:12 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 28
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : This file is responsible for creating the kernel-headers packages 
## 
## arch-tag: 2280e193-fbb3-4990-ac8c-d0504ee9bab5
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

LINK_ARCH=$(KERNEL_ARCH)
ifneq ($(filter i386 x86_64,$(KERNEL_ARCH)),)
	LINK_ARCH=x86
endif
INSTALL_HDR_PATH=$(SRCDIR)

debian/stamp/install/$(h_package):
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
	$(make_directory) $(SRCDIR)
	$(make_directory) $(DOCDIR)/examples
	$(make_directory) $(TMPTOP)/etc/kernel/header_postinst.d
	$(make_directory) $(TMPTOP)/etc/kernel/header_preinst.d
	$(make_directory) $(TMPTOP)/etc/kernel/header_postrm.d
	$(make_directory) $(TMPTOP)/etc/kernel/header_prerm.d
	$(make_directory) $(SRCDIR)/arch/$(LINK_ARCH)
	$(make_directory) $(SRCDIR)/arch/$(LINK_ARCH)/kernel/
	$(eval $(which_debdir))
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
######################################################################
#### 
######################################################################
	$(install_file) Makefile                           $(SRCDIR)
	test ! -e Rules.make || $(install_file) Rules.make $(SRCDIR)
	test ! -e .kernelrelease || $(install_file) .kernelrelease $(SRCDIR)
	test ! -e arch/$(LINK_ARCH)/Makefile     ||                             \
                                $(install_file) arch/$(LINK_ARCH)/Makefile      \
                                                     $(SRCDIR)/arch/$(LINK_ARCH)
	test ! -e arch/$(LINK_ARCH)/Makefile.cpu ||                             \
                                $(install_file) arch/$(LINK_ARCH)/Makefile.cpu  \
                                                     $(SRCDIR)/arch/$(LINK_ARCH)
	test ! -e arch/$(LINK_ARCH)/Makefile_32.cpu ||                             \
                                $(install_file) arch/$(LINK_ARCH)/Makefile_32.cpu  \
                                                     $(SRCDIR)/arch/$(LINK_ARCH)
	test ! -e Rules.make     || $(install_file) Rules.make     $(SRCDIR)
	test ! -e Module.symvers || $(install_file) Module.symvers $(SRCDIR)
  ifneq ($(strip $(int_follow_symlinks_in_src)),)
	-tar cfh - include       |   (cd $(SRCDIR); umask 000; tar xsf -)
	-tar cfh - scripts       |   (cd $(SRCDIR); umask 000; tar xsf -)
	test ! -e arch/powerpc/lib/crtsavres.o ||                                  \
          tar cfh - arch/powerpc/lib/crtsavres.o | (cd $(SRCDIR); umask 000; tar xsf -)
	(cd $(SRCDIR)/include;   rm -rf asm; ln -s asm-$(LINK_ARCH) asm)
	find . -path './scripts/*'   -prune -o -path './Documentation/*' -prune -o  \
               -path './debian/*'    -prune -o -type f                              \
               \( -name Makefile -o  -name 'Kconfig*' \) -print  |                  \
                  cpio -pdL --preserve-modification-time $(SRCDIR);
	test ! -d arch/$(LINK_ARCH)/include || find arch/$(LINK_ARCH)/include   \
               -print | cpio -pdL --preserve-modification-time $(SRCDIR);
	test ! -d arch/$(LINK_ARCH)/scripts || find arch/$(LINK_ARCH)/scripts   \
               -print | cpio -pdL --preserve-modification-time $(SRCDIR);
  else
	-tar cf - include |        (cd $(SRCDIR); umask 000; tar xsf -)
	-tar cf - scripts |        (cd $(SRCDIR); umask 000; tar xsf -)
	test ! -e arch/powerpc/lib/crtsavres.o ||                                  \
          tar cfh - arch/powerpc/lib/crtsavres.o | (cd $(SRCDIR); umask 000; tar xsf -)
	(cd       $(SRCDIR)/include; rm -f asm; ln -s asm-$(LINK_ARCH) asm)
	find . -path './scripts/*' -prune -o -path './Documentation/*' -prune -o  \
               -path './debian/*'  -prune -o -type f                              \
               \( -name Makefile -o -name 'Kconfig*' \) -print |                  \
                  cpio -pd --preserve-modification-time $(SRCDIR);
	test ! -d arch/$(LINK_ARCH)/include || find arch/$(LINK_ARCH)/include \
               -print | cpio -pd --preserve-modification-time $(SRCDIR);
	test ! -d arch/$(LINK_ARCH)/scripts || find arch/$(LINK_ARCH)/scripts \
               -print | cpio -pd --preserve-modification-time $(SRCDIR);
  endif
  ifeq ($(strip $(KERNEL_ARCH)),um)
	test ! -e arch/$(LINK_ARCH)/Makefile.cpu ||                              \
         $(install_file) arch/$(LINK_ARCH)/Makefile.cpu                          \
               $(SRCDIR)/arch/$(LINK_ARCH)/
	test ! -e arch/$(LINK_ARCH)/Makefile_32.cpu ||                              \
         $(install_file) arch/$(LINK_ARCH)/Makefile_32.cpu                          \
               $(SRCDIR)/arch/$(LINK_ARCH)/
	test ! -s $(SRCDIR)/arch/um || $(make_directory) $(SRCDIR)/arch/um
	$(install_file) arch/um/Makefile* $(SRCDIR)/arch/um/
	test ! -e arch/um/Kconfig.arch ||                                           \
         $(install_file) arch/um/Kconfig.arch $(SRCDIR)/arch/um/
  endif
	test ! -e arch/$(LINK_ARCH)/kernel/asm-offsets.s ||                     \
           $(install_file)               arch/$(LINK_ARCH)/kernel/asm-offsets.s \
                           $(SRCDIR)/arch/$(LINK_ARCH)/kernel/asm-offsets.s
	for file in $(localversion_files) dummy; do                               \
          test ! -e $$file || $(install_file) $$file $(SRCDIR);                   \
        done
	(cd $(SRCDIR); find . -type d -name .git -print0       | xargs -0r rm -rf {} \; )
	(cd $(SRCDIR); find . -type f -name .gitmodule -print0 | xargs -0r rm -f  {} \; )
######################################################################
#### Now add in Debian specific informational stuff
######################################################################
	$(install_file) .config  	        $(SRCDIR)/.config
	echo $(debian)                    > $(SRCDIR)/$(INT_STEM)-headers.revision
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'   \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=K/$(kimage)/g'      \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=B@$(LINK_ARCH)@g'    \
            $(DEBDIR)/pkg/headers/create_link  > $(DOCDIR)/examples/create_link
	test -d $(SRCDIR)/debian || mkdir $(SRCDIR)/debian
	for file in $(DEBIAN_FILES) control changelog; do                    \
            cp -f  $(DEBDIR)/$$file $(SRCDIR)/debian/;                       \
        done
	for dir  in $(DEBIAN_DIRS);  do                                      \
          cp -af $(DEBDIR)/$$dir  $(SRCDIR)/debian/;                         \
        done
######################################################################
#### Now strip any elf objects in the header package
######################################################################
#         $(DEBDIR)/pkg/headers/create_link  >                        \
#                $(TMPTOP)/etc/kernel/postinst.d/create_link-$(KERNELRELEASE)
ifeq (,$(findstring nostrip,$(DEB_BUILD_OPTIONS)))
	test ! -d $(SRCDIR)/scripts || find $(SRCDIR)/scripts -type f | while read i; do  \
           if file -b $$i | egrep -q "^ELF.*executable"; then                             \
             strip --strip-all --remove-section=.comment --remove-section=.note $$i;      \
           fi;                                                                            \
         done
	test ! -d $(SRCDIR)/scripts || find $(SRCDIR)/scripts -type f | while read i; do  \
           if file -b $$i | egrep -q "^ELF.*shared object"; then                          \
             strip --strip-unneeded --remove-section=.comment --remove-section=.note $$i; \
           fi;                                                                            \
         done
endif
	@echo done > $@

debian/stamp/binary/$(h_package): 
	$(REASON)
	@echo "This is kernel package version $(kpkg_version)."
	$(checkdir)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir debian/stamp/binary
	$(make_directory) $(TMPTOP)/DEBIAN
	$(eval $(deb_rule))
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'   \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
            -e 's/=K/$(kimage)/g'          \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=P/$(package)/g'         \
            -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=B@$(LINK_ARCH)@g'    \
		$(DEBDIR)/pkg/headers/postinst >        $(TMPTOP)/DEBIAN/preinst
	chmod 755                                       $(TMPTOP)/DEBIAN/preinst
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'   \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
            -e 's/=K/$(kimage)/g'          \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=P/$(package)/g'         \
            -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=B@$(LINK_ARCH)@g'    \
		$(DEBDIR)/pkg/headers/postinst >        $(TMPTOP)/DEBIAN/postinst
	chmod 755                                       $(TMPTOP)/DEBIAN/postinst
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'   \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
            -e 's/=K/$(kimage)/g'          \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=P/$(package)/g'         \
            -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=B@$(LINK_ARCH)@g'    \
		$(DEBDIR)/pkg/headers/postinst >        $(TMPTOP)/DEBIAN/prerm
	chmod 755                                       $(TMPTOP)/DEBIAN/prerm
	sed -e 's/=V/$(KERNELRELEASE)/g'    -e 's/=IB/$(link_in_boot)/g'   \
            -e 's/=ST/$(INT_STEM)/g'  -e 's/=R/$(reverse_symlink)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
            -e 's/=K/$(kimage)/g'      \
            -e 's/=I/$(INITRD)/g'     -e 's,=D,$(IMAGEDIR),g'        \
            -e 's/=P/$(package)/g'         \
            -e 's@=A@$(DEB_HOST_ARCH)@g'   \
            -e 's@=B@$(LINK_ARCH)@g'    \
		$(DEBDIR)/pkg/headers/postinst >        $(TMPTOP)/DEBIAN/postrm
	chmod 755                                       $(TMPTOP)/DEBIAN/postrm
#	echo "/etc/kernel/postinst.d/create_link-$(KERNELRELEASE)" > $(TMPTOP)/DEBIAN/conffiles
	cp -pf debian/control debian/control.dist
ifneq ($(strip $(header_clean_hook)),)
	(cd $(SRCDIR); test -x $(header_clean_hook) && $(header_clean_hook))
endif
	k=`find $(TMPTOP) -type f | ( while read i; do                    \
          if file -b $$i | egrep -q "^ELF.*executable.*dynamically linked" ; then \
            j="$$j $$i";                                                  \
           fi;                                                            \
        done; echo $$j; )`; test -z "$$k" || dpkg-shlibdeps $$k;          \
        echo "Elf Files: $$K" >              $(DOCDIR)/elffiles;          \
        test -n "$$k" || perl -pli~ -e 's/\$$\{shlibs:Depends\}\,?//g' debian/control
	test ! -e debian/control~ || rm -f debian/control~
	dpkg-gencontrol -isp -DArchitecture=$(DEB_HOST_ARCH) -p$(package) \
                                          -P$(TMPTOP)/
	$(create_md5sum)                   $(TMPTOP)
	chown -R root:root                  $(TMPTOP)
	chmod -R og=rX                      $(TMPTOP)
	dpkg --build                        $(TMPTOP) $(DEB_DEST)
	cp -pf debian/control.dist          debian/control
	@echo done > $@

debian/stamp/binary/pre-$(h_package): debian/stamp/install/$(h_package)
	$(REASON)
	$(checkdir)
	@echo "This is kernel package version $(kpkg_version)."
	@test -d debian/stamp/binary || mkdir debian/stamp/binary
	$(require_root)
	$(eval $(deb_rule))
	$(root_run_command) debian/stamp/binary/$(h_package)
	@echo done > $@


#Local variables:
#mode: makefile
#End:
