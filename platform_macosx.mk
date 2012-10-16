# Copyright (c) 2012 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

############################################################

# Language to compile all .cpp files as
MACOSX_CXX_DEFAULTLANG ?= objective-c++

# Check which SDK version we have available
XCODE_SDK_VER ?= 10.6
ifeq (,$(shell xcodebuild -showsdks | grep macosx$(XCODE_SDK_VER)))
  $(error Cant find SDK version $(XCODE_SDK_VER))
endif

# Create a variable holding the xcode configuration
ifeq ($(CONFIG),debug)
  XCODE_CONFIG := Debug
else
  XCODE_CONFIG := Release
endif

# Mark non-10.6 builds

ifneq ($(XCODE_SDK_VER),10.6)
  VARIANT:=$(strip $(VARIANT)-$(XCODE_SDK_VER))
endif

############################################################

$(call log,MACOSX BUILD CONFIGURATION)

#
# CXX / CMM FLAGS
#

CXX := /Developer/usr/bin/llvm-g++-4.2
CMM := $(CXX)

CXXFLAGSPRE := -x $(MACOSX_CXX_DEFAULTLANG) \
    -arch i386 -fmessage-length=0 -pipe -fexceptions \
    -fpascal-strings -fasm-blocks \
    -Wall -Wno-unknown-pragmas \
    -Wno-reorder -Wno-trigraphs -Wno-unused-parameter \
    -isysroot /Developer/SDKs/MacOSX$(XCODE_SDK_VER).sdk \
    -ftree-vectorize -msse3 -mssse3 \
    -mmacosx-version-min=$(XCODE_SDK_VER) \
    -fvisibility-inlines-hidden \
    -fvisibility=hidden \
    -DXP_MACOSX=1 -DMACOSX



# -fno-rtti
# -fno-exceptions
# -fvisibility=hidden

CMMFLAGSPRE := -x objective-c++ \
    -arch i386 -fmessage-length=0 -pipe \
    -fpascal-strings -fasm-blocks -fPIC \
    -Wall -Wno-unknown-pragmas \
    -Wno-reorder -Wno-trigraphs -Wno-unused-parameter \
    -Wno-undeclared-selector \
    -isysroot /Developer/SDKs/MacOSX$(XCODE_SDK_VER).sdk \
    -ftree-vectorize -msse3 -mssse3 \
    -mmacosx-version-min=$(XCODE_SDK_VER) \
    -fvisibility-inlines-hidden \
    -fvisibility=hidden \
    -DXP_MACOSX=1

# -fno-exceptions
# -fno-rtti

CXXFLAGSPOST := \
    -isysroot /Developer/SDKs/MacOSX$(XCODE_SDK_VER).sdk \
    -c

CMMFLAGSPOST := \
    -isysroot /Developer/SDKs/MacOSX$(XCODE_SDK_VER).sdk \
    -c

# DEBUG / RELEASE

ifeq ($(CONFIG),debug)
  CXXFLAGSPRE += -g -O0 -D_DEBUG -DDEBUG
  CMMFLAGSPRE += -g -O0 -D_DEBUG -DDEBUG
else
  CXXFLAGSPRE += -g -O3 -DNDEBUG
  CMMFLAGSPRE += -g -O3 -DNDEBUG
endif

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

AR := MACOSX_DEPLOYMENT_TARGET=$(XCODE_SDK_VER) /Developer/usr/bin/libtool
ARFLAGSPRE := -static -arch_only i386 -g
arout := -o
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

DLL := MACOSX_DEPLOYMENT_TARGET=$(XCODE_SDK_VER) /Developer/usr/bin/llvm-g++-4.2
DLLFLAGSPRE := -dynamiclib -arch i386 -g
DLLFLAGSPOST := \
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
    in=`otool -D $$$$d | grep -v :`; \
    bn=`basename $$$$d`; \
    install_name_tool -change $$$$in @loader_path/$$$$bn $$@ ; \
  done

#
# APPS
#

LDFLAGS_LIBDIR := -L
LDFLAGS_LIB := -l

LD := /Developer/usr/bin/llvm-g++-4.2
LDFLAGSPRE := \
    -arch i386 \
    -g \
    -isysroot /Developer/SDKs/MacOSX$(XCODE_SDK_VER).sdk

LDFLAGSPOST := \
    -mmacosx-version-min=$(XCODE_SDK_VER) \
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

app-post = \
  $(CMDPREFIX) for d in $($(1)_ext_dlls) ; do \
    in=`otool -D $$$$d | grep -v :`; \
    bn=`basename $$$$d`; \
    install_name_tool -change $$$$in @loader_path/$$$$bn $$@ ; \
  done

############################################################
