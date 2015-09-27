# Copyright (c) 2013 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

# Make SYNTAX_CHECK_MODE use modular mode.  If we use refcheck,
# renamed x_flymake.ts files can reference other files which include
# the original x.ts, and we get duplicate symbols.

ifeq (1,$(SYNTAX_CHECK_MODE))
  TS_MODULAR := 1
  TS_REFCHECK := 0
  TS_OUTPUT_DIR := .tssyntaxcheck
  ifneq (,$(filter %.ts,$(CHK_SOURCES)))
    TS_SYNTAX_CHECK := 1
  endif
endif
# $(warning TS_SYNTAX_CHECK = $(TS_SYNTAX_CHECK))

TS_MODULAR ?= 1
ifeq (1,$(TS_REFCHECK))
  TS_MODULAR := 0
endif

TS_ALLOW_REFS ?= 0
TS_NODE_JS ?=

CLOSURE:=java -jar external/closure/compiler.jar \
  --compilation_level WHITESPACE_ONLY \
  --js_output_file /dev/null

#

# Define the postfix flags for various behaviour patterns, and
# external tools

tsc_postfix_failonerror := || ($(RM) $$@ && $(FALSE))
ifeq (win32,$(BUILDHOST))
  tsc_postfix_ignoreerrors := >NUL 2>&1 || if exist $$@ ($(TRUE)) else ($(FALSE))
else
  tsc_postfix_ignoreerrors := > /dev/null 2>&1 || [ -e $$@ ]
endif

############################################################
# Inlining compiled cgfx files
#
# Modules with .cgfx files as source must only have a single .ts file.
############################################################

TS_GEN_DIR ?= jslib/_generated
TS_GEN_FILES :=

_getcgfx = $(word 1,$(subst !, ,$(1)))
_getts = $(word 2,$(subst !, ,$(1)))

# Create the rules to build a .ts files from a .cgfx file
# 1 - module name
# 2 - cgfx file
# 3 - ts file
define _make_cgfx_ts_rule
  $(3:.ts=.json) : $(2)
	@echo "[CGFX2JSON] $$@"
	@$(MKDIR) -p $$(dir $$@)
	$(CMDPREFIX)$(CGFX2JSON) $(CGFX2JSONFLAGS) -o $$@ -i $$^

  $(3) : $(3:.ts=.json)
	@echo "[JSON2TS] $$@"
	@$(MKDIR) -p $$(dir $$@)
	$(CMDPREFIX)echo // Generated from $(2) > $$@
	$(CMDPREFIX)echo var $(subst -,_,$(subst .,_,$(notdir $(2)))) : any = >> $$@
	$(CMDPREFIX)$(CAT) $$^ >> $$@
	$(CMDPREFIX)echo ; >> $$@
endef

# Main function that handles cgfx files for each module.  It appears
# somewhat comlex, but it basically just does the following:
#
# If there are any cgfx files in <module>_src, there must be exactly 1
# .ts file.  A new .ts files of the same name is generated, and
# <module>_src is rewritten to reference that generated file.
#
# The generated .ts file contains the concatenation of:
#
#  1. each proceed cgfx file (compiled and inlined as typescript)
#
#  2. the original .ts file
#
# The rules for processing the cgfx files (into JSON and then into TS)
# are also created here.
#
# 1 - module name
define _make_cgfx_ts_list

  _$(1)_cgfx_ts_list := $$(foreach c,$(filter %.cgfx,$($(1)_src)),  \
    $$(c)!$(TS_GEN_DIR)/$$(notdir $$(c:.cgfx=.cgfx.ts))             \
  )

  ifneq (,$$(_$(1)_cgfx_ts_list))

    _$(1)_old_ts_src := $(filter %.ts,$(filter-out %.d.ts,$($(1)_src)))
    ifneq (1,$$(words $$(_$(1)_old_ts_src)))
      $$(error $(1): .cgfx file found with multiple .ts files: \
        $$(_$(1)_old_ts_src))
    endif

    # Replace .ts with the concatenated source in $(1)_src

    _$(1)_new_src := $$(subst $(TS_SRC_DIR),$(TS_GEN_DIR),$$(_$(1)_old_ts_src))
    $(1)_src :=                                               \
      $$(filter-out %.cgfx $$(_$(1)_old_ts_src),$($(1)_src))  \
      $$(_$(1)_new_src)
    TS_GEN_FILES += $$(_$(1)_new_src)

    # Rules to generate new (concatenated) .ts from generated .cgfx.ts
    # files

    _$(1)_gen_src_list := \
      $$(foreach ct,$$(_$(1)_cgfx_ts_list), $$(call _getts,$$(ct)))

    $$(_$(1)_new_src) : $$(_$(1)_gen_src_list) $$(_$(1)_old_ts_src)
	  @echo "[GEN_TS] $$@"
	  @$(MKDIR) -p $$(dir $$@)
	  $(CMDPREFIX)$(CAT) $$^ > $$@

    # Rules to generate .cgfx.ts files from .cgfx files

    $$(foreach ct,$$(_$(1)_cgfx_ts_list),  \
      $$(eval $$(call _make_cgfx_ts_rule,  \
        $(1),                              \
        $$(call _getcgfx,$$(ct)),          \
        $$(call _getts,$$(ct))             \
      ))                                   \
    )

  endif

