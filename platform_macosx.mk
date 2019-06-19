# Copyright (c) 2012 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

############################################################

ifeq (,$(ARCH))
  $(error ARCH variable is not set (x86_64|i386))
endif

ifeq (1,$(MACOSX_USE_OLD_TOOLS))
  MACOSX_XCODE_BIN_PATH := $(wildcard /Developer/usr/bin/)
endif

ifneq (,$(MACOSX_XCODE_BIN_PATH))
  # OLD TOOLS
  MACOSX_CXX := llvm-g++-4.2
  CXXFLAGS += -ftree-vectorize
  CMMFLAGS += -ftree-vectorize
else
  # clang
  MACOSX_CXX := clang
  MACOSX_LDFLAGS += -lc++
  MACOSX_DLLFLAGS += -lc++
endif

MACOSX_EXT_DLL_RPATH ?= @loader_path

# Language to compile all .c and .cpp files as
MACOSX_C_DEFAULTLANG ?= objective-c
MACOSX_CXX_DEFAULTLANG ?= objective-c++

# SDK to build against
ifeq (auto,$(XCODE_SDK_VER))
  XCODE_SDK_VER:=$(shell xcodebuild -showsdks | grep -o 'macosx.*' | sort -r | head -n 1 | grep -oe '[0-9\.]\+')
  ifeq (,$(XCODE_SDK_VER))
    $(error Failed to auto-detect SDK version)
  endif
  $(warning Using auto-detected SDK version: $(XCODE_SDK_VER))
endif

XCODE_SDK_VER ?= 10.14

# Minimum OS version to target
XCODE_MIN_OS_VER ?= 10.9
# $(XCODE_SDK_VER)

# Mark builds that are linked against the non-default SDKs
# ifneq ($(XCODE_SDK_VER),10.11)
#   VARIANT:=$(strip $(VARIANT)-$(XCODE_SDK_VER))
# endif

# Check the known SDK install locations

XCODE_SDK_ROOT:=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX$(XCODE_SDK_VER).sdk
ifeq (,$(wildcard $(XCODE_SDK_ROOT)))
  XCODE_SDK_ROOT:=/Developer/SDKs/MacOSX$(XCODE_SDK_VER).sdk
endif
ifeq (,$(wildcard $(XCODE_SDK_ROOT)))
  XCODE_SDK_ROOT:=$(shell xcode-select --print-path)/SDKs/MacOSX$(XCODE_SDK_VER).sdk
endif

############################################################

#
# CCACHE
#
CCACHE:=$(shell test -n "`which ccache 2>/dev/null`"; if [ $$? -eq 0 ] ; then echo "ccache" ; fi)

#
# CXX / CMM FLAGS
#

CC := $(CCACHE) $(DISTCC) $(MACOSX_XCODE_BIN_PATH)$(MACOSX_CXX)
CXX := $(CC)
CMM := $(CXX)
OBJDUMP := $(MACOSX_XCODE_BIN_PATH)otool
OBJDUMP_DISASS := -tv
CLANG_TIDY := /usr/local/opt/llvm/bin/clang-tidy

CSYSTEMFLAGS := \
    -isysroot $(XCODE_SDK_ROOT) \
    -mmacosx-version-min=$(XCODE_MIN_OS_VER) \

_cxxflags_warnings := \
    -Wall -Wconversion -Wsign-compare -Wunused-parameter \
    -Wno-unknown-pragmas -Wno-overloaded-virtual -Wno-trigraphs

CFLAGSPRE := \
    -arch $(ARCH) -fmessage-length=0 -pipe \
    -fpascal-strings -fasm-blocks \
    -fstrict-aliasing -fno-threadsafe-statics \
    -msse3 -mssse3 \
    $(_cxxflags_warnings) \
    -fvisibility-inlines-hidden \
    -fvisibility=hidden \
    -DMACOSX=1

CFLAGSPOST := -c

# DEBUG / RELEASE

ifeq (1,$(C_SYMBOLS))
  CFLAGSPRE += -g
endif

ifeq (1,$(C_OPTIMIZE))
  CFLAGSPRE += -O3 -DNDEBUG -Wno-unused-lambda-capture
else
  CFLAGSPRE += -O0 -D_DEBUG -DDEBUG
endif

#ifeq (1,$(LD_OPTIMIZE))
#  CFLAGSPRE += -flto
#  MACOSX_LDFLAGS += -O3 -flto
#endif

