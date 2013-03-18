# Copyright (c) 2013 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

# Make SYNTAX_CHECK_MODE use non-modular refcheck mode

ifeq (1,$(SYNTAX_CHECK_MODE))
  TS_MODULAR := 0
  TS_REFCHECK := 1
  ifneq (,$(filter %.ts,$(CHK_SOURCES)))
    TS_SYNTAX_CHECK := 1
  endif
endif
# $(warning TS_SYNTAX_CHECK = $(TS_SYNTAX_CHECK))

TS_MODULAR ?= 1
ifeq (1,$(TS_REFCHECK))
  TS_MODULAR := 0
endif

CLOSURE:=java -jar external/closure/compiler.jar \
  --compilation_level WHITESPACE_ONLY \
  --js_output_file /dev/null

ifeq (1,$(TS_MODULAR))

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

TS_OUTPUT_DIR ?= jslib-modular
TS_SYNTAX_CHECK := 0

# Syntax checking
ifeq (1,$(TS_SYNTAX_CHECK))
  ifneq (,$(filter %_flymake.ts,$(CHK_SOURCES)))
    SYNTAX_CHECK_REPLACE:=$(CHK_SOURCES:_flymake.ts=.ts)
    SYNTAX_CHECK_WITH:=$(CHK_SOURCES)
  endif
endif

syntax_replace = $(subst $(SYNTAX_CHECK_REPLACE),$(SYNTAX_CHECK_WITH),$(1))

# Calc .ts and .d.ts src
$(foreach t,$(TSLIBS),\
  $(eval _$(t)_ts_src := $(call syntax_replace,$(filter-out %.d.ts,$($(t)_src)))) \
  $(eval _$(t)_d_ts_src := $(filter %.d.ts,$($(t)_src))) \
  $(eval _$(t)_out_js ?= $(if $(_$(t)_ts_src),$(TS_OUTPUT_DIR)/$(t).js))    \
  $(eval _$(t)_out_d_ts ?= $(if $(_$(t)_ts_src),$(TS_OUTPUT_DIR)/$(t).d.ts)) \
  $(eval _$(t)_out_copy_d_ts := $(if $(_$(t)_d_ts_src),$(addprefix $(TS_OUTPUT_DIR)/,$(notdir $(_$(t)_d_ts_src))))) \
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
	@echo "[TSC  ] $$< -> $$@"
	$(CMDPREFIX)$(TSC) -c --failonerror --noresolve      \
      $(if $($(1)_nodecls),,--declaration)               \
      $(if $(CHK_SOURCES),--filter $(CHK_SOURCES))       \
      --out $$@ $(TS_BASE_FILES)                         \
      $(_$(1)_dep_d_files) $(_$(1)_d_ts_src) $(abspath $(_$(1)_ts_src))

  jslib : $(1)

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
	$(CP) $$^ $$(dir $$@)

  jslib : $(1)

endef

$(foreach t,$(TSLIBS),\
  $(if $(_$(t)_ts_src),$(eval $(call _make_js_rule,$(t)))) \
  $(if $(_$(t)_d_ts_src),$(eval $(call _make_d_ts_copy_rule,$(t)))) \
)

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
  TSC_FLAGS := -c --failonerror
else
  TSC_FLAGS := -c --noresolve --ignoretypeerrors
endif

# Override if we are syntax checking

ifeq (1,$(TS_SYNTAX_CHECK))

  .PHONY : check-syntax
  check-syntax: $(TS_OUTPUT_DIR)/.syntax_check.js

  .PHONY : $(TS_OUTPUT_DIR)/.syntax_check.js
  ts_js_files:=$(foreach ts,$(CHK_SOURCES),$(ts)!$(TS_OUTPUT_DIR)/.syntax_check.js)

else

  ts_js_files := $(foreach ts,$(filter-out %.d.ts,$(TS_FILES)),   \
    $(ts)!$(subst $(TS_SRC_DIR),$(TS_OUTPUT_DIR),$(ts:.ts=.js)) \
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
	$(CMDPREFIX)$(TSC) $(TSC_FLAGS) --out $(2) $(1)
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

endif # else # ifeq (1,$(TS_MODULAR))
