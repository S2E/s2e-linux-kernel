######################### -*- Mode: Makefile-Gmake -*- ########################
## architecture.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Fri Oct 28 00:28:13 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Thu Apr 13 09:48:40 2006
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 6
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
##
## arch-tag: ceaf3617-cfb1-4acb-a865-a87f280b2336
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


######################################################################
###          Architecture specific stuff                           ###
######################################################################
# Each architecture has the following specified for it
# (a) The kernel image type (i.e. zImage or bzImage)
# (e) The build target
# (f) The location of the kernelimage source
# (g) The location of the kernelimage destination
# (h) The name of the arch specific configuration file
# Some architectures has sub architectures
INT_IMAGE_DESTDIR=$(TMPTOP)/$(IMAGEDIR)
define DO_IMAGE_POST_PROCESSING
	@echo ""
endef

$(eval $(which_debdir))
### m68k
ifeq ($(strip $(architecture)),m68k)
include $(DEBDIR)/ruleset/arches/m68k.mk
endif

### ARM
ifeq ($(strip $(architecture)),arm)
include $(DEBDIR)/ruleset/arches/arm.mk
endif
ifeq ($(strip $(architecture)),armeb)
include $(DEBDIR)/ruleset/arches/armeb.mk
endif

##### PowerPC and PowerPC architecture 
ifneq ($(strip $(filter ppc powerpc ppc64 powerpc64,$(architecture))),)
    include $(DEBDIR)/ruleset/arches/powerpc.mk
endif

##### Alpha
ifeq ($(strip $(architecture)),alpha)
include $(DEBDIR)/ruleset/arches/alpha.mk
endif


##### Sparc
ifeq ($(strip $(architecture)),sparc)
include $(DEBDIR)/ruleset/arches/sparc.mk
endif

##### amd64
ifeq ($(strip $(architecture)),x86_64)
include $(DEBDIR)/ruleset/arches/amd64.mk
endif
# This is the alternate
ifeq ($(strip $(architecture)),amd64)
include $(DEBDIR)/ruleset/arches/amd64.mk
endif

##### i386 and such
ifeq ($(strip $(architecture)),i386)
include $(DEBDIR)/ruleset/arches/i386.mk
endif

##### S/390
ifeq ($(strip $(architecture)),s390)
include $(DEBDIR)/ruleset/arches/s390.mk
endif

##### hppa
ifeq ($(strip $(architecture)),hppa)
include $(DEBDIR)/ruleset/arches/hppa.mk
endif

##### ia64
ifeq ($(strip $(architecture)),ia64)
include $(DEBDIR)/ruleset/arches/ia64.mk
endif

##### mips
ifeq ($(strip $(architecture)),mips)
include $(DEBDIR)/ruleset/arches/mips.mk
endif

##### mipsel
ifeq ($(strip $(architecture)),mipsel)
include $(DEBDIR)/ruleset/arches/mipsel.mk
endif

##### m32r
ifeq ($(strip $(architecture)),m32r)
include $(DEBDIR)/ruleset/arches/m32r.mk
endif

# usermode linux
ifeq ($(strip $(architecture)),um)
include $(DEBDIR)/ruleset/arches/uml.mk
endif

# xen-linux
ifeq ($(strip $(architecture)),xen)
include $(DEBDIR)/ruleset/arches/xen.mk
endif


#Local variables:
#mode: makefile
#End:
