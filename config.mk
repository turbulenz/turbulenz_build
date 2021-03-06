# Copyright (c) 2015 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

ifeq ($(BUILDDIR),)
  $(error BUILDDIR not set)
endif

include $(BUILDDIR)/utils.mk

############################################################

BUILDVERBOSE ?= 0
CMDVERBOSE ?= 0
CONFIG ?= release
VALGRIND ?= 0
ABSPATHS ?= 0
ABSPATHS_EXT ?= 1
UNITY ?= 1
PCH ?= 1

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

ifeq ($(CONFIG),debug)
  C_SYMBOLS ?= 1
  C_OPTIMIZE ?= 0
  C_RUNTIME_CHECKS ?= 0
  LD_OPTIMIZE ?= 0
  WIN_DLL=debug
endif
ifeq ($(CONFIG),development)
  C_SYMBOLS ?= 1
  C_OPTIMIZE ?= 0
  C_RUNTIME_CHECKS ?= 0
  LD_OPTIMIZE ?= 0
  WIN_DLL=release
endif
ifeq ($(CONFIG),release-noltcg)
  C_SYMBOLS ?= 1
  C_OPTIMIZE ?= 1
  C_RUNTIME_CHECKS ?= 0
  LD_OPTIMIZE ?= 0
  WIN_DLL=release
endif
ifeq ($(CONFIG),release)
  C_SYMBOLS ?= 1
  C_OPTIMIZE ?= 1
  C_RUNTIME_CHECKS ?= 0
  LD_OPTIMIZE ?= 1
  WIN_DLL=release
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

OBJDIR = obj/$(TARGET)$(VARIANT)-$(CONFIG)
DEPDIR = $(OBJDIR)
LIBDIR = lib/$(TARGET)$(VARIANT)-$(CONFIG)
BINDIR = bin/$(TARGET)$(VARIANT)-$(CONFIG)
BINOUTDIR = bin/$(TARGET)-$(CONFIG)

############################################################

ifeq ($(BUILDVERBOSE),1)
  log=$(warning $(1))
endif
$(call log,Verbose Mode Enabled...)
# $(call log,OBJDIR=$(OBJDIR))
# $(call log,LIBDIR=$(LIBDIR))
# $(call log,BINDIR=$(BINDIR))

############################################################

ifneq ($(CMDVERBOSE),1)
  CMDPREFIX:=@
endif

ifeq ($(VALGRIND),1)
  RUNPREFIX += valgrind --dsymutil=yes --track-origins=yes --leak-check=full \
    --error-exitcode=15
  # --gen-suppressions=all
  CXXFLAGS += -DTZ_VALGRIND
endif

BUILDDIR_ABS := $(realpath $(BUILDDIR))
MV := python $(BUILDDIR_ABS)/commands/mv.py
CP := python $(BUILDDIR_ABS)/commands/cp.py
CAT := python $(BUILDDIR_ABS)/commands/cat.py
MKDIR := python $(BUILDDIR_ABS)/commands/mkdir.py
FIND := python $(BUILDDIR_ABS)/commands/find.py
RELPATH := python $(BUILDDIR_ABS)/commands/relpath.py
TSC ?= tsc
MAKE_APK_PROJ := python $(BUILDDIR)/commands/make_android_project.py
CLANG_TIDY ?= clang-tidy

ifneq (,$(filter win%,$(BUILDHOST)))
  RM := python $(BUILDDIR)/commands/rm.py
  TRUE := cmd /c "exit /b 0"
  FALSE := cmd /c "exit /b 1"
else
  RM := rm
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

############################################################
# Resolve externals.
#
# EXT list and all external versions
############################################################

# Pull in all platform-specific externals

EXT := $(sort $(EXT) $(EXT_$(TARGETNAME)) $(EXT_$(TARGET)))

# Let platform-specific versions <external>_version_<targetname>
# override defaults.

$(foreach ext,$(EXT),$(eval                                              \
  $(ext)_version := $(strip                                              \
    $(if $($(ext)_version_$(TARGETNAME)),                                \
         $($(ext)_version_$(TARGETNAME)),                                \
         $($(ext)_version))                                              \
  )))

ifeq (,$(CONFIG))
  $(error CONFIG not defined)
endif
ifeq (,$(TARGETNAME))
  $(error TARGETNAME not defined)
endif
ifeq (,$(COMPILER))
  $(error COMPILER not defined)
endif
ifeq (,$(ARCH))
  $(error ARCH not defined)
endif
