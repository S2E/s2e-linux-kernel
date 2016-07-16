######################### -*- Mode: Makefile-Gmake -*- ########################
## modules.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 10:37:44 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Oct  9 15:11:12 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 14
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : This file contains the targets responsible for third party
##                    module interaction. 
##
## arch-tag: 0c2c8a37-03da-48a2-9d87-27330c559025
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

define old_mod_inst_cmds
        @(                                                           \
        MODLIB=$(INSTALL_MOD_PATH)/lib/modules/$(KERNELRELEASE);           \
        cd modules;                                                  \
        MODULES="";                                                  \
        inst_mod() { These="$$(cat $$1)"; MODULES="$$MODULES $$These"; \
                mkdir -p $$MODLIB/$$2; cp $$These $$MODLIB/$$2;               \
                echo Installing modules under $$MODLIB/$$2; \
        }; \
                                                                               \
	if [ -f BLOCK_MODULES    ]; then inst_mod BLOCK_MODULES    block; fi; \
	if [ -f NET_MODULES      ]; then inst_mod NET_MODULES      net;   fi; \
	if [ -f IPV4_MODULES     ]; then inst_mod IPV4_MODULES     ipv4;  fi; \
	if [ -f IPV6_MODULES     ]; then inst_mod IPV6_MODULES     ipv6;  fi; \
         if [ -f ATM_MODULES      ]; then inst_mod ATM_MODULES      atm;   fi; \
	if [ -f SCSI_MODULES     ]; then inst_mod SCSI_MODULES     scsi;  fi; \
	if [ -f FS_MODULES       ]; then inst_mod FS_MODULES       fs;    fi; \
	if [ -f NLS_MODULES      ]; then inst_mod NLS_MODULES      fs;    fi;        \
	if [ -f CDROM_MODULES    ]; then inst_mod CDROM_MODULES    cdrom; fi;        \
	if [ -f HAM_MODULES      ]; then inst_mod HAM_MODULES      net;   fi;        \
	if [ -f SOUND_MODULES    ]; then inst_mod SOUND_MODULES    sound; fi;        \
	if [ -f VIDEO_MODULES    ]; then inst_mod VIDEO_MODULES    video; fi;        \
	if [ -f FC4_MODULES      ]; then inst_mod FC4_MODULES      fc4;   fi;        \
	if [ -f IRDA_MODULES     ]; then inst_mod IRDA_MODULES     net;   fi;        \
         if [ -f USB_MODULES      ]; then inst_mod USB_MODULES      usb;   fi;        \
         if [ -f SK98LIN_MODULES  ]; then inst_mod SK98LIN_MODULES  net;   fi;        \
         if [ -f SKFP_MODULES     ]; then inst_mod SKFP_MODULES     net;   fi;        \
         if [ -f IEEE1394_MODULES ]; then inst_mod IEEE1394_MODULES ieee1394; fi;     \
         if [ -f PCMCIA_MODULES   ]; then inst_mod PCMCIA_MODULES pcmcia;   fi;       \
         if [ -f PCMCIA_NET_MODULES ]; then inst_mod PCMCIA_NET_MODULES pcmcia; fi;   \
         if [ -f PCMCIA_CHAR_MODULES ]; then inst_mod PCMCIA_CHAR_MODULES pcmcia; fi; \
         if [ -f PCMCIA_SCSI_MODULES ]; then inst_mod PCMCIA_SCSI_MODULES pcmcia; fi; \
                                                                                      \
        for f in *.o; do [ -r $$f ] && echo $$f; done > .allmods; \
        echo $$MODULES | tr ' ' '\n' | sort | comm -23 .allmods - > .misc; \
        if [ -s .misc ]; then inst_mod .misc misc; fi; \
        rm -f .misc .allmods; \
        )
endef

ifeq (,$(findstring nostrip,$(DEB_BUILD_OPTIONS)))
INSTALL_MOD_STRIP:=1
endif

# only generate module image packages
modules-image modules_image: .config
ifeq ($(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),)
	@echo Modules not configured, so not making $@
else
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(KERNELRELEASE)"; exit 1)
endif
	$(if $(subst $(strip $(UTS_RELEASE_VERSION)),,$(strip $(KERNELRELEASE))), \
		echo "The UTS Release version in $(UTS_RELEASE_HEADER)"; \
		echo "     \"$(strip $(UTS_RELEASE_VERSION))\" "; \
		echo "does not match current version:"; \
		echo "     \"$(strip $(KERNELRELEASE))\" "; \
		echo "Please correct this."; \
		exit 2,)
	-for module in $(valid_modules) ; do                       \
          if test -d  $$module; then                                \
	    (cd $$module;                                          \
              if ./debian/rules KVERS="$(KERNELRELEASE)" KSRC="$(SRCTOP)" \
                             KMAINT="$(pgp)" KEMAIL="$(email)"      \
                             KPKG_DEST_DIR="$(KPKG_DEST_DIR)"       \
                             KPKG_MAINTAINER="$(maintainer)"        \
                             KPKG_EXTRAV_ARG="$(EXTRAV_ARG)"        \
                             ARCH="$(KERNEL_ARCH)" $(CROSS_ARG)     \
                             KDREV="$(debian)" kdist_image; then    \
                  echo "Module $$module processed fine";            \
              else                                                  \
                   echo "Module $$module failed.";                  \
                   if [ "X$(strip $(ROOT_CMD))" != "X" ]; then      \
                      echo "Perhaps $$module does not understand --rootcmd?";  \
                      echo "If you see messages that indicate that it is not"; \
                      echo "in fact being built as root, please file a bug ";  \
                      echo "against $$module.";                     \
                   fi;                                              \
                   echo "Hit return to Continue";                   \
		 read ans;                                          \
              fi;                                                   \
	     );                                                     \
	  else                                                      \
               echo "Module $$module does not exist";               \
               echo "Hit return to Continue?";                      \
	  fi;                                                       \
        done
endif

# generate the modules packages and sign them
modules: .config
ifeq ($(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),)
	@echo Modules not configured, so not making $@
else
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(KERNELRELEASE)"; exit 1)
endif
	$(if $(subst $(strip $(UTS_RELEASE_VERSION)),,$(strip $(KERNELRELEASE))), \
		echo "The UTS Release version in $(UTS_RELEASE_HEADER)"; \
		echo "     \"$(strip $(UTS_RELEASE_VERSION))\" "; \
		echo "does not match current version:"; \
		echo "     \"$(strip $(KERNELRELEASE))\" "; \
		echo "Please correct this."; \
		exit 2,)
	-for module in $(valid_modules) ; do                       \
          if test -d  $$module; then                                \
	    (cd $$module;                                          \
              if ./debian/rules KVERS="$(KERNELRELEASE)" KSRC="$(SRCTOP)" \
                             KMAINT="$(pgp)" KEMAIL="$(email)"      \
                             KPKG_DEST_DIR="$(KPKG_DEST_DIR)"       \
                             KPKG_MAINTAINER="$(maintainer)"        \
                             ARCH=$(KERNEL_ARCH) $(CROSS_ARG)       \
                             KPKG_EXTRAV_ARG="$(EXTRAV_ARG)"        \
                             KDREV="$(debian)" kdist; then          \
                  echo "Module $$module processed fine";            \
              else                                                  \
                   echo "Module $$module failed.";                  \
                   if [ "X$(strip $(ROOT_CMD))" != "X" ]; then      \
                      echo "Perhaps $$module does not understand --rootcmd?";  \
                      echo "If you see messages that indicate that it is not"; \
                      echo "in fact being built as root, please file a bug ";  \
                      echo "against $$module.";                     \
                   fi;                                              \
                   echo "Hit return to Continue?";                  \
		 read ans;                                          \
              fi;                                                   \
	     );                                                     \
	  else                                                      \
               echo "Module $$module does not exist";               \
               echo "Hit return to Continue?";                      \
	  fi;                                                       \
        done
endif

# configure the modules packages
modules-config modules_config: .config
ifeq ($(strip $(shell grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE))),)
	@echo Modules not configured, so not making $@
