######################### -*- Mode: Makefile-Gmake -*- ########################
## doc.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 16:38:08 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 14:21:09 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 9
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : This file is responsible for creating the kernel-doc packages
## 
## arch-tag: ecb720c6-075d-4641-adb4-55f313499e8e
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

debian/stamp/install/$(d_package): 
	$(REASON)
	@echo "This is kernel package version $(kpkg_version)."
	@test -d debian/stamp/install || mkdir debian/stamp/install
	$(eval $(which_debdir))
	rm -rf            $(TMPTOP)
	$(make_directory) $(DOCDIR)
	$(make_directory) $(MAN9DIR)
	$(make_directory) $(TMP_MAN)
	$(make_directory) $(TMPTOP)/etc/kernel/doc_postinst.d
	$(make_directory) $(TMPTOP)/etc/kernel/doc_preinst.d
	$(make_directory) $(TMPTOP)/etc/kernel/doc_postrm.d
	$(make_directory) $(TMPTOP)/etc/kernel/doc_prerm.d
######################################################################
#### Add documentation to /usr/share/doc
######################################################################
	$(install_file) debian/changelog          $(DOCDIR)/changelog.Debian
	$(install_file) $(DEBDIR)/pkg/doc/README  $(DOCDIR)/README.Debian
	echo "This was produced by kernel-package version $(kpkg_version)." > \
	           $(DOCDIR)/Buildinfo
	chmod 0644 $(DOCDIR)/Buildinfo
	if test -f README.Debian ; then \
           $(install_file) README.Debian $(DOCDIR)/README.Debian.1st;\
	fi
ifneq ($(strip $(shell if [ -x /usr/bin/db2html ]; then echo YSE; fi)),)
	$(MAKE)  mandocs htmldocs
endif
	-tar cf - Documentation | (cd $(DOCDIR); umask 000; tar xsf -)
ifneq ($(LGUEST_SUBDIR),)
	rm -f $(DOCDIR)/$(LGUEST_SUBDIR)/lguest $(DOCDIR)/$(LGUEST_SUBDIR)/lguest.lds
endif
	test ! -d $(DOCDIR)/Documentation/DocBook ||                            \
	   rm -f   $(DOCDIR)/Documentation/DocBook/Makefile                     \
	           $(DOCDIR)/Documentation/DocBook/*.sgml                       \
	           $(DOCDIR)/Documentation/DocBook/*.tmpl                       \
	           $(DOCDIR)/Documentation/DocBook/.*.sgml.cmd
	test ! -d $(DOCDIR)/Documentation/DocBook ||                                  \
	   find $(DOCDIR)/Documentation/DocBook -name "*.9"    -exec mv {} $(TMP_MAN) \;
	test ! -d $(DOCDIR)/Documentation/DocBook ||                                  \
	   find $(DOCDIR)/Documentation/DocBook -name "*.9.gz" -exec mv {} $(TMP_MAN) \;
	test ! -d $(DOCDIR)/Documentation/DocBook/man ||                       \
	   rm -rf $(DOCDIR)/Documentation/DocBook/man
	test ! -d $(DOCDIR)/Documentation/DocBook ||                           \
	   mv $(DOCDIR)/Documentation/DocBook $(DOCDIR)/html
######################################################################
#### 
######################################################################
		find -name Kconfig -print0 | xargs -0r cat | \
		     (umask 000 ; cat > $(DOCDIR)/Kconfig.collected)
# removing if empty should be faster than running find twice
	if ! test -s $(DOCDIR)/Kconfig.collected ; then \
	    rm -f $(DOCDIR)/Kconfig.collected ;          \
         fi
ifneq ($(strip $(doc_clean_hook)),)
	(cd $(DOCDIR);              \
               test -x $(doc_clean_hook) && $(doc_clean_hook))
endif
	-gzip -9qfr $(DOCDIR)
	-find $(DOCDIR)      -type f -name \*.gz -perm +111 -exec gunzip {} \;
	-find $(DOCDIR)/html -type f -name \*.gz            -exec gunzip {} \;
	find   $(DOCDIR)/              -type d -exec chmod 0755 {} \;
	$(install_file) $(DEBDIR)/pkg/doc/copyright $(DOCDIR)/copyright
	-rmdir   $(MAN9DIR)
	-rmdir   $(MANDIR)
	@echo done > $@

debian/stamp/binary/$(d_package): 
	$(REASON)
	$(checkdir)
	$(TESTROOT)
	@echo "This is kernel package version $(kpkg_version)."
	@test -d debian/stamp/binary || mkdir debian/stamp/binary
	$(make_directory) $(TMPTOP)/DEBIAN
	$(eval $(deb_rule))
	sed -e 's/=P/$(package)/g' -e 's/=V/$(KERNELRELEASE)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
		$(DEBDIR)/pkg/doc/postinst >        $(TMPTOP)/DEBIAN/preinst
	chmod 755                                   $(TMPTOP)/DEBIAN/preinst
	sed -e 's/=P/$(package)/g' -e 's/=V/$(KERNELRELEASE)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
		$(DEBDIR)/pkg/doc/postinst >        $(TMPTOP)/DEBIAN/postinst
	chmod 755                                   $(TMPTOP)/DEBIAN/postinst
	sed -e 's/=P/$(package)/g' -e 's/=V/$(KERNELRELEASE)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
		$(DEBDIR)/pkg/doc/postinst >        $(TMPTOP)/DEBIAN/prerm
	chmod 755                                   $(TMPTOP)/DEBIAN/prerm
	sed -e 's/=P/$(package)/g' -e 's/=V/$(KERNELRELEASE)/g' \
            -e 's/=KPV/$(kpkg_version)/g'                       \
		$(DEBDIR)/pkg/doc/postinst >        $(TMPTOP)/DEBIAN/postrm
	chmod 755                                   $(TMPTOP)/DEBIAN/postrm
	dpkg-gencontrol -isp -p$(package)         -P$(TMPTOP)/
	$(create_md5sum)                           $(TMPTOP)
	chmod -R og=rX                              $(TMPTOP)
	chown -R root:root                          $(TMPTOP)
	dpkg --build                                $(TMPTOP) $(DEB_DEST)
	@echo done > $@

debian/stamp/binary/pre-$(d_package): debian/stamp/install/$(d_package)
	$(REASON)
	$(checkdir)
	@echo "This is kernel package version $(kpkg_version)."
	@test -d debian/stamp/binary || mkdir debian/stamp/binary
	$(require_root)
	$(eval $(deb_rule))
	$(root_run_command) debian/stamp/binary/$(d_package)
	@echo done > $@



#Local variables:
#mode: makefile
#End:
