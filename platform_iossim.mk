# Copyright (c) 2013 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

XCODE_ROOT := /Applications/Xcode.app/Contents/Developer
XCODE_TOOLROOT := $(XCODE_ROOT)/Toolchains/XcodeDefault.xctoolchain
XCODE_PLATFORMS := $(XCODE_ROOT)/Platforms

# SIM
XCODE_SIM_SDK := iPhoneSimulator6.1.sdk
XCODE_SIM_PLATFORM := $(XCODE_PLATFORMS)/iPhoneSimulator.platform
XCODE_SIM_SDKROOT := $(XCODE_SIM_PLATFORM)/Developer/SDKs/$(XCODE_SIM_SDK)

CXX := $(XCODE_TOOLROOT)/usr/bin/clang
CMM := $(XCODE_TOOLROOT)/usr/bin/clang

CXXFLAGSPRE := -x objective-c++ \
  -arch i386 \
  -fmessage-length=0 -fpascal-strings -fexceptions -fasm-blocks \
  -fvisibility=hidden -fvisibility-inlines-hidden \
  -fobjc-abi-version=2 \
  -fobjc-legacy-dispatch "-DIBOutlet=__attribute__((iboutlet))" \
  "-DIBOutletCollection(ClassName)=__attribute__((iboutletcollection(ClassName)))" \
  "-DIBAction=void)__attribute__((ibaction)" \
  -Wall \
  -isysroot $(XCODE_SIM_SDKROOT) \
  -mios-simulator-version-min=5.0 \
  -I$(XCODE_SIM_PLATFORM)/usr/include \
  -DTZ_IOS=1

CMMFLAGSPRE := -x objective-c++ \
  -arch i386 \
  -fmessage-length=0 -fpascal-strings -fexceptions -fasm-blocks \
  -fvisibility=hidden -fvisibility-inlines-hidden \
  -fobjc-abi-version=2 \
  -fobjc-legacy-dispatch "-DIBOutlet=__attribute__((iboutlet))" \
  "-DIBOutletCollection(ClassName)=__attribute__((iboutletcollection(ClassName)))" \
  "-DIBAction=void)__attribute__((ibaction)" \
  -Wall \
  -isysroot $(XCODE_SIM_SDKROOT) \
  -mios-simulator-version-min=5.0 \
  -DTZ_IOS=1

#  --serialize-diagnostics somefile.dia

CXXFLAGSPOST := \
    -c

CMMFLAGSPOST := \
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

AR := $(XCODE_TOOLROOT)/usr/bin/libtool
ARFLAGSPRE := -static -arch_only i386 -syslibroot $(XCODE_SIM_SDKROOT) -g
arout := -o
ARFLAGSPOST :=

libprefix := lib
libsuffix := .a

#
# DLL
#

DLL := MACOSX_DEPLOYMENT_TARGET=$(XCODE_SDK_VER) $(MACOSX_XCODE_BIN_PATH)$(MACOSX_CXX)
DLLFLAGSPRE := -isysroot $(XCODE_SDK_ROOT) -dynamiclib -arch i386 -g
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
    in=`$(MACOSX_XCODE_BIN_PATH)otool -D $$$$d | grep -v :`; \
    bn=`basename $$$$d`; \
    $(MACOSX_XCODE_BIN_PATH)install_name_tool -change $$$$in @loader_path/$$$$bn $$@ ; \
  done

#
# APPS
#

LDFLAGS_LIBDIR := -L
LDFLAGS_LIB := -l

LD := $(MACOSX_XCODE_BIN_PATH)$(MACOSX_CXX)
LDFLAGSPRE := \
    -arch i386 \
    -g \
    -isysroot $(XCODE_SDK_ROOT) \
    $(MACOSX_LDFLAGS)

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
    in=`$(MACOSX_XCODE_BIN_PATH)otool -D $$$$d | grep -v :`; \
    bn=`basename $$$$d`; \
    $(MACOSX_XCODE_BIN_PATH)install_name_tool -change $$$$in @loader_path/$$$$bn $$@ ; \
  done

############################################################
