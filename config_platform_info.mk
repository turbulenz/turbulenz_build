# Copyright (c) 2015 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

ifeq ($(BUILDDIR),)
  $(error BUILDDIR not set)
endif

# Inputs:
#   TARGET
# Outputs:
#   BUILDHOST
#   TARGETNAME
#   TARGET (if not set)
#   ARCH (if not set)
#   COMPILER (if not set)
#   VARIANT (on some platforms, otherwise this is set later in config.mk)

############################################################
# Determine the build host
############################################################

ifeq (,$(BUILDHOST))

# Try to detect Windows, most robust methods first

ifeq (Windows_NT,$(OS))
  UNAME := win32
else
  ifneq (,$(filter %.exe,$(notdir $(SHELL))))
    UNAME := win32
  else
    ifdef SYSTEMROOT
      UNAME := win32
    else
      ifdef SystemRoot
        UNAME := win32
      else
        ifdef COMSPEC
          UNAME := win32
        else
          ifdef ComSpec
            UNAME := win32
          endif
        endif
      endif
    endif
  endif
endif

ifeq (,$(UNAME))
  UNAME := $(shell uname)
endif

# Check for unsupported build host
ifeq ($(UNAME),)
  $(warning Couldnt determine BUILDHOST from uname: $(UNAME), assuming win32)
  UNAME := win32
endif

# macosx
ifeq ($(UNAME),Darwin)
  BUILDHOST := macosx
endif

# linux32/64
ifeq ($(UNAME),Linux)
  M_ARCH := $(shell uname -m)
  ifeq ($(M_ARCH),x86_64)
    BUILDHOST := linux64
  else
    ifeq ($(M_ARCH),i686)
      BUILDHOST := linux32
    else
      $(error Unsupported architecture: $(M_ARCH))
    endif
  endif
endif

# windows
ifeq ($(UNAME),win32)
  override SHELL := cmd.exe
  BUILDHOST := win64
  ABSPATHS_EXT := 0
  UNITY := 0
endif

# $(info UNAME = $(UNAME))
# $(info SHELL = $(SHELL))
endif # ifeq (,$(BUILDHOST))

############################################################
# Target platform settings
############################################################

# Gate on _tz_build_set_target since TARGETNAME, ARCH, etc may be set
# by the calling build process.

ifeq (,$(_tz_build_set_target))
_tz_build_set_target := 1

# Set TARGET if it hasn't been determined, and based on that, set
# TARGETNAME:
#
#  TARGET = linux32, linux64, macosx, win32, win64, android, ...
#  TARGETNAME = linux, macosx, win, android, ...
#  ARCH = i386,x86_64,armv7a
#  PKGARCH = x86,amd64

ifeq ($(TARGET),)
  TARGET ?= $(BUILDHOST)
endif

# Apply and defaults passed in as <VAR>_<target>

ifneq (,$(COMPILER_$(TARGET)))
  COMPILER?=$(COMPILER_$(TARGET))
endif
ifneq (,$(ARCH_$(TARGET)))
  ARCH?=$(ARCH_$(TARGET))
endif

# Apply our own defaults for each platform

ifeq ($(TARGET),macosx)
  COMPILER ?= clang
  TARGETNAME := macosx
  ARCH ?= $(MACOSX_ARCH)
  ifeq (,$(ARCH))
    ARCH := x86_64
  endif
endif

ifeq ($(TARGET),android)
  TARGETNAME := android
  ARCH ?= armv7a
  COMPILER ?= gcc
endif

ifeq ($(TARGET),linux64)
  TARGETNAME := linux
  ARCH ?= x86_64
  COMPILER ?= gcc
  PKGARCH ?= amd64
endif

ifeq ($(TARGET),linux32)
  TARGETNAME := linux
  ARCH ?= i386
  COMPILER ?= gcc
  PKGARCH ?= x86
endif

ifeq ($(TARGET),win32)
  TARGETNAME := win
  ARCH ?= i386
  COMPILER ?= vs2013
  VARIANT:=-$(COMPILER)$(VARIANT)
endif

ifeq ($(TARGET),win64)
  TARGETNAME := win
  ARCH ?= x86_64
  COMPILER ?= vs2015
  VARIANT:=-$(COMPILER)$(VARIANT)
endif

ifeq ($(TARGET),iossim)
  # 'iossim' is shorthand for TARGET=ios, ARCH=i386
  override TARGET := ios
  ARCH ?= x86_64
endif

ifeq ($(TARGET),ios)
  TARGETNAME := ios
  ARCH ?= armv7
  COMPILER ?= clang
  VARIANT:=-$(ARCH)$(VARIANT)
endif

# Give the client a chance to define their own configuration code and
# platforms.
-include $(CUSTOMSCRIPTS)/tzbuild_config.mk

# unknown
ifeq ($(TARGETNAME),)
  $(error Couldnt determine TARGETNAME from TARGET: $(TARGET))
endif

endif # ifeq (,$(_tz_build_set_target))
