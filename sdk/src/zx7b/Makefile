# SPDX-FileCopyrightText: 2021 Ivan Tatarinov <ivan-tat@ya.ru>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Supported environments:
#   * GNU on Linux, FreeBSD etc.
#   * GNU on Windows NT (using MinGW/MSYS/Cygwin/WSL)
#
# Build:
#   make [BUILD=<BUILD>] [<TARGET> ...]
# Install / Uninstall:
#   make [BUILD=<BUILD>] [prefix=<PREFIX>] install | uninstall
# Clean:
#   make [BUILD=<BUILD>] clean
#   make distclean
#
# where:
#   <BUILD> - see included `common.mk'.
#   <TARGET> is one of values for `BINS' variable prefixed with "build/"
#     (see target `all' below).
#   <PREFIX> is a prefix directory to install files into.

include ../../common.mk

srcdir		= .
prefix		?= /usr/local
exec_prefix	?= $(prefix)
bindir		?= $(exec_prefix)/bin

INSTALL		?= install
INSTALL_PROGRAM	?= $(INSTALL)

BINS=\
 zx7b$(EXESUFFIX)\
 dzx7b$(EXESUFFIX)

.PHONY: all
all: $(foreach t,$(BINS),build/$(t))

build\
$(DESTDIR)$(bindir):
	mkdir -p $@

build/zx7b$(EXESUFFIX): $(srcdir)/zx7b.c Makefile | build
	$(CC) $(CFLAGS) -o $@ $<

build/dzx7b$(EXESUFFIX): $(srcdir)/dzx7b.c Makefile | build
	$(CC) $(CFLAGS) -o $@ $<

.PHONY: install
install: $(foreach t,$(BINS),$(DESTDIR)$(bindir)/$(t))

$(DESTDIR)$(bindir)/zx7b$(EXESUFFIX): build/zx7b$(EXESUFFIX) | $(DESTDIR)$(bindir)
	$(INSTALL_PROGRAM) -m 755 $< $@

$(DESTDIR)$(bindir)/dzx7b$(EXESUFFIX): build/dzx7b$(EXESUFFIX) | $(DESTDIR)$(bindir)
	$(INSTALL_PROGRAM) -m 755 $< $@

.PHONY: uninstall
uninstall:
	rm -f $(foreach t,$(BINS),$(DESTDIR)$(bindir)/$(t))

.PHONY: clean
clean:
	rm -f $(foreach t,$(BINS),build/$(t))

.PHONY: distclean
distclean:
	rm -rf build/*