endef

$(foreach t,$(TSLIBS),$(eval $(call _make_cgfx_ts_list,$(t))))

# If there will be any cgfx->ts generation happening in this build,
# ensure that the CGFX tool is available.

ifneq (,$(TS_GEN_FILES))
  ifeq (,$(CGFX2JSON))
    $(error Some modules have cgfx files, but CGFX2JSON has not been set)
  endif
  ifeq (,$(wildcard $(CGFX2JSON)))
    $(error CGFX2JSON points to non-existant file: $(CGFX2JSON))
  endif
endif

############################################################
#
# MODULAR BUILDS
#
# Each module defines a set of .ts files which are built into a .js
# and a .d.ts.  Modules can be dependent on other modules, meaning
# they require the .d.ts in order to build correctyl.  Any type errors
# result in a failed build.
#
############################################################

ifeq (1,$(TS_MODULAR))

TS_OUTPUT_DIR ?= jslib-modular
TS_SYNTAX_CHECK ?= 0

TSC_POSTFIX := $(tsc_postfix_failonerror)

# Syntax checking
syntax_replace = $(1)
ifeq (1,$(TS_SYNTAX_CHECK))
  ifneq (,$(filter %_flymake.ts,$(CHK_SOURCES)))
    SYNTAX_CHECK_REPLACE:=$(CHK_SOURCES:_flymake.ts=.ts)
    SYNTAX_CHECK_WITH:=$(CHK_SOURCES)
    syntax_replace = $(sort \
      $(subst $(SYNTAX_CHECK_REPLACE),$(SYNTAX_CHECK_WITH),$(1)) \
    )
  endif
  TSC_PREFIX := !
  TSC_POSTFIX := $(TSC_POSTFIX) 2>&1 | grep '$(CHK_SOURCES)\:'
endif

# Calc .ts and .d.ts src
$(foreach t,$(TSLIBS),\
  $(eval _$(t)_ts_src := $(call syntax_replace, \
    $(filter-out %.d.ts,$(filter %.ts,$($(t)_src))) \
  )) \
  $(eval _$(t)_d_ts_src := $(filter %.d.ts,$($(t)_src))) \
  $(eval _$(t)_cgfx_src := $(filter %.cgfx,$($(t)_src))) \
  $(eval _$(t)_out_js ?= $(if $(_$(t)_ts_src),$(TS_OUTPUT_DIR)/$(t).js))    \
  $(eval _$(t)_out_d_ts ?= $(if $(_$(t)_ts_src),$(TS_OUTPUT_DIR)/$(t).d.ts)) \
  $(eval _$(t)_out_copy_d_ts := $(if $(_$(t)_d_ts_src),$(addprefix $(TS_OUTPUT_DIR)/,$(notdir $(_$(t)_d_ts_src))))) \
  \
)

# Dep files.  Note that we use the _d_ts_src for dependent decl
# modules, so that the compiler (and any error messages) reference the
# source version rather than the copy.

# _dep_d_files := list of files to actually build against (.d.ts)
# _dep_d_dep_targets := list of build targets we depend upon (.ts)
$(foreach t,$(TSLIBS),\
  $(eval _$(t)_dep_d_files := $(sort         \
    $(foreach d,$($(t)_deps),                \
      $(_$(d)_out_d_ts) $(_$(d)_d_ts_src) $(_$(d)_dep_d_files) \
    )                                        \
  ))                                         \
  $(eval _$(t)_dep_targets := $(sort         \
    $(foreach d,$($(t)_deps),                \
      $(_$(d)_out_js) $(_$(d)_d_ts_src) $(_$(d)_dep_targets)) \
  ))                                         \
)

