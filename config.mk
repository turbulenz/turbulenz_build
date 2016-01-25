# Copyright (c) 2015 Turbulenz Limited.
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

############################################################
# Get basic platform info (HOST and TARGET)
############################################################

include $(BUILDDIR)/config_platform_info.mk
# $(info tzbuild: config.mk: called config_platform_info.mk)

############################################################
# CONFIG default settings
############################################################

ifeq ($(CONFIG),release)
  C_SYMBOLS ?= 1
  C_OPTIMIZE ?= 1
  LD_OPTIMIZE ?= 0    # Keep LTO off by default
endif
ifeq ($(CONFIG),debug)
  C_SYMBOLS ?= 1
  C_OPTIMIZE ?= 0
  LD_OPTIMIZE ?= 0
endif
ifeq ($(CONFIG),development)
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
RELPATH := python $(BUILDDIR)/commands/relpath.py
TSC ?= tsc
MAKE_APK_PROJ := python $(BUILDDIR)/commands/make_android_project.py
CLANG_TIDY ?= clang-tidy

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

  $(if $(filter $(1),$(_TZ_DIRS)),$(error already have rule for dir: $1))

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
