# Copyright (c) 2012-2014 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

############################################################

all:

C_MODULES := $(LIBS) $(DLLS) $(APPS)
$(call log,C_MODULES = $(C_MODULES))

ifeq (1,$(SYNTAX_CHECK_MODE))
  ifneq (,$(filter %.c,$(CHK_SOURCES))$(filter %.cpp,$(CHK_SOURCES))$(filter %.cpp,$(CHK_SOURCES)))
    C_SYNTAX_CHECK := 1
    # $(warning CHK_SOURCES = $(CHK_SOURCES))
  endif
endif
# $(warning C_SYNTAX_CHECK = $(C_SYNTAX_CHECK))

############################################################

space:= #
cdeps?= -MP -MD -MF
cout?=-o$(space)
cobj?=.o
cdeptarget?=-MT
cdeptargetpre?=
cdeptargetpost?=

libprefix?=lib
libsuffix?=.a

dllout?= -o #

#
# Platform Checks
#
# (these checks are performed here so they don't cause terminal errors
#  for clients who aren't building C++ apps).

ifeq (macosx,$(TARGETNAME))

  # Check which SDK version we have available
  ifeq (,$(shell $(MACOSX_XCODE_BIN_PATH)xcodebuild -showsdks | grep macosx$(XCODE_SDK_VER)))
    $(error Cant find SDK version $(XCODE_SDK_VER))
  endif

  # Check the SDK ROOT location
  ifeq (,$(wildcard $(XCODE_SDK_ROOT)))
    $(error couldnt find SDK dir)
  endif

endif

############################################################

#
# Full deps
#

# 1 - mod
#
# Not the clearest piece of code in the world, but ...
#
# For each dependencies of $(1), recursively calculate their full
# dependencies.  Then, with the full deep dependencies of our deps
# calculated, iterate through all dependencies, adding new words on
# the left so that the deepest dependencies appear on the right (to
# satisfy the gcc linker)
#
define _calc_fulldeps

  # Make sure each dep has been calculated
  $(foreach d,$($(1)_deps), \
    $(if $(filter $(d),$(LIBS) $(DLLS)),, \
      $(error $(1)_deps contains '$(d)' which is not a LIB or DLL) \
    ) \
    $(if $($(d)_depsdone),$(call log,$(d) deps already done),$(eval \
      $(call _calc_fulldeps,$(d)) \
    )) \
  )

  # For each dep, add any words in $(dep)_fulldeps not already in $(1)_fulldeps
  $(foreach d,$($(1)_deps), \
   $(if $(filter $(d),$($(1)_fulldeps)),$(call log,$(d) already in fulldeps),\
     $(eval $(1)_depstoadd := ) \
     $(foreach dd,$($(d)_fulldeps), \
      $(if $(filter $(dd),$($(1)_fulldeps)),$(call log,dep $(dd) already in list for $(d)),\
       $(call log,adding dep $(dd))\
       $(eval $(1)_depstoadd := $($(1)_depstoadd) $(dd))\
       $(call log,depstoadd: $($(1)_depstoadd))\
      )\
     )\
     $(eval $(1)_fulldeps := $(d) $($(1)_depstoadd) $($(1)_fulldeps)) \
   )\
  )

  $(1)_depsdone:=1
  $(call log,Deps for $(1): $($(1)_fulldeps))

endef

$(foreach mod,$(C_MODULES),$(eval \
  $(call _calc_fulldeps,$(mod)) \
))


$(foreach mod,$(C_MODULES),$(call log,$(mod)_fulldeps = $($(mod)_fulldeps)))

############################################################

ifeq (1,$(ABSPATHS))
  # call full paths of all source files
  # ifneq (1,$(C_SYNTAX_CHECK))
  # $(call log,standalone_src = $(standalone_src))
  $(foreach mod,$(C_MODULES),$(eval                          \
	$(mod)_src := $(foreach s,$($(mod)_src),                 \
	  $(if $(realpath $(s)),$(realpath $(s)),$(s))           \
	)                                                        \
  ))
  # endif
  # $(call log,standalone_src = $(standalone_src))
endif