# Defines rules for .ts to .js
# 1 - module name (define <module>_src, <module>_deps)
define _make_js_rule

  .PHONY : $(1)

  $(1) : $(_$(1)_out_js)

  $(call _mkdir_rule,$(dir $(_$(1)_out_js)))

  $(_$(1)_out_js) : $($(1)_src) $(_$(1)_dep_targets) \
   |$(call _dir_marker,$(dir $(_$(1)_out_js)))
	@echo "[TSC  ] $(notdir $($(1)_src)) -> $$@"
	$(CMDPREFIX) $(TSC_PREFIX)                           \
      $(TSC) $(if $(TS_ALLOW_REFS),,--noResolve)         \
      $(if $($(1)_nodecls),,--declaration)               \
      $($(1)_tscflags)                                   \
      $(if $(TS_NODE_JS),,--out $$@)                     \
      $(TS_BASE_FILES)                                   \
      $(_$(1)_dep_d_files) $(_$(1)_d_ts_src)             \
      $(abspath $(_$(1)_ts_src))                         \
      $(TSC_POSTFIX)

  jslib : $(1)

  # tslint rule

  .PHONY: _tslint_$(1)
  _tslint_$(1) :
	tslint $(if $(TSLINT_CONFIG),-c $(TSLINT_CONFIG),) -f $($(1)_src)

  tslint : _tslint_$(1)

  # Add the module to the syntax-check deps ?

  ifeq (1,$(TS_SYNTAX_CHECK))
    .PHONY: check-syntax
    check-syntax : $(if $(filter $(CHK_SOURCES),$(call syntax_replace,$($(1)_src))),$(1))
  endif

endef

# 1 - modules
define _make_d_ts_copy_rule

  .PHONY : $(1)

  $(1) : $(_$(1)_out_copy_d_ts)

  $(call _mkdir_rule,$(dir $(_$(1)_out_copy_d_ts)))

  $(_$(1)_out_copy_d_ts) : $(_$(1)_d_ts_src) |$(call _dir_marker,$(dir $(_$(1)_out_copy_d_ts)))
	@echo "[CP   ] $(notdir $$^)"
	$(CMDPREFIX)$(CP) $$^ $$(dir $$@)

  jslib : $(1)

endef

$(foreach t,$(TSLIBS),\
  $(if $(_$(t)_ts_src),$(eval $(call _make_js_rule,$(t)))) \
  $(if $(_$(t)_d_ts_src),$(eval $(call _make_d_ts_copy_rule,$(t)))) \
)

# tslint rules (defined in _make_js_rule)

.PHONY: tslint

# clean rules

.PHONY: clean clean_ts distclean_ts

clean_ts:
	$(RM) $(foreach t,$(TSLIBS), \
      $(_$(t)_out_copy_d_ts) $(_$(t)_out_js) $(_$(t)_out_d_ts) \
    )

distclean_ts:
	$(RM) $(TS_OUTPUT_DIR)

clean: clean_ts

distclean: distclean_ts

else # ifeq (1,$(TS_MODULAR))

############################################################
# ONESHOT BUILD
#
# Build everything in a single command.  No timestamp checking, just a
# single huge operation to generate jslib.
#
############################################################

ifeq (1,$(TS_ONESHOT))

# Split the list of all files into those from the tslib source dir and
# those from the generated source dir.  Ensure that there are no
# unexpected entries.

TS_ALL_FILES := $(foreach m,$(TSLIBS),$($(m)_src))
TS_SRC_FILES := $(filter $(TS_SRC_DIR)/%,$(TS_ALL_FILES))

# TS_GEN_FILES is set above
# TS_GEN_FILES := $(filter $(TS_GEN_DIR)/%,$(TS_ALL_FILES))

_ts_unexpected := $(filter-out $(TS_SRC_FILES) $(TS_GEN_FILES),$(TS_ALL_FILES))
ifneq (,$(_ts_unexpected))
  $(error Unexpected source file(s): $(_ts_unexpected))
endif

TSC_POSTFIX := $(tsc_postfix_ignoreerrors)