else
ifneq ($(strip $(HAVE_VERSION_MISMATCH)),)
	@(echo "The changelog says we are creating $(saved_version), but I thought the version is $(KERNELRELEASE)"; exit 1)
endif
	$(if $(subst $(strip $(UTS_RELEASE_VERSION)),,$(strip $(KERNELRELEASE))), \
		echo "The UTS Release version in $(UTS_RELEASE_HEADER)"; \
		echo "     \"$(strip $(UTS_RELEASE_VERSION))\" "; \
		echo "does not match current version:"; \
		echo "     \"$(strip $(KERNELRELEASE))\" "; \
		echo "Please correct this."; \
		exit 2,)
	-for module in $(valid_modules) ; do                       \
          if test -d  $$module; then                                \
	    (cd $$module;                                          \
              if ./debian/rules KVERS="$(KERNELRELEASE)" KSRC="$(SRCTOP)" \
                             KMAINT="$(pgp)" KEMAIL="$(email)"      \
                             KPKG_DEST_DIR="$(KPKG_DEST_DIR)"       \
                             KPKG_MAINTAINER="$(maintainer)"        \
                             ARCH=$(KERNEL_ARCH) $(CROSS_ARG)       \
                             KPKG_EXTRAV_ARG="$(EXTRAV_ARG)"        \
                             KDREV="$(debian)" kdist_configure; then\
                  echo "Module $$module configured fine";           \
              else                                                  \
                   echo "Module $$module failed to configure";      \
                   echo "Hit return to Continue?";                  \
		 read ans;                                          \
              fi;                                                   \
	     );                                                     \
	  else                                                      \
               echo "Module $$module does not exist";               \
               echo "Hit return to Continue?";                      \
	  fi;                                                      \
        done
endif

modules-clean modules_clean:
ifeq ($(strip $(shell if [ -e $(CONFIG_FILE) ]; then grep -E ^[^\#]*CONFIG_MODULES $(CONFIG_FILE); fi)),)
	@echo Modules not configured, so not making $@
else
	$(if $(subst $(strip $(UTS_RELEASE_VERSION)),,$(strip $(KERNELRELEASE))), \
		echo "The UTS Release version in $(UTS_RELEASE_HEADER)"; \
		echo "     \"$(strip $(UTS_RELEASE_VERSION))\" "; \
		echo "does not match current version:"; \
		echo "     \"$(strip $(KERNELRELEASE))\" "; \
		echo "Please correct this."; \
		exit 2,)
	-for module in $(valid_modules); do                        \
          if test -d  $$module; then                                \
	    (cd $$module;                                          \
              if ./debian/rules KVERS="$(KERNELRELEASE)" KSRC="$(SRCTOP)" \
                             KMAINT="$(pgp)" KEMAIL="$(email)"      \
                             KPKG_DEST_DIR="$(KPKG_DEST_DIR)"       \
                             KPKG_MAINTAINER="$(maintainer)"        \
                             ARCH=$(KERNEL_ARCH) $(CROSS_ARG)       \
                             KPKG_EXTRAV_ARG="$(EXTRAV_ARG)"        \
                             KDREV="$(debian)" kdist_clean; then    \
                  echo "Module $$module cleaned";                   \
              else                                                  \
                   echo "Module $$module failed to clean up";       \
                   echo "Hit return to Continue?";                  \
		 read ans;                                          \
              fi;                                                   \
	     );                                                     \
	  else                                                      \
               echo "Module $$module does not exist";               \
               echo "Hit return to Continue?";                      \
	  fi;                                                       \
        done
endif


# 		2.0.38	2.2.12	2.3.1
# BLOCK_MODULES	X	X	X
# NET_MODULES	X	X	X
# IPV4_MODULES	X	X	X
# IPV6_MODULES		X	X
# ATM_MODULES			X
# SCSI_MODULES	X	X	X
# FS_MODULES	X	X	X
# NLS_MODULES		X	X
# CDROM_MODULES	X	X	X
# HAM_MODULES		X	X
# SOUND_MODULES		X	X
# VIDEO_MODULES		X	X
# FC4_MODULES		X	X
# IRDA_MODULES		X	X
# USB_MODULES			X


#Local variables:
#mode: makefile
#End:
