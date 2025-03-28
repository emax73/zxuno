# Common declarations for Makefiles.
#
# SPDX-FileCopyrightText: 2021 Ivan Tatarinov <ivan-tat@ya.ru>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Supported environments:
#   * GNU on Linux, FreeBSD etc.
#   * GNU on Windows NT (using MinGW/MSYS/Cygwin/WSL)

ifndef ZXSDK

# ZXSDK

# Root (if set acts as a flag of the properly configured environment variables)
export ZXSDK = $(patsubst %/,%,$(abspath $(dir $(lastword $(MAKEFILE_LIST)))))
_path = $(ZXSDK)

# Root of platform specific files
ifeq ($(OS),Windows_NT)
 ifeq ($(PROCESSOR_ARCHITECTURE),X86)
  ZXSDK_PLATFORM = $(ZXSDK)/windows-x86
 else ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
  ZXSDK_PLATFORM = $(ZXSDK)/windows-x86
 else ifeq ($(PROCESSOR_ARCHITECTURE),EM64T)
  ZXSDK_PLATFORM = $(ZXSDK)/windows-x86
 else
  $(warning Unsupported platform: "$(PROCESSOR_ARCHITECTURE)")
  ZXSDK_PLATFORM = $(ZXSDK)/windows-x86
 endif
else
 ZXSDK_PLATFORM = $(ZXSDK)
endif
export ZXSDK_PLATFORM

# "bin" directory (platform specific)
_path := $(_path):$(ZXSDK_PLATFORM)/bin

# "lib" directory (platform specific)
ifeq ($(OS),Windows_NT)
 _path := $(_path):$(ZXSDK_PLATFORM)/lib
else
 export LD_LIBRARY_PATH = $(ZXSDK_PLATFORM)/lib
endif

# SDCC

# Root (platform specific)
export SDCCHOME	= $(ZXSDK_PLATFORM)/opt/sdcc

# "bin" directory (platform specific)
_path := $(_path):$(SDCCHOME)/bin

# "include" directory (platform specific)
ifeq ($(OS),Windows_NT)
 SDCCINCLUDE = $(SDCCHOME)/include
else
 SDCCINCLUDE = $(SDCCHOME)/share/sdcc/include
endif
export SDCCINCLUDE

# "lib" directory (platform specific)
ifeq ($(OS),Windows_NT)
 SDCCLIB = $(SDCCHOME)/lib
else
 SDCCLIB = $(SDCCHOME)/share/sdcc/lib
endif
export SDCCLIB

# Z88DK

# Root
Z88DK = $(ZXSDK)/src/z88dk

# "bin" directory
_path := $(_path):$(Z88DK)/bin

# Configuration file
ZCCCFG = $(Z88DK)/lib/config
ifeq ($(OS),Windows_NT)
 # Fix paths under Cygwin for Z88DK on Windows
 ifeq ($(shell echo $$OSTYPE),cygwin)
  ZCCCFG := $(shell cygpath -m $(ZCCCFG))
 endif
endif
export ZCCCFG

# PATH

export PATH := $(_path):$(PATH)
#undefine _path

endif	# !ZXSDK

# Default values

-include $(ZXSDK)/conf.mk

# Shared directory for downloaded files
DOWNLOADS ?= $(shell realpath $(ZXSDK)/../.downloads)

# C compiler
ifeq ($(BUILD),mingw32)
 CC = i686-w64-mingw32-gcc
else ifeq ($(BUILD),mingw64)
 CC = x86_64-w64-mingw32-gcc
endif

# Filename suffixes (platform specific)
ifeq ($(BUILD),mingw32)
 EXESUFFIX = .exe
 DLLSUFFIX = .dll
else ifeq ($(BUILD),mingw64)
 EXESUFFIX = .exe
 DLLSUFFIX = .dll
else
 ifeq ($(OS),Windows_NT)
  EXESUFFIX = .exe
  DLLSUFFIX = .dll
 else
  EXESUFFIX =
  DLLSUFFIX = .so
 endif
endif

# Default path where to install files (platform specific)
ifeq ($(BUILD),mingw32)
 USE_PREFIX ?= $(ZXSDK)/windows-x86
else ifeq ($(BUILD),mingw64)
 USE_PREFIX ?= $(ZXSDK)/windows-x86_64
else
USE_PREFIX ?= $(ZXSDK_PLATFORM)
endif

# Version of SJAsmPlus compiler to use
USE_SJASMPLUS_VERSION ?= z00m128