# Choose a file that is a real .ts file (not .d.ts)
ts_first_src := $(word 1,$(filter-out %.d.ts,$(TS_SRC_FILES)))
ts_src_output := $(subst $(TS_SRC_DIR),$(TS_OUTPUT_DIR),$(ts_first_src:.ts=.js))
ts_first_gen := $(word 1,$(filter-out %.d.ts,$(TS_GEN_FILES)))
ts_gen_output := $(subst $(TS_GEN_DIR),$(TS_OUTPUT_DIR),$(ts_first_gen:.ts=.js))

.PHONY : jslib
jslib: $(ts_src_output) $(ts_gen_output)

# (Windows version of make requires this to be in a 'define' in order
# that the POSTFIX variable gets expanded correctly.

define _make_ts_js_rule
  $(ts_src_output) : $(TS_SRC_FILES)
	@echo "[TSC  ] *.ts -> $(TS_OUTPUT_DIR)"
	$(CMDPREFIX)$(TSC) $(TSC_FLAGS) --outDir $(TS_OUTPUT_DIR) $$^ $(TSC_POSTFIX)

  $(ts_gen_output) : $(TS_GEN_FILES)
	@echo "[TSC  ] (generated) *.ts -> $(TS_OUTPUT_DIR)"
	$(CMDPREFIX)$(TSC) $(TSC_FLAGS) --outDir $(TS_OUTPUT_DIR) $$^ $(TSC_POSTFIX)
endef

$(eval $(call _make_ts_js_rule))

else # ifeq(1,$(TS_ONESHOT))

############################################################
#
# CRUDE BUILD.
#
# Build each file in TSLIBS to the output directory.  All type errors
# are ignored unless TS_REFCHECK == 1.
#
############################################################

ifeq (1,$(TS_REFCHECK))
  TS_OUTPUT_DIR ?= jslib-refcheck
else
  TS_OUTPUT_DIR ?= jslib
endif

TS_FILES := $(foreach m,$(TSLIBS),$($(m)_src))

ifeq (1,$(TS_REFCHECK))
  TSC_FLAGS := #--failonerror
  TSC_POSTFIX := $(tsc_postfix_failonerror)
else
  TSC_FLAGS := --noResolve
  TSC_POSTFIX := $(tsc_postfix_ignoreerrors)
endif

# Override if we are syntax checking

ifeq (1,$(TS_SYNTAX_CHECK))

  .PHONY : check-syntax
  check-syntax: $(TS_OUTPUT_DIR)/.syntax_check.js

  .PHONY : $(TS_OUTPUT_DIR)/.syntax_check.js
  ts_js_files:=$(foreach ts,$(CHK_SOURCES),$(ts)!$(TS_OUTPUT_DIR)/.syntax_check.js)

else

  ts_js_files := $(foreach ts,$(filter-out %.d.ts,$(TS_FILES)),   \
    $(ts)!$(subst $(TS_GEN_DIR),$(TS_OUTPUT_DIR),$(subst $(TS_SRC_DIR),$(TS_OUTPUT_DIR),$(ts:.ts=.js))) \
  )

endif

# $(warning ts_js_files = $(ts_js_files))

_getsrc = $(word 1,$(subst !, ,$(1)))
_getdst = $(word 2,$(subst !, ,$(1)))

.PHONY : jslib
jslib:

# 1 - src
# 2 - dst
define _make_ts_js_rule

  $(call _mkdir_rule,$(dir $(2)))

  $(2) : $(1) |$(call _dir_marker,$(dir $(2)))
	@echo "[TSC  ] $$< -> $$@"
	$(CMDPREFIX)$(TSC) $(TSC_FLAGS) --out $(2) $(1) $(TSC_POSTFIX)
	$(if $(VERIFY_CLOSURE),\
      $(CMDPREFIX)echo "[CLOSURE]" $(2) ; $(CLOSURE) --js $(2) \
    )

  jslib : $(2)

  ifeq (1,$(TS_SYNTAX_CHECK))
    check-syntax : $(2)
  endif

endef

$(foreach ts_js,$(ts_js_files),$(eval                                        \
  $(call _make_ts_js_rule,$(call _getsrc,$(ts_js)),$(call _getdst,$(ts_js))) \
))

.PHONY: clean_ts distclean_ts

clean_ts:
	$(RM) $(foreach ts_js,$(ts_js_files),$(call _getdst,$(ts_js)))

distclean_ts:
	$(RM) $(TS_OUTPUT_DIR)

clean: clean_ts

distclean: distclean_ts

endif # else # ifeq (1,$(TS_ONESHOT))

endif # else # ifeq (1,$(TS_MODULAR))
