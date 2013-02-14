# Copyright (c) 2013 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

ifeq ($(BUILDDIR),)
  $(error BUILDDIR not set)
endif

############################################################

BUILDVERBOSE ?= 0
CMDVERBOSE ?= 0
CONFIG ?= release

# Disable all build-in rules
.SUFFIXES:

#
# Platform stuff.  Determine the build host
#
_shell_base := $(notdir $(SHELL))
ifneq (,$(filter %.exe,$(_shell_base)))
  UNAME := win32
  # This avoids problems where sh.exe exists in the path, but has
  # spaces in it.
  override SHELL := cmd.exe
else
  UNAME := $(shell uname)
endif

# $(warning UNAME = $(UNAME))
# $(warning SHELL = $(SHELL))

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

# Check for unsupported build host
ifeq ($(UNAME),)
  $(warning Couldnt determine BUILDHOST from uname: $(UNAME), assuming win32)
  UNAME := win32
endif

ifeq ($(UNAME),win32)
  BUILDHOST := win32
endif

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
  TARGETNAME ?= macosx
  ARCH ?= i386
endif

ifeq ($(TARGET),android)
  TARGETNAME ?= android
  ARCH ?= armv7a
endif

ifeq ($(TARGET),linux64)
  TARGETNAME ?= linux
  ARCH ?= x86_64
  PKGARCH ?= amd64
endif

ifeq ($(TARGET),linux32)
  TARGETNAME ?= linux
  ARCH ?= i386
  PKGARCH ?= x86
endif

ifeq ($(TARGET),win32)
  TARGETNAME ?= win32
  ARCH ?= i386
endif

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
endif
ifeq ($(CONFIG),debug)
  C_SYMBOLS ?= 1
  C_OPTIMIZE ?= 0
endif

############################################################
# Target PLATFORM variables
############################################################

include $(BUILDDIR)/platform_$(TARGET).mk

############################################################

ROOTDIR ?= $(realpath .)
OBJDIR = $(ROOTDIR)/obj/$(TARGET)$(VARIANT)-$(CONFIG)
DEPDIR = $(OBJDIR)
LIBDIR = $(ROOTDIR)/lib/$(TARGET)$(VARIANT)-$(CONFIG)
BINDIR = $(ROOTDIR)/bin/$(TARGET)$(VARIANT)-$(CONFIG)

############################################################

ifeq ($(BUILDVERBOSE),1)
  log=$(warning $(1))
endif
$(call log,Verbose Mode Enabled...)
$(call log,ROOTDIR=$(ROOTDIR))
$(call log,OBJDIR=$(OBJDIR))
$(call log,LIBDIR=$(LIBDIR))
$(call log,BINDIR=$(BINDIR))

############################################################

ifneq ($(CMDVERBOSE),1)
  CMDPREFIX:=@
endif

CP := python $(BUILDDIR)/commands/cp.py
CAT := $(CMDPREFIX)python $(BUILDDIR)/commands/cat.py
MKDIR := python $(BUILDDIR)/commands/mkdir.py
RM := python $(BUILDDIR)/commands/rm.py
FIND := python $(BUILDDIR)/commands/find.py
TSC := node $(BUILDDIR)/../typescript/0.8.2/tsc.js
MAKE_APK_PROJ := python $(BUILDDIR)/commands/make_android_project.py

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