# calc <mod>_headerfile all headers belonging to this module
$(foreach mod,$(C_MODULES),$(eval \
  $(mod)_headerfiles := $(foreach i,$($(mod)_incdirs),$(wildcard $(i)/*.h)) \
))

ifeq (1,$(ABSPATHS))
  # calc full paths of all incdirs and libdirs (including externals)
  $(foreach mod,$(C_MODULES) $(EXT),$(eval \
	$(mod)_incdirs := $(foreach i,$($(mod)_incdirs),$(realpath $(i))) \
  ))
  $(call log,javascriptcore_incdirs = $(javascriptcore_incdirs))
endif

# calc full path of each <ext>_libdir
$(foreach ext,$(EXT), \
  $(eval $(ext)_libdir:=$(strip $(foreach l,$($(ext)_libdir),$(realpath $(l)))))\
)
$(call log,javascriptcore_libdir = $(javascriptcore_libdir))

# calc full path of external dlls
$(foreach ext,$(EXT), \
  $(eval $(ext)_dlls := \
    $(foreach l,$($(ext)_lib), \
      $(foreach d,$($(ext)_libdir), \
        $(wildcard $(d)/$(libprefix)$(l)$(dllsuffix)*) \
      ) \
    ) \
    $(filter-out %$(libsuffix),$($(ext)_libfile)) \
  ) \
)

# if it's a platform with .lib files accompanying .dlls (i.e. Windows)
# where we don't include input .dlls int he link commnd line, filter
# the dlls out from <ext>_libfiles, now that we have the list of dlls
# to copy.
ifneq (,$(dlllibsuffix))
  $(foreach ext,$(EXT),$(eval \
    $(ext)_libfile := $(filter-out %$(dllsuffix),$($(ext)_libfile)) \
  ))
endif

$(call log,javascriptcore_dlls = $(javascriptcore_dlls))
$(call log,openal_libfile = $(openal_libfile))
$(call log,dllsuffix = $(dllsuffix))
$(call log,openal_libfile filtered = $(filter %$(dllsuffix),$(openal_libfile)))
$(call log,openal_dlls = $(openal_dlls))

# calc <mod>_depincdirs - include dirs from dependencies
$(foreach mod,$(C_MODULES),$(eval \
  $(mod)_depincdirs := $(foreach d,$($(mod)_fulldeps),$($(d)_incdirs)) \
))

# # calc <mod>_depheaderfiles - include files of dependencies
# $(foreach mod,$(C_MODULES),$(eval \
#   $(mod)_depheaderfiles := $(foreach d,$($(mod)_fulldeps),$($(d)_headerfiles)) \
# ))

# calc <mod>_depcxxflags
$(foreach mod,$(C_MODULES),$(eval \
	$(mod)_depcxxflags := $(foreach d,$($(mod)_fulldeps),$($(d)_cxxflags)) \
))

# cal <mod>_depextlibs - libs from dependencies
$(foreach mod,$(C_MODULES),$(eval \
  $(mod)_depextlibs := $(foreach d,$($(mod)_fulldeps),$($(d)_extlibs)) \
))
$(call log,npturbulenz_depextlibs = $(npturbulenz_depextlibs))

# calc external include dirs
$(foreach mod,$(C_MODULES),$(eval \
  $(mod)_ext_incdirs := $(foreach e,$($(mod)_extlibs) $($(mod)_depextlibs),$($(e)_incdirs)) \
))

# calc external lib dirs
$(foreach mod,$(C_MODULES),$(eval \
  $(mod)_ext_libdirs := $(foreach e,$($(mod)_extlibs) $($(mod)_depextlibs), \
    $($(e)_libdir) \
  ) \
))

# calc external libs.
#  <extlib>_lib      values are prefixed with -l
#  <extlib>_libfiles values are included as-is
$(foreach mod,$(C_MODULES),\
  $(eval $(mod)_ext_lib_files :=                          \
    $(foreach e,$($(mod)_extlibs) $($(mod)_depextlibs),   \
      $(if $(filter $(e),$(EXT)),,                        \
        $(error $(mod)_extlibs contains '$(e)', not in EXT) \
      )                                                   \
      $($(e)_libfile)                                     \
  ))                                                      \
  $(eval $(mod)_ext_lib_flags :=                          \
    $(foreach e,$($(mod)_extlibs) $($(mod)_depextlibs),   \
      $(addprefix $(DLLFLAGS_LIB),$($(e)_lib))            \
      $($(e)_libfile)                                     \
  ))                                                      \
)

# calc the full list of external dynamic libs for apps and dlls
$(foreach b,$(DLLS) $(APPS),\
  $(eval $(b)_ext_dlls := \
    $(foreach e,$($(b)_extlibs) $($(b)_depextlibs),$($(e)_dlls)) \
  ) \
)
$(call log,npturbulenz_ext_dlls = $(npturbulenz_ext_dlls))

############################################################

# External dlls need to be copied to bin

# 1 - module name
# 2 - dest
# 3 - src
ifneq (1,$(DISABLE_COPY_EXTERNAL_DLLS))
  define _copy_dll_rule

    $($(1)_dllfile) $($(1)_appfile) : $(2)

    $(2) :: $(3)
	  @$(MKDIR) -p $$(dir $$@)
	  @echo [COPY-DLL] \($(1)\) $$(notdir $$<)
	  $(CMDPREFIX) $(CP) $$^ $$@

  endef
endif


# 1 - EXT name
define _null_external_dll

  .PHONY : $(1)
  $(1) :

endef

############################################################

# calc <mod>_OBJDIR
$(foreach mod,$(C_MODULES),$(eval $(mod)_OBJDIR := $(OBJDIR)/$(mod)))

# calc <mod>_DEPDIR
$(foreach mod,$(C_MODULES),$(eval $(mod)_DEPDIR := $(DEPDIR)/$(mod)))

#
# For unity builds, replace the src list with a single file, and a
# rule to create it.
#

ifeq (1,$(C_SYNTAX_CHECK))
  UNITY := 0
endif

ifeq ($(UNITY),1)

# 1 - mod
define _make_cxx_unity_file

  $($(1)_src) : $($(1)_unity_src)
	@$(MKDIR) -p $($(1)_OBJDIR)
	echo > $$@
	for i in $$^ ; do echo \#include \"$$$$i\" >> $$@ ; done

endef

$(foreach mod,$(C_MODULES),\
  $(if $(filter 1,$($(mod)_unity)),                         \
    $(eval $(mod)_unity_src := $($(mod)_src)) 	            \
    $(eval $(mod)_src := $($(mod)_OBJDIR)/$(mod)_unity.cpp) \
    $(eval $(call _make_cxx_unity_file,$(mod)))             \
  )                                                         \
)

$(call log, core_unity_src = $(core_unity_src))
$(call log, core_src = $(core_src))

endif #($(UNITY),1)

#
# Precopiled headers
#

# for each module, if _pch is set, we need vars:
$(foreach mod,$(C_MODULES), \
  $(if $($(mod)_pch), \
    $(eval \
      _$(mod)_pchfile := $($(mod)_OBJDIR)/$(notdir $($(mod)_pch:.h=.h.gch)) \
    ) \
    $(eval \
      _$(mod)_pchdep := $($(mod)_DEPDIR)/$(notdir $($(mod)_pch:.h=.h.d)) \
    ) \
  ) \
)

#
# For each module, create cxx_obj_dep list
#

# 1 - module name
define _make_cxx_obj_dep_list
  $(1)_cxx_obj_dep := \
    $(foreach s,$(filter %.cpp,$($(1)_src)), \
      $(s)!$($(1)_OBJDIR)/$(notdir $(s:.cpp=$(cobj)))!$($(1)_DEPDIR)/$(notdir $(s:.cpp=.d)) \
     ) \
    $(foreach s,$(filter %.c,$($(1)_src)), \
      $(s)!$($(1)_OBJDIR)/$(notdir $(s:.c=$(cobj)))!$($(1)_DEPDIR)/$(notdir $(s:.c=.d)) \
     ) \
    $(foreach s,$(filter %.cc,$($(1)_src)), \
      $(s)!$($(1)_OBJDIR)/$(notdir $(s:.cc=$(cobj)))!$($(1)_DEPDIR)/$(notdir $(s:.cc=.d)) \
     )
endef

# 1 - module name
define _make_cmm_obj_dep_list
  $(1)_cmm_obj_dep := $(foreach s,$(filter %.mm,$($(1)_src)), \
    $(s)!$($(1)_OBJDIR)/$(notdir $(s:.mm=.mm.o))!$($(1)_DEPDIR)/$(notdir $(s:.mm=.mm.d)) \
  )
endef

$(foreach mod,$(C_MODULES),                        \
  $(eval $(call _make_cxx_obj_dep_list,$(mod)))  \
)

# only look for .mm's on mac and ios

ifneq (,$(filter macosx ios,$(TARGETNAME)))
  $(foreach mod,$(C_MODULES), $(eval \
    $(call _make_cmm_obj_dep_list,$(mod)) \
  ))
endif

$(call log,standalone_src = $(npengine_src))
$(call log,standalone_cxx_obj_dep = $(npengine_cxx_obj_dep))
$(call log,standalone_cmm_obj_dep = $(npengine_cmm_obj_dep))

#
# Functions for getting src, obj and dep files
#

_getsrc = $(word 1,$(subst !, ,$(1)))
_getobj = $(word 2,$(subst !, ,$(1)))
_getdep = $(word 3,$(subst !, ,$(1)))

#
# For each modules, calculate the full object list and full depfile list
#

$(foreach mod,$(C_MODULES),$(eval \
  $(mod)_OBJECTS := \
    $(foreach sod,$($(mod)_cxx_obj_dep),$(call _getobj,$(sod))) \
    $(foreach sod,$($(mod)_cmm_obj_dep),$(call _getobj,$(sod))) \
))

$(foreach mod,$(C_MODULES),$(eval \
  $(mod)_DEPFILES :=                                            \
    $(_$(mod)_pchdep)                                           \
    $(foreach sod,$($(mod)_cxx_obj_dep),$(call _getdep,$(sod))) \
    $(foreach sod,$($(mod)_cmm_obj_dep),$(call _getdep,$(sod))) \
))
$(call log,npengine_DEPFILES = $(npengine_DEPFILES))

#
# Flags
#

# 1 - mod
# 2 - flags file
# 3 - flags string
define _make_cxx_flags_file
  ifneq ('$(shell $(CAT) $(2))','$(strip $(3))')
    # $$(info .flags: '$$(shell cat $(2) 2>/dev/null)')
    # $$(info new fl: '$$(strip $(3))')

    $$(shell $(MKDIR) -p $($(1)_OBJDIR))
    $$(shell $(MKDIR) -p $($(1)_OBJDIR))
    $$(shell echo '$(strip $(3))' > $(2))
  endif

  $($(1)_OBJECTS) : $(2)

endef

ifneq (1,$(DISABLE_FLAG_CHECKS))
$(foreach mod,$(C_MODULES),$(eval \
  $(call _make_cxx_flags_file,$(mod),$($(mod)_OBJDIR)/.flags, $(strip   \
    $(CXXFLAGSPRE) $(CXXFLAGS) $($(mod)_depcxxflags) $($(mod)_cxxflags) \
    $($(mod)_local_cxxflags)                                            \
    $(addprefix -I,$($(mod)_incdirs))                                   \
    $(addprefix -I,$($(mod)_depincdirs))                                \
    $(addprefix -I,$($(mod)_ext_incdirs))                               \
    $(CXXFLAGSPOST)                                                     \
  ))                                                                    \
))
endif

#
# Function to make a flymake target for a source file
#

# 1 - flymake src
# 2 - module_name
define _target_flymake_src

  _fm_found += \
    $(filter $(1)%,$($(2)_cxx_obj_dep) $($(2)_cmm_obj_dep))

endef

ifeq (1,$(C_SYNTAX_CHECK))
  FLYMAKESRC:=$(strip $(abspath $(CHK_SOURCES)))
  $(foreach mod,$(C_MODULES),\
    $(eval $(call _target_flymake_src,$(FLYMAKESRC),$(mod))) \
  )

  # $(warning _fm_found: $(_fm_found))
  ifneq (,$(strip $(_fm_found)))
    $(foreach mod,$(C_MODULES),\
      $(eval $(mod)_cxx_obj_dep := $(subst $(FLYMAKESRC),$(CHK_SOURCES),$($(mod)_cxx_obj_dep))) \
      $(eval $(mod)_cmm_obj_dep := $(subst $(FLYMAKESRC),$(CHK_SOURCES),$($(mod)_cmm_obj_dep))) \
    )

    # $(warning standalone_cxx_obj_dep = $(standalone_cxx_obj_dep))
    # $(warning standalone_cmm_obj_dep = $(standalone_cmm_obj_dep))

    _obj := $(call _getobj,$(_fm_found))

    .PHONY : $(_obj)
    check-syntax: $(_obj)

  else
    ifneq (android,$(TARGET))
      check-syntax:
	    $(MAKE) -s CHK_SOURCES=$(CHK_SOURCES) SYNTAX_CHECK_MODE=1 TARGET=android check-syntax
    endif
  endif

endif

#
# For each module, create the object build rules, generating the
# dependency files as a side-effect of a single run.
#

# 1 - mod
# 2 - .h source file
# 3 - .h.pch dest file
# 4 - depfile
define _make_pch_rule

  .PRECIOUS : $(3)

  $(3) : $(2)
	@$(MKDIR) -p $($(1)_OBJDIR) $($(1)_DEPDIR)
	@echo [PCH $(ARCH)] \($(1)\) $$(notdir $$@)
	$(CMDPREFIX)$(CXX)                                              \
      $(CXXFLAGSPRE) $(CXXFLAGS)                                    \
      $(cdeps) $4 $(cdeptarget) $(cdeptargetpre)$4$(cdeptargetpost) \
      $(cdeptarget) $(cdeptargetpre)$$@$(cdeptargetpost)            \
      $($(1)_depcxxflags) $($(1)_cxxflags) $($(1)_local_cxxflags)   \
      $(addprefix -I,$($(1)_incdirs))                               \
      $(addprefix -I,$($(1)_depincdirs))                            \
      $(addprefix -I,$($(1)_ext_incdirs))                           \
      $(CXXFLAGSPOST) $($(call file_flags,$(2)))                    \
      $(PCHFLAGS)                                                   \
      $$< $(cout) $$@


endef

# 1 - mod
# 2 - cxx srcfile
# 3 - object file
# 4 - depfile
define _make_cxx_object_rule

  .PRECIOUS : $(3)

  $(3) : $(2) $(_$1_pchfile)
	$(CMDPREFIX)$(MKDIR) $($(1)_OBJDIR) $($(1)_DEPDIR)
	@echo [CXX $(TARGET)-$(ARCH)] \($(1)\) $$(notdir $$<)
	$(CMDPREFIX)$(CXX)                                             \
      $(if $(_$1_pchfile),-include $(_$1_pchfile:.gch=))           \
      $(CXXFLAGSPRE) $(CXXFLAGS)                                   \
      $(if $(DISABLE_DEP_GEN),, \
        $(cdeps) $4 $(cdeptarget) $(cdeptargetpre)$4$(cdeptargetpost) \
        $(cdeptarget) $(cdeptargetpre)$$@$(cdeptargetpost) \
      ) \
      $($(1)_depcxxflags) $($(1)_cxxflags) $($(1)_local_cxxflags)  \
      $(addprefix -I,$($(1)_incdirs))                              \
      $(addprefix -I,$($(1)_depincdirs))                           \
      $(addprefix -I,$($(1)_ext_incdirs))                          \
      $(CXXFLAGSPOST) $($(call file_flags,$(2)))                   \
      $(cout)$$@ $(csrc) $$< || ($(RM) $(4) && exit 1)
	$(call cxx-post,$(1),$(2),$(3),$(4))

  $(2):

  $(4):

  $(3).S : $(3)
	@echo [DISASS] \($(1)\) $$@
	$(OBJDUMP) $(OBJDUMP_DISASS) $$< > $$@

  $(1)_asm : $(3).S

endef

# 1 - mod
# 2 - mm srcfile
# 3 - object file
# 4 - depfile
define _make_cmm_object_rule

  .PRECIOUS : $(3)

  $(3) : $(2) $(_$1_pchfile)
	@mkdir -p $($(1)_OBJDIR) $($(1)_DEPDIR)
	@echo [CMM $(ARCH)] \($(1)\) $$(notdir $$<)
	$(CMDPREFIX)$(CMM)                                              \
      $(if $(_$1_pchfile),-include $(_$1_pchfile:.gch=))            \
      $(CMMFLAGSPRE) $(CMMFLAGS)                                    \
      $(cdeps) $4 $(cdeptarget) $(cdeptargetpre)$4$(cdeptargetpost) \
      $(cdeptarget) $(cdeptargetpre)$$@$(cdeptargetpost)            \
      $($(1)_cxxflags) $($(1)_depcxxflags)                          \
      $(addprefix -I,$($(1)_incdirs))                               \
      $(addprefix -I,$($(1)_depincdirs))                            \
      $(addprefix -I,$($(1)_ext_incdirs))                           \
      $(CMMFLAGSPOST) $($(call file_flags,$(2)))                    \
      $$< $(cout) $$@

endef

# DEPS WERE:
# $(2) $($(1)_headerfiles) $($(1)_depheaderfiles)

# 1 - mod
define _make_object_rules

  $(if $(_$(1)_pchfile), \
    $(call _make_pch_rule,$(1),$($(1)_pch),$(_$(1)_pchfile),$(_$(mod)_pchdep)) \
  )

  $(foreach sod,$($(1)_cxx_obj_dep),$(eval \
    $(call _make_cxx_object_rule,$(1),$(call _getsrc,$(sod)),$(call _getobj,$(sod)),$(call _getdep,$(sod))) \
  ))

  $(foreach sod,$($(1)_cmm_obj_dep),$(eval \
    $(call _make_cmm_object_rule,$(1),$(call _getsrc,$(sod)),$(call _getobj,$(sod)),$(call _getdep,$(sod))) \
  ))

  # Define the phony _asm target for this module
  .PHONY: $(1)_asm

endef

$(foreach mod,$(C_MODULES),$(eval $(call _make_object_rules,$(mod))))

############################################################

# LIBRARY

# set <lib>_libfile
$(foreach lib,$(LIBS),$(eval \
  $(lib)_libfile ?= $(LIBDIR)/$(libprefix)$(lib)$(libsuffix) \
))

# <mod>_deplibs = all libraries we depend upon
# depend on the libs for all dependencies
$(foreach mod,$(C_MODULES),                                                 \
  $(eval $(mod)_deplibs := $(foreach d,$($(mod)_fulldeps),$($(d)_libfile))) \
  $(eval $(mod)_deplibs_cmdline :=                                          \
    $(foreach d,$($(mod)_fulldeps),                                         \
      $(if $($(d)_keepsymbols),                                             \
        $(DLLKEEPSYM_PRE) $($(d)_libfile) $(DLLKEEPSYM_POST),               \
        $($(d)_libfile))                                                    \
       ))                                                                   \
)

$(foreach mod,$(C_MODULES),$(eval \
  $(mod)_deplibs_cmdline := $(foreach d,$($(mod)_fulldeps),\
    $(if $($(d)_keepsymbols), \
      $(DLLKEEPSYM_PRE) $($(d)_libfile) $(DLLKEEPSYM_POST), \
      $($(d)_libfile)) \
  ) \
))

# each lib depends on the object files for that module

# 1 - mod
define _make_lib_rule

  $($(1)_libfile) : $($(1)_OBJECTS)
	$(CMDPREFIX)$(MKDIR) $$(dir $$@)
	@echo [AR  $(TARGET)-$(ARCH)] $$(notdir $$@)
	$(CMDPREFIX)$(RM) $$@
	$(CMDPREFIX)$(AR) \
     $(ARFLAGSPRE) \
     $(arout)$$@ \
     $($(1)_OBJECTS) \
      $(ARFLAGSPOST) \

  .PHONY : $(1)

  $(1) : $($(1)_libfile)

endef

$(foreach lib,$(LIBS),$(eval \
  $(call _make_lib_rule,$(lib)) \
))

############################################################

# DLLS

# 1 - dll
define _make_dll_paths
  $(1)_dllfile ?= $(BINDIR)/$(dllprefix)$(dll)$(dllsuffix)
  $(1)_pdbfile ?= $$($(1)_dllfile:$(dllsuffix)=$(pdbsuffix))
  $(1)_dlllibfile ?= $$($(1)_dllfile:$(dllsuffix)=$(dlllibsuffix))
endef

# calc <dll>_dllfile
$(foreach dll,$(DLLS),$(eval \
  $(call _make_dll_paths,$(dll)) \
))

# $(info core_dllfile = $(core_dllfile))
# $(info core_pdbfile = $(core_pdbfile))
# $(info core_dlllibfile = $(core_dlllibfile))

# rules to copy the dependent dlls
$(foreach dll,$(DLLS), \
  $(foreach d,$($(dll)_ext_dlls),$(eval \
    $(call _copy_dll_rule,$(dll),$(dir $($(dll)_dllfile))/$(notdir $(d)),$(d)) \
  )) \
)

# 1 - module
define _make_dll_rule

  $($(1)_dllfile) : $($(1)_deplibs) $($(1)_OBJECTS) $($(1)_ext_lib_files)
	@$(MKDIR) -p $$(dir $$@)
	@echo [DLL $(TARGET)-$(ARCH)] $$@
	$(CMDPREFIX)$(DLL) $(DLLFLAGSPRE) \
      $($(1)_DLLFLAGSPRE) \
      $(dllout)$$@ \
      $(if $(pdbsuffix),$(DLLFLAGS_PDB)$($(1)_pdbfile)) \
      $(if $(dlllibsuffix),$(DLLFLAGS_DLLLIB)$($(1)_dlllibfile)) \
      $(if $(DLLFLAGS_LIBDIR), \
        $(addprefix $(DLLFLAGS_LIBDIR),$(LIBDIR)) \
        $(addprefix $(DLLFLAGS_LIBDIR),$($(1)_ext_libdirs)) \
      ) \
      $($(1)_OBJECTS) \
      $($(1)_deplibs_cmdline) \
      $($(1)_ext_lib_flags) \
      $(DLLFLAGSPOST) \
      $($(1)_DLLFLAGSPOST)
	$(call dll-post,$(1))
	$(if $($(1)_poststep),($($(1)_poststep)) || $(RM) -f $$@)

  .PHONY : $(1)
  $(1) : $($(1)_dllfile)

endef

# rule to make dll file
$(foreach dll,$(DLLS),$(eval \
  $(call _make_dll_rule,$(dll)) \
))

# $(warning therun_ext_lib_files = $(therun_ext_lib_files))
# $(warning therun_ext_lib_flags = $(therun_ext_lib_flags))

############################################################

# APPLICATIONS

# calc <app>_appfile
$(foreach app,$(APPS),$(eval \
  $(app)_appfile ?= $(BINDIR)/$(app)$(binsuffix) \
))

# calc <app>_depdlls (for platforms that dont have export libs
# associated with DLLS)
ifeq (,$(dlllibsuffix))
  $(foreach app,$(APPS),$(eval \
    $(app)_depdlls := $(foreach d,$($(app)_fulldeps),$($(d)_dllfile)) \
  ))
endif

# rules to copy the dependent dlls
$(foreach app,$(APPS),                                                         \
  $(foreach a,$($(app)_ext_dlls),$(eval                                        \
    $(call _copy_dll_rule,$(app),$(dir $($(app)_appfile))/$(notdir $(a)),$(a)) \
  ))                                                                           \
)

# 1 - mod
define _make_app_rule

  $($(1)_appfile) : $($(1)_deplibs) $($(1)_depdlls) $($(1)_OBJECTS) \
  $($(1)_ext_lib_files)
	@$(MKDIR) -p $$(dir $$@)
	@echo [LD  $(TARGET)-$(ARCH)] $$@
	$(CMDPREFIX)$(LD) $(LDFLAGSPRE) \
      $(addprefix $(LDFLAGS_LIBDIR),$(LIBDIR)) \
      $(addprefix $(LDFLAGS_LIBDIR),$($(1)_ext_libdirs)) \
      $($(1)_OBJECTS) \
      $($(1)_deplibs) \
      $($(1)_depdlls) \
      $($(1)_ext_lib_flags) \
      $(LDFLAGSPOST) \
      $($(1)_LDFLAGS) \
      -o $$@
	$(call app-post,$(1))
	$($(1)_poststep)

  .PHONY : $(1)
  $(1) : $($(1)_appfile)

endef

# rule to make app file
$(foreach app,$(APPS),$(eval \
  $(call _make_app_rule,$(app)) \
))

# <mod>_run rule

# 1 - mod
define _run_app_rule

  .PHONY : $(1)_run
  $(1)_run : $(1)
	$(RUNPREFIX) $(call _run_prefix,$(1)) $($(1)_appfile)

endef

$(foreach app,$(APPS),$(eval \
  $(call _run_app_rule,$(app)) \
))

############################################################

# BUNDLES  (macosx only)

$(foreach b,$(BUNDLES),\
  $(if $($(b)_version),,$(error $(b) has no version set)) \
  $(if $($(b)_bundlename),,$(error $(b) has no bundlename set)) \
  $(eval $(b)_bundle := $(BINDIR)/$(b).plugin) \
  $(eval $(b)_copylibs := $($(b)_ext_dlls) $($(b)_bundle_extra_files)) \
)

# Fill out the bundle
# 1 - module name
# 2 - bundle location
# 3 - main dll file
# 4 - dependent libs
define _make_bundle_rule

  .PHONY : $(2)

  $(2) : $(3)
	@echo [MAKE BUNDLE] $(2)
	$(CMDPREFIX)rm -rf $(2)
	$(CMDPREFIX)mkdir -p $(2)/Contents/MacOS
	$(CMDPREFIX)cp $(3) $(2)/Contents/MacOS
	$(CMDPREFIX)$(BUILDDIR)/build-infoplist.py \
      --bundlename '$($(1)_bundlename)' \
      --executable `basename $(3)` \
      --version $($(1)_version) > $(2)/Contents/Info.plist
	$(CMDPREFIX)for l in $(4) ; do \
      cp $$$$l $(2)/Contents/MacOS; \
    done

  $(1) : $(2)

endef

ifeq ($(TARGET),macosx)
  $(foreach b,$(BUNDLES),$(eval \
    $(call _make_bundle_rule,$(b),$($(b)_bundle),$($(b)_dllfile),$($(b)_copylibs)) \
  ))
endif

############################################################

# APKS (android only)

APK_CONFIG := $(if $(ANDROID_KEY_STORE),$(CONFIG),debug)

# For each apk, calc the destination and full set of native libs to
# copy
$(foreach apk,$(APKS),														\
  $(eval $(apk)_apk_dest := $(BINOUTDIR)/$(apk))							\
  $(eval																	\
     $(apk)_version := $(if $($(apk)_version),$($(apk)_version),1.0.0)		\
  )																			\
  $(eval $(apk)_apk_file :=													\
    $($(apk)_apk_dest)/bin/$(apk)-$(strip $($(apk)_version))-$(APK_CONFIG).apk \
  )																			\
  $(eval																	\
    $(apk)_archs := $(if $($(apk)_archs),$($(apk)_archs),$(ARCH))			\
  )																			\
)
$(call log,android_engine_dest = $(android_engine_dest))
$(call log,android_engine_copylibs = $(android_engine_copylibs))
$(call log,android_engine_file = $(android_engine_file))

# For each APK, <apk>_apk_fulldeps := \
#     [ <d>_apk_fulldeps for d in <apk>_deps ]

$(foreach apk,$(APKS),                                          \
  $(eval $(apk)_apk_fulldeps :=                                 \
    $(foreach d,$($(apk)_deps),$($(d)_apk_dest) $($(d)_apk_fulldeps)) \
  )                                                             \
)

# $(warning android_online_deps = $(android_online_deps))
# $(warning android_online_apk_fulldeps = $(android_online_apk_fulldeps))

$(foreach apk,$(APKS),                                          \
  $(eval $(apk)_apk_depflags :=                                 \
    $(foreach dp,$($(apk)_apk_fulldeps),--depends $(dp))        \
  )                                                             \
)
# $(warning android_online_apk_depflags = $(android_online_apk_depflags))

# Rule to make native apps for APK
# 1 - apk name
# 2 - apk location
# 3 - arch
define _make_apk_native_rule

  .PHONY : _$(1)_make_$(3)_native_libs
  _$(1)_make_$(3)_native_libs :
	$(MAKE) ARCH=$(3) $($(1)_native)                   \
      BINDIR=$(2)/libs/$(call _android_arch_name,$(3))

  $(1) : _$(1)_make_$(3)_native_libs

endef

# Rule to make an APK
# 1 - apk name
# 2 - apk location
define _make_apk_rule

  .PHONY : $(1)

  # In turn, we generate a project, copy in any native libs, copy in
  # any .jar files, and finally perform an ant build.  Note we do:
  #
  #   [ ! -f $$$$dst ] || [ $$$$l -nt $$$$dst ]
  #
  # as a copy condition, since some versions of bash (namely
  # 4.2.24(1)) are broken and don't deal with missing destination
  # files as part of -nt.

  $(1) : $($(1)_deps) $($(1)_datarule)
	@echo [MAKE APK] $(2)
	echo $(CMDPREFIX)rm -rf $(2)
	$(CMDPREFIX)mkdir -p $(2)/libs/$(ANDROID_ARCH_NAME)
	$($(1)_prebuild)
	$(CMDPREFIX)$(MAKE_APK_PROJ)                                             \
      --sdk-version                                                          \
        $(if $($(1)_sdk_version),$($(1)_sdk_version),$(ANDROID_SDK_VERSION)) \
      --target $(if $($(1)_target),$($(1)_target),$(ANDROID_SDK_TARGET))     \
      --dest $(2)                                                            \
      --version $($(1)_version)                                              \
      --name $(1)                                                            \
      --package $($(1)_package)                                              \
      $(if $($(1)_srcbase),$(addprefix --src ,$($(1)_srcbase)))              \
      $(if $(ANDROID_KEY_STORE),--key-store $(ANDROID_KEY_STORE))            \
      $(if $(ANDROID_KEY_ALIAS),--key-alias $(ANDROID_KEY_ALIAS))            \
      $(if $(ANDROID_SDK),--android-sdk $(ANDROID_SDK))                      \
      $(if $($(1)_library),--library)                                        \
      $(if $($(1)_title),--title "$($(1)_title)")                            \
      $(if $($(1)_activity),--activity $($(1)_activity))                     \
      $(addprefix --permissions ,$($(1)_permissions))                        \
      $(if $($(1)_icondir),--icon-dir $($(1)_icondir))                       \
      $($(1)_apk_depflags)                                                   \
      $($(1)_flags)
	$(CMDPREFIX)for j in $($(1)_jarfiles) ; do                  \
      dst=$(2)/libs/`basename $$$$j` ;                          \
      if [ ! -f $$$$dst ] || [ $$$$j -nt $$$$dst ] ; then       \
        echo [CP JAR] $$$$j ; cp -a $$$$j $$$$dst ;             \
      fi ;                                                      \
    done
	$(CMDPREFIX)cd $(2) && ant $(APK_CONFIG)
	$($(1)_poststep)

  $(1)_install : $(1)
	adb install -r $($(1)_apk_file)

  $(1)_run_dot:=$(if $(filter com.%,$($(1)_activity)),,.)
  $(1)_run : $(1)_install
	adb shell am start -a android.intent.action.MAIN \
      -n $($(1)_package)/$$($(1)_run_dot)$($(1)_activity)

  .PHONY : $(1)_clean
  $(1)_clean :
	rm -rf $(2)
endef


ifeq ($(TARGET),android)

  # Rules to build the native libs for each arch into the correct
  # location, followed by the APK itself.

  $(foreach apk,$(APKS),													\
    $(if $($(apk)_native), $(foreach arch,$($(apk)_archs),                  \
      $(eval $(call _make_apk_native_rule,$(apk),$($(apk)_apk_dest),$(arch))) \
    ))																		\
    $(eval $(call _make_apk_rule,$(apk),$($(apk)_apk_dest)))                \
  )

endif

############################################################

MODULEDEFDIR := moduledefs

# Define the <mod>_moduledef rule
# 1 - module name
# 2 - module type ('executable', 'shared_library', 'static_library')
define _make_moduledef_rule

  $(1)_moduledef := $(MODULEDEFDIR)/$(1).$(TARGET).$(CONFIG).def
  $(MODULEDEFDIR)/$(1).$(TARGET).$(CONFIG).def :
	@mkdir -p $(MODULEDEFDIR)
	@echo [MODULEDEF] \($(1)\) $$@
	@echo "{ 'target_name': '$(1)'," > $$@
	@echo "  'type': 'none'," >> $$@

	@echo "  'dependencies': [" >> $$@
	@for d in $($(1)_deps) ; do echo "    '$$$$d'," ; done >> $$@
	@echo "  ]," >> $$@

	@echo "  'actions': [ {" >> $$@
	@echo "    'action_name': 'build $(1)', 'extension': 'in'," >> $$@
	@echo "    'action': [ 'bash', '-c', " >> $$@
	@if [ "" == "$($(1)_cmds)" ] ; then \
      echo "'if [ \"\$$$$(ACTION)\" == \"clean\" ] ; then \
               echo Cleaning $(1) ; \
               make CONFIG=\$$$$(CONFIGURATION) \
               USE_JSC=$(USE_JSC) USE_V8=$(USE_V8) USE_SM=$(USE_SM) \
               $(1)_clean ; \
             else \
               echo Building $(1) ; \
               make CONFIG=\$$$$(CONFIGURATION) \
               USE_JSC=$(USE_JSC) USE_V8=$(USE_V8) USE_SM=$(USE_SM) \
               $(1) -j4 ;\
             fi' ]," >> $$@ ; \
	else \
	  echo "'$($(1)_cmds)' ]," >> $$@ ; \
	fi
	@echo "    'outputs': [ 'obj' ]," >> $$@

	@echo "    'inputs': [" >> $$@
	@_p=`pwd`/ ; for s in $($(1)_src) ; do echo "      '$$$${s#$$$$_p}'," ; \
	  done >> $$@
	@for s in $($(1)_headerfiles) ; do echo "      '$$$$s'," ; done >> $$@
	@echo "    ]," >> $$@

	@echo "  } ]," >> $$@

	@echo "  'mac_external': 1," >> $$@

	@echo "}," >> $$@

endef

# define <mod>_moduledef for each APP, DLL and LIB
$(foreach m,$(APPS),$(eval \
  $(call _make_moduledef_rule,$(m),executable) \
))
$(foreach m,$(DLLS),$(eval \
  $(call _make_moduledef_rule,$(m),shared_library) \
))
$(foreach m,$(LIBS),$(eval \
  $(call _make_moduledef_rule,$(m),static_library) \
))
$(foreach m,$(RULES),$(eval \
  $(call _make_moduledef_rule,$(m),static_library) \
))

.PHONY : module-defs
module-defs : $(foreach m,$(C_MODULES) $(RULES),$($(m)_moduledef))

############################################################

# DEPENDENCY FILES

#
# Generate a list of all dependency files
#

# include only those that are relevant to the targets being
# created

ALLDEPFILES := $(foreach t,$(C_MODULES),$($(t)_DEPFILES))
-include $(sort $(ALLDEPFILES))

############################################################

# CLEAN

# <mod>_cleanfiles
$(foreach mod,$(C_MODULES),$(eval \
  $(mod)_cleanfiles := $($(mod)_OBJECTS) $($(mod)_OBJDIR) $($(mod)_libfile) \
    $($(mod)_appfile) $($(mod)_DEPFILES) \
))

# <mod>_clean  rule to delete files

# 1 - mod
define _make_clean_rule
  $(1)_clean :
	rm -rf $($(1)_cleanfiles)
endef

$(foreach mod,$(C_MODULES),$(eval \
  $(call _make_clean_rule,$(mod)) \
))

# clean rule
.PHONY : clean
clean : $(foreach mod,$(C_MODULES) $(APKS),$(mod)_clean)

.PHONY : depclean
depclean :
	rm -rf dep

.PHONY : distclean
distclean :
	rm -rf dep obj bin lib
