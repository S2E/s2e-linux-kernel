######################### -*- Mode: Makefile-Gmake -*- ########################
## local-vars.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Fri Oct 28 00:37:02 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Wed Jan  4 18:03:17 2006
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 6
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
##
## arch-tag: 429a30d9-86ea-4641-bae8-29988a017daf
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


FILES_TO_CLEAN  = modules/modversions.h modules/ksyms.ver debian/files \
                  scripts/cramfs/cramfsck  scripts/cramfs/mkcramfs 
STAMPS_TO_CLEAN =
DIRS_TO_CLEAN   = 


$(eval $(which_debdir))
include $(DEBDIR)/ruleset/misc/defaults.mk
include $(DEBDIR)/ruleset/misc/version_vars.mk
include $(DEBDIR)/ruleset/architecture.mk
include $(DEBDIR)/ruleset/misc/pkg_names.mk
# Include any site specific overrides here.
-include $(CONFLOC)

$(eval $(which_debdir))
include $(DEBDIR)/ruleset/misc/config.mk
include $(DEBDIR)/ruleset/misc/modules.mk
include $(DEBDIR)/ruleset/misc/checks.mk


#Local variables:
#mode: makefile
#End:
