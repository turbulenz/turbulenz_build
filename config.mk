# Copyright (c) 2013 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

ifeq ($(BUILDDIR),)
  $(error BUILDDIR not set)
endif

############################################################

BUILDVERBOSE ?= 0
CMDVERBOSE ?= 0
CONFIG ?= release
VALGRIND ?= 0
ABSPATHS ?= 1

# Disable all build-in rules
.SUFFIXES:

#
# Platform stuff.  Determine the build host
#

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
  BUILDHOST := win32
  ABSPATHS := 0
  UNITY := 0
endif

# $(info UNAME = $(UNAME))
# $(info SHELL = $(SHELL))

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

ifeq ($(TARGET),macosx)
  COMPILER ?= clang
  TARGETNAME := macosx
  ARCH ?= x86_64
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
  COMPILER ?= vs2013
  VARIANT:=-$(COMPILER)$(VARIANT)
endif

ifeq ($(TARGET),iossim)
  # 'iossim' is shorthand for TARGET=ios, ARCH=i386
  override TARGET := ios
  ARCH ?= i386
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

############################################################
# CONFIG default settings
############################################################

ifeq ($(CONFIG),release)
  C_SYMBOLS ?= 0
  C_OPTIMIZE ?= 1
  LD_OPTIMIZE ?= 0    # Keep LTO off by default
endif
ifeq ($(CONFIG),debug)
  C_SYMBOLS ?= 1
  C_OPTIMIZE ?= 0
  LD_OPTIMIZE ?= 0
endif

############################################################
# Target PLATFORM variables
############################################################

_platform_config :=                                     \
  $(wildcard $(BUILDDIR)/platform_$(TARGET).mk)         \
  $(wildcard $(CUSTOMSCRIPTS)/platform_$(TARGET).mk)

ifeq (,$(strip $(_platform_config)))
  $(error Cannot find platform_$(TARGET).mk)
endif
include $(_platform_config)

############################################################

ifeq (1,$(ABSPATHS))
  ROOTDIR ?= $(realpath .)/
endif
OBJDIR = $(ROOTDIR)obj/$(TARGET)$(VARIANT)-$(CONFIG)
DEPDIR = $(OBJDIR)
LIBDIR = $(ROOTDIR)lib/$(TARGET)$(VARIANT)-$(CONFIG)
BINDIR = $(ROOTDIR)bin/$(TARGET)$(VARIANT)-$(CONFIG)
BINOUTDIR = $(ROOTDIR)bin/$(TARGET)-$(CONFIG)

############################################################

ifeq ($(BUILDVERBOSE),1)
  log=$(warning $(1))
endif
$(call log,Verbose Mode Enabled...)
# $(call log,ROOTDIR=$(ROOTDIR))
# $(call log,OBJDIR=$(OBJDIR))
# $(call log,LIBDIR=$(LIBDIR))
# $(call log,BINDIR=$(BINDIR))

############################################################

ifneq ($(CMDVERBOSE),1)
  CMDPREFIX:=@
endif

ifeq ($(VALGRIND),1)
  RUNPREFIX+=valgrind --dsymutil=yes --track-origins=yes --leak-check=full --error-exitcode=15
  # --gen-suppressions=all
  CXXFLAGS += -DTZ_VALGRIND
endif

CP := python $(BUILDDIR)/commands/cp.py
CAT := python $(BUILDDIR)/commands/cat.py
MKDIR := python $(BUILDDIR)/commands/mkdir.py
RM := python $(BUILDDIR)/commands/rm.py
FIND := python $(BUILDDIR)/commands/find.py
TSC ?= tsc
MAKE_APK_PROJ := python $(BUILDDIR)/commands/make_android_project.py

ifeq (win32,$(BUILDHOST))
  TRUE := cmd /c "exit /b 0"
  FALSE := cmd /c "exit /b 1"
else
  TRUE := true
  FALSE := false
endif

############################################################

# Util functions for the build description

#  1 - file name
file_flags = CXXFLAGS_$(subst /,_,$(realpath $(1)))

# 1 - source file name
# 2 - flags
set_file_flags = $(eval \
  $(call file_flags,$(1)) := $(2) \
)

############################################################
# Common rules (building directories, etc)
############################################################

.SECONDEXPANSION:

_TZ_DIRS :=

# 1 - directory name
_dir_marker = $(foreach d,$(1),$(d).mkdir)

# 1 - directory name
define _create_mkdir_rule

  $(if $(filter $(1),$(_TZ_DIRS)),$(error alrady have rule for dir: $1))

  $(call _dir_marker,$(1)) :
	@echo "[MKDIR] $1"
	$(CMDPREFIX)$(MKDIR) $$(dir $$@)
	$(CMDPREFIX)echo directory marker > $$@

  _TZ_DIRS += $(1)
endef

# 1 - directory name
_mkdir_rule =                                  \
  $(foreach d,$(1),                            \
    $(if $(filter $(d),$(_TZ_DIRS)),,          \
      $(eval $(call _create_mkdir_rule,$(d)))  \
    )                                          \
  )