ifeq (1,$(C_RUNTIME_CHECKS))

  _RT_FLAGS :=                                   \
    -fsanitize=address                           \

    # -fsanitize=undefined                         \
    # -fsanitize=safe-stack                        \
    # -fsanitize=memory                            \
    # -fsanitize=thread                            \
    # -fsanitize=dataflow                          \
    # -fsanitize=cfi                               \

  $(warning -fsanitize=address not enable on Mac (not stable))
  # CFLAGSPOST += $(_RT_FLAGS)
  # DLLFLAGSPOST += $(_RT_FLAGS)
  # LDFLAGSPOST += $(_RT_FLAGS)

endif

# -fno-rtti
# -fno-exceptions
# -fvisibility=hidden

CXXSYSTEMFLAGS := $(CSYSTEMFLAGS)
CXXFLAGSPRE := -x $(MACOSX_CXX_DEFAULTLANG) -std=c++14 -fno-exceptions \
  -Wno-undeclared-selector  \
  $(CFLAGSPRE)
CMMFLAGSPRE := $(CXXFLAGSPRE)
CFLAGSPRE := -x $(MACOSX_C_DEFAULTLANG) $(CFLAGSPRE)

CXXFLAGSPOST := $(CFLAGSPOST)
CMMFLAGSPOST := $(CFLAGSPOST)

PCHFLAGS := -x objective-c++-header

#
# LIBS
#

# ARFLAGSPOST := \
#     -Xlinker \
#     --no-demangle \
#     -framework CoreFoundation \
#     -framework OpenGL \
#     -framework Carbon \
#     -framework AGL \
#     -framework QuartzCore \
#     -framework AppKit \
#     -framework IOKit \
#     -framework System

AR := MACOSX_DEPLOYMENT_TARGET=$(XCODE_MIN_OS_VER) \
  $(MACOSX_XCODE_BIN_PATH)libtool
ARFLAGSPRE := -static -arch_only $(ARCH) -g
space:= #
arout := -o #$(space)
ARFLAGSPOST := \
  -framework CoreFoundation \
  -framework OpenGL \
  -framework Carbon \
  -framework AGL \
  -framework QuartzCore \
  -framework AppKit \
  -framework IOKit \
  -framework System

libprefix := lib
libsuffix := .a

#
# DLL
#

DLL := MACOSX_DEPLOYMENT_TARGET=$(XCODE_MIN_OS_VER) \
  $(MACOSX_XCODE_BIN_PATH)$(MACOSX_CXX)
DLLFLAGSPRE := \
  -isysroot $(XCODE_SDK_ROOT) -dynamiclib -arch $(ARCH) -g $(MACOSX_DLLFLAGS)
DLLFLAGSPOST += \
  -framework CoreFoundation \
  -framework OpenGL \
  -framework Carbon \
  -framework AGL \
  -framework QuartzCore \
  -framework AppKit \
  -framework IOKit \
  -framework System

DLLFLAGS_LIBDIR := -L
DLLFLAGS_LIB := -l

dllprefix :=
dllsuffix := .dylib


dll-post = \
  $(CMDPREFIX) for d in $($(1)_ext_dlls) ; do \
    in=`$(MACOSX_XCODE_BIN_PATH)otool -D $$$$d | grep -v :`; \
    bn=`basename $$$$d`; \
    $(MACOSX_XCODE_BIN_PATH)install_name_tool -change $$$$in $(MACOSX_EXT_DLL_RPATH)/$$$$bn $$@ ; \
  done

#
# APPS
#

LDFLAGS_LIBDIR := -L
LDFLAGS_LIB := -l

LD := $(MACOSX_XCODE_BIN_PATH)$(MACOSX_CXX)
LDFLAGSPRE := \
    -arch $(ARCH) \
    -g \
    -isysroot $(XCODE_SDK_ROOT) \
    $(MACOSX_LDFLAGS)

LDFLAGSPOST += \
    -mmacosx-version-min=$(XCODE_MIN_OS_VER) \
    -dead_strip \
    -Wl,-search_paths_first \
    -framework CoreFoundation \
    -framework OpenGL \
    -framework Carbon \
    -framework QuartzCore \
    -framework AppKit \
    -framework IOKit \
    -licucore

#    -Xlinker \
#    --no-demangle \

# Generate map files

pdbsuffix := .map
DLLFLAGS_PDB := -Wl,-map,
LDFLAGS_PDB := $(DLLFLAGS_PDB)

# Paths to local dlls

app-post = \
  $(CMDPREFIX) for d in $($(1)_ext_dlls) ; do \
    in=`$(MACOSX_XCODE_BIN_PATH)otool -D $$$$d | grep -v :`; \
    bn=`basename $$$$d`; \
    $(MACOSX_XCODE_BIN_PATH)install_name_tool -change $$$$in @loader_path/$$$$bn $$@ ; \
  done

############################################################
