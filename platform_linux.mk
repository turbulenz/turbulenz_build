# Copyright (c) 2012 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

############################################################
#
# Linux
#
############################################################

CLANG_VERSION ?= 6.0

#
# CCACHE
#
CCACHE:=$(shell test -n "`which ccache 2>/dev/null`"; if [ $$? -eq 0 ] ; then echo "ccache" ; fi)

#
# DISTCC
#
ifeq (1,$(ENABLE_DISTCC))
DISTCC:=$(shell test -n "`which distcc 2>/dev/null`"; if [ $$? -eq 0 ] ; then echo "distcc" ; fi)
endif

#
# RPATH the executable dir?
ifneq (1,$(DISABLE_EXECUTABLE_RPATH))
  _rpath_flags := -Wl,-rpath,'$$$$ORIGIN'
endif

#
# CXX / CMM
#

ifeq (clang,$(COMPILER))
  CXXCOMPILER:=$(shell \
    which clang++-$(CLANG_VERSION) || which clang++ || echo -n \
  )
  ifeq ($(CXXCOMPILER),)
    $(error Cannot find clang++)
  endif
else
  CXXCOMPILER:=g++
endif

ifeq (ccachedistcc,$(CCACHE)$(DISTCC))
export CCACHE_PREFIX := distcc
CXX := $(CCACHE) $(CXXCOMPILER)
else
CXX := $(CCACHE) $(DISTCC) $(CXXCOMPILER)
endif
CC := $(CXX) -x c

#
# CXX / CMM FLAGS
#

_cxxflags_warnings := \
  -Wall -Wsign-compare -Wunused-parameter \
  -Wno-pragmas -Wno-unknown-pragmas -Wno-trigraphs \
  -Wshadow

# -Wconversion

CFLAGSPRE := \
    -D_GLIBCXX_USE_CXX11_ABI=0 \
    -fmessage-length=0 -pipe \
    $(_cxxflags_warnings) \
    -fPIC \
    -ftree-vectorize -msse3 -mssse3 \
    -fdata-sections \
    -ffunction-sections \
    -fvisibility-inlines-hidden \
    -fvisibility=hidden \

ifeq (clang,$(COMPILER))
  CFLAGSPRE += -Qunused-arguments -Wno-deprecated-register -Wpessimizing-move -Wshadow-uncaptured-local
endif

CFLAGSPOST := -c

# SYMBOLS

ifeq (1,$(C_SYMBOLS))
  CFLAGSPRE += -g
  DLLFLAGSPOST += -g -rdynamic
  LDFLAGSPOST += -g -rdynamic
endif

ifeq (1,$(C_OPTIMIZE))
  CFLAGSPRE += -O3 -DNDEBUG -ftree-vectorize -Wno-unused-lambda-capture

else
  CFLAGSPRE += -O0 -D_DEBUG -DDEBUG
  # ifneq (clang,$(COMPILER))
  #   CFLAGSPRE += -falign-functions=4
  # endif
endif

ifeq (1,$(LD_OPTIMIZE))
  # Enable lto, requires the use of the gold linker
  CFLAGSPRE += -flto
  LDFLAGSPOST += -O3 -flto -fuse-ld=gold
  DLLFLAGSPOST += -O3 -flto -fuse-ld=gold
  ARFLAGSPOST += --plugin /usr/lib/llvm-$(CLANG_VERSION)/lib/LLVMgold.so
endif

ifeq (1clang,$(C_RUNTIME_CHECKS)$(COMPILER))
  _RT_FLAGS := -fsanitize=address
    # -fsanitize=thread

    # non-trivial to make work ...
    # requires -frtti:
    # -fsanitize=undefined
    # link error:
    # -fsanitize=dataflow
    # unsupported:
    # -fsanitize=safe-stack
    # -fsanitize=cfi
    # issues at startup
    # _RT_FLAGS := -fsanitize=memory
    # CFLAGSPOST += -fPIE
    # DLLFLAGSPOST += -Wl,-pie
    # LDFLAGSPOST += -Wl,-pie
endif

CXXFLAGSPRE := \
  $(CFLAGSPRE) -Wno-overloaded-virtual -std=c++14 -Wno-reorder \
  -DXP_LINUX=1 -DXP_UNIX=1 -DMOZILLA_STRICT_API
CXXFLAGSPOST := $(CFLAGSPOST) -fexceptions -fpermissive $(_RT_FLAGS)

PCHFLAGS := -x c++-header

#
# LIBS
#

AR := ar
ARFLAGSPRE := cr
arout :=
ARFLAGSPOST +=

libprefix := lib
libsuffix := .a

#
# DLLS
#

DLL := $(CXX)
DLLFLAGSPRE += -shared
DLLFLAGSPOST += $(_rpath_flags) $(_RT_FLAGS)


DLLFLAGS_LIBDIR := -L
DLLFLAGS_LIB := -l

dllprefix := lib
dllsuffix := .so

#
# APPS
#

LDFLAGS_LIBDIR := -L
LDFLAGS_LIB := -l

LD := $(CXX)
LDFLAGSPRE +=
LDFLAGSPOST += -Wl,--gc-sections -lpthread $(_rpath_flags) $(_RT_FLAGS)

#
# .map files
#

pdbsuffix := .map
DLLFLAGS_PDB := -Wl,-Map,
LDFLAGS_PDB := $(DLLFLAGS_PDB)

############################################################
