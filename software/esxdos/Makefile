# SPDX-FileCopyrightText: 2021 Ivan Tatarinov <ivan-tat@ya.ru>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Supported environments:
#   * GNU on Linux, FreeBSD etc.
#   * GNU on Windows NT (using MinGW/MSYS/Cygwin/WSL)
#
# Build:
#   make [all]
# Install / Uninstall:
#   make [prefix=<PREFIX>] install | uninstall
# Clean:
#   make clean | distclean
#
# where:
#   <PREFIX> is a prefix directory to install files into.

include ../../sdk/common.mk

# Use uppercase for FAT filesystem
prefix		?= .
exec_prefix	?= $(prefix)
bindir		?= $(exec_prefix)/BIN
docdir		?= $(prefix)/DOCS
sysdir		?= $(exec_prefix)/SYS
sysconfdir	?= ${sysdir}/CONFIG
tmpdir		?= $(prefix)/TMP

# Disable execution mode for FAT filesystem
INSTALL		?= install -m 644
INSTALL_PROGRAM	?= $(INSTALL)
RM		?= rm -f

ROOT_FILES=\
 ESX089.NFO\
 ESXMMC.BIN\
 README.TXT

BIN_FILES=\
 128\
 CAL\
 CD\
 CHMOD\
 CP\
 DATE\
 DFWLOAD\
 DIVIDEO\
 DRIVES\
 DSKPROBE\
 DUMPMEM\
 FILE\
 GRAMON\
 GSC\
 HEXDUMP\
 HEXVIEW\
 LAUNCHER\
 LS\
 LSTAP\
 MKDIR\
 MKTRD\
 MORE\
 MV\
 PARTINFO\
 PLAYPT3\
 PLAYSQT\
 PLAYSTC\
 PLAYTFM\
 PLAYWAV\
 RM\
 SCL2TRD\
 SERCP\
 SNAPLOAD\
 SPEAKCZ\
 STRINGS\
 TAPEIN\
 TAPEOUT\
 TAR\
 TE\
 TSPLAY\
 VDISK

DOC_FILES=\
 DIVIDEO.TXT\
 GRAMON.TXT\
 PLAYWAV.TXT\
 SNAPLOAD.TXT\
 SPEAKCZ.TXT\
 TEINFO.TXT\
 TRKPLAY.TXT

SYS_FILES=\
 BDIR.KO\
 BETADISK.SYS\
 BFILE.KO\
 ERRMSG.KO\
 ESXDOS.SYS\
 NMI_HELP.SCR\
 NMI.SYS\
 TAPE.KO\
 TRDBOOT.BIN\
 TRDOS54T.KO\
 VDISK.KO

SYSCONF_FILES=\
 ESXDOS.CFG\
 TRDOS.CFG

.PHONY: all
all: build/.extracted

$(DOWNLOADS)/esxdos\
build\
$(DESTDIR)$(prefix)\
$(DESTDIR)$(bindir)\
$(DESTDIR)$(docdir)\
$(DESTDIR)$(sysdir)\
$(DESTDIR)$(sysconfdir)\
$(DESTDIR)$(tmpdir):
	mkdir -p $@

ESXDOS_ARCHIVE		= $(DOWNLOADS)/esxdos/esxdos089.zip
ESXDOS_ARCHIVE_SHA256	= d455888361cd13d455e362a4c841452b6f4568d30f9069443044affdd40de9a4
ESXDOS_ARCHIVE_TYPE	= .zip
ESXDOS_ARCHIVE_SUBDIR	= .

build/.extracted: $(ESXDOS_ARCHIVE) | build
	rm -rf $(@D)
	extract.sh $<\
	 --sha256 $(ESXDOS_ARCHIVE_SHA256)\
	 --type $(ESXDOS_ARCHIVE_TYPE)\
	 --subdir $(ESXDOS_ARCHIVE_SUBDIR)\
	 --output $(@D)
	touch $@

$(DOWNLOADS)/esxdos/esxdos089.zip: | $(DOWNLOADS)/esxdos
	wget -c http://www.esxdos.org/files/$(@F) -O $@

define install_root_rule =
$$(DESTDIR)$$(prefix)/$1: build/$1 | $$(DESTDIR)$$(prefix)
	$$(INSTALL) $$< $$@
endef

$(foreach f,$(ROOT_FILES),$(eval $(call install_root_rule,$(f))))

define install_bin_rule =
$$(DESTDIR)$$(bindir)/$1: build/BIN/$1 | $$(DESTDIR)$$(bindir)
	$$(INSTALL_PROGRAM) $$< $$@
endef

$(foreach f,$(BIN_FILES),$(eval $(call install_bin_rule,$(f))))

define install_doc_rule =
$$(DESTDIR)$$(docdir)/$1: build/DOCS/$1 | $$(DESTDIR)$$(docdir)
	$$(INSTALL) $$< $$@
endef

$(foreach f,$(DOC_FILES),$(eval $(call install_doc_rule,$(f))))

define install_sys_rule =
$$(DESTDIR)$$(sysdir)/$1: build/SYS/$1 | $$(DESTDIR)$$(sysdir)
	$$(INSTALL) $$< $$@
endef

$(foreach f,$(SYS_FILES),$(eval $(call install_sys_rule,$(f))))

define install_sysconf_rule =
$$(DESTDIR)$$(sysconfdir)/$1: build/SYS/CONFIG/$1 | $$(DESTDIR)$$(sysconfdir)
	$$(INSTALL) $$< $$@
endef

$(foreach f,$(SYSCONF_FILES),$(eval $(call install_sysconf_rule,$(f))))

# Use separate rule to install files - `build` directory may be empty on
# `make install` invocation and we have to extract archive before we can
# use this rule
.PHONY: install-files
install-files:\
 $(foreach f,$(ROOT_FILES),$(DESTDIR)$(prefix)/$(f))\
 $(foreach f,$(BIN_FILES),$(DESTDIR)$(bindir)/$(f))\
 $(foreach f,$(DOC_FILES),$(DESTDIR)$(docdir)/$(f))\
 $(foreach f,$(SYS_FILES),$(DESTDIR)$(sysdir)/$(f))\
 $(foreach f,$(SYSCONF_FILES),$(DESTDIR)$(sysconfdir)/$(f))

# Do `make install-files` inside the recipe
.PHONY: install
install: build/.extracted
	mkdir -p $(DESTDIR)$(tmpdir)
	$(MAKE) -w install-files

.PHONY: uninstall
uninstall:
	$(RM)\
	 $(foreach f,$(ROOT_FILES),$(DESTDIR)$(prefix)/$(f))\
	 $(foreach f,$(BIN_FILES),$(DESTDIR)$(bindir)/$(f))\
	 $(foreach f,$(DOC_FILES),$(DESTDIR)$(docdir)/$(f))\
	 $(foreach f,$(SYS_FILES),$(DESTDIR)$(sysdir)/$(f))\
	 $(foreach f,$(SYSCONF_FILES),$(DESTDIR)$(sysconfdir)/$(f))

.PHONY: clean
clean:
	rm -rf build

.PHONY: distclean
distclean: clean
	rm -rf $(DOWNLOADS)/esxdos
