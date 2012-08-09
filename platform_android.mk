# Copyright (c) 2012 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

############################################################

# NDK dir

ANDROID_NDK ?= external/android/android-ndk-r8b
NDK_PLATFORM ?= android-9
NDK_GCC_VER ?= 4.6

# Toolset for which arch

ifeq ($(ARCH),armv7a)
  NDK_ARCHDIR := $(ANDROID_NDK)/toolchains/arm-linux-androideabi-$(NDK_GCC_VER)
  NDK_TOOLPREFIX := arm-linux-androideabi-
  NDK_PLATFORMDIR := \
    $(ANDROID_NDK)/platforms/$(NDK_PLATFORM)/arch-arm
  ANDROID_ARCH_NAME := armeabi-v7a
endif
ifeq ($(ARCH),x86)
  NDK_ARCHDIR := $(ANDROID_NDK)/toolchains/x86-$(NDK_GCC_VER)
  NDK_TOOLPREFIX := i686-linux-android-
  NDK_PLATFORMDIR := \
    $(ANDROID_NDK)/platforms/$(NDK_PLATFORM)/arch-x86
  ANDROID_ARCH_NAME := x86
endif
ifeq ($(NDK_ARCHDIR),)
  $(error Couldnt determine toolchain for android ARCH $(ARCH))
endif

# Find toolset for this platfom

ifeq ($(BUILDHOST),macosx)
  NDK_TOOLBIN := $(NDK_ARCHDIR)/prebuilt/darwin-x86/bin
endif
ifeq ($(BUILDHOST),linux64)
  NDK_TOOLBIN := $(NDK_ARCHDIR)/prebuilt/linux-x86/bin
endif
ifeq ($(NDK_TOOLBIN),)
  $(error Couldnt find toolchain for BUILDHOST $(BUILDHOST))
endif

# Some include paths

NDK_STL_DIR := \
  $(ANDROID_NDK)/sources/cxx-stl/gnu-libstdc++/$(NDK_GCC_VER)
NDK_STL_LIBS += \
  $(NDK_STL_DIR)/libs/$(ANDROID_ARCH_NAME)

NDK_STL_INCLUDES := \
  $(NDK_STL_LIBS)/include $(NDK_STL_DIR)/include
NDK_PLATFORM_INCLUDES := \
  $(ANDROID_NDK)/sources/android/native_app_glue \
  $(NDK_PLATFORMDIR)/usr/include

# Set the variant to incldue the arch

VARIANT:=$(strip $(VARIANT)-$(ARCH))

############################################################

#
# CXX
#

# From NDK_BUILD:
#
# /Users/dtebbs/turbulenz/external/android/android-ndk-r8/toolchains/arm-linux-androideabi-4.4.3/prebuilt/darwin-x86/bin/arm-linux-androideabi-g++
# -MMD -MP -MF
# /Users/dtebbs/turbulenz/build/android/obj/local/armeabi-v7a/objs/turbulenz/__/__/__/src/engine/android/androideventhandler.o.d
# -fpic -ffunction-sections -funwind-tables -fstack-protector
# -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__
# -Wno-psabi
# -march=armv7-a -mfloat-abi=softfp -mfpu=vfp
# -fno-exceptions -fno-rtti -mthumb -Os -fomit-frame-pointer
# -fno-strict-aliasing -finline-limit=64
# -I../../../src/core ...
#  -I/Users/dtebbs/turbulenz/build/android/jni
# -DANDROID -DTZ_USE_V8 -DTZ_ANDROID -DTZ_STANDALONE -DFASTCALL=
# -DTZ_NO_TRACK_REFERENCES -finline-limit=256
# -O3 -Wa,--noexecstack   -O2
# -DNDEBUG -g
# -fexceptions
# -I/Users/dtebbs/turbulenz/external/android/android-ndk-r8/sources/cxx-stl/gnu-libstdc++/include
# -I/Users/dtebbs/turbulenz/external/android/android-ndk-r8/sources/cxx-stl/gnu-libstdc++/libs/armeabi-v7a/include
# -I/Users/dtebbs/turbulenz/external/android/android-ndk-r8/platforms/android-9/arch-arm/usr/include
# -c  /Users/dtebbs/turbulenz/build/android/jni/../../../src/engine/android/androideventhandler.cpp
# -o /Users/dtebbs/turbulenz/build/android/obj/local/armeabi-v7a/objs/turbulenz/__/__/__/src/engine/android/androideventhandler.o
#
# x86, release
# /Users/dtebbs/turbulenz/external/android/android-ndk-r8/toolchains/x86-4.4.3/prebuilt/darwin-x86/bin/i686-android-linux-g++
# -MMD -MP -MF <deps>
# -ffunction-sections -funwind-tables -fno-exceptions -fno-rtti -O2
# -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300
# -I<includes>
# -DANDROID -DTZ_USE_V8 -DTZ_ANDROID -DTZ_STANDALONE -DFASTCALL=
# -DTZ_NO_TRACK_REFERENCES
# -finline-limit=256 -O3 -Wa,--noexecstack   -O2 -DNDEBUG -g -fexceptions
# -I<includes>
# -c <cpp>
# -o <out>
#
# x86, debug
# /Users/dtebbs/turbulenz/external/android/android-ndk-r8/toolchains/x86-4.4.3/prebuilt/darwin-x86/bin/i686-android-linux-g++
# -MMD -MP -MF <deps>
# -ffunction-sections -funwind-tables [-fno-exceptions] -fno-rtti -O2
# -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300
# -I<includes>
# -DANDROID -DTZ_USE_V8 -DTZ_ANDROID -DTZ_STANDALONE -DFASTCALL=
# -DTZ_NO_TRACK_REFERENCES
# -finline-limit=256 -O3 -Wa,--noexecstack   -O0 -g -fexceptions
# -I<includes>
# -c <cpp>
# -o <out>



CXX := $(NDK_TOOLBIN)/$(NDK_TOOLPREFIX)g++
CXXFLAGSPRE := \
  -ffunction-sections -funwind-tables -fno-rtti \
  -fomit-frame-pointer -fstrict-aliasing -funswitch-loops \
  -finline-limit=256 \
  -Wall -Wno-unknown-pragmas -Wno-reorder -Wno-trigraphs \
  -Wno-unused-parameter -Wno-psabi \
  -DANDROID -DTZ_ANDROID -DTZ_USE_V8

# -fstack-protector

ifeq ($(ARCH),armv7a)
  CXXFLAGSPRE += \
    -fpic \
    -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ \
    -march=armv7-a -mfloat-abi=softfp -mfpu=vfp -mthumb
endif
ifeq ($(ARCH),x86)
  CXXFLAGSPRE += \
    -Wa,--noexecstack
endif

CXXFLAGSPOST := \
 $(addprefix -I,$(NDK_STL_INCLUDES) $(NDK_PLATFORM_INCLUDES)) \
 -DFASTCALL= -finline-limit=256 -O3 -Wa,--noexecstack -O2 -fexceptions

ifeq ($(CONFIG),debug)
  CXXFLAGSPOST += \
    -DDEBUG -D_DEBUG -O0 -g
endif
ifeq ($(CONFIG),release)
  CXXFLAGSPOST += \
    -DNDEBUG -O2 -g
endif
CXXFLAGSPOST += -c

#
# AR
#

AR := $(NDK_TOOLBIN)/$(NDK_TOOLPREFIX)ar
ARFLAGSPRE := cr
arout :=
ARFLAGSPOST :=

libprefix := lib
libsuffix := .a

#
# DLLS
#

# /Users/dtebbs/turbulenz/external/android/android-ndk-r8/toolchains/arm-linux-androideabi-4.4.3/prebuilt/darwin-x86/bin/arm-linux-androideabi-g++
# -Wl,-soname,libturbulenz.so -shared
# --sysroot=/Users/dtebbs/turbulenz/external/android/android-ndk-r8/platforms/android-9/arch-arm
# <objects>
# <libs>
# /Users/dtebbs/turbulenz/build/android/obj/local/armeabi-v7a/libopenal.so
# /Users/dtebbs/turbulenz/build/android/obj/local/armeabi-v7a/libtbb.so
# /Users/dtebbs/turbulenz/build/android/obj/local/armeabi-v7a/libwebsockets.a
# /Users/dtebbs/turbulenz/build/android/obj/local/armeabi-v7a/libgnustl_static.a
# -Wl,--fix-cortex-a8  -Wl,--no-undefined -Wl,-z,noexecstack -L/Users/dtebbs/turbulenz/external/android/android-ndk-r8/platforms/android-9/arch-arm/usr/lib -llog -landroid -lEGL -lGLESv2 -ldl -llog -lc -lm -o /Users/dtebbs/turbulenz/build/android/obj/local/armeabi-v7a/libturbulenz.so


DLL := $(NDK_TOOLBIN)/$(NDK_TOOLPREFIX)gcc
DLLFLAGSPRE := -shared \
  --sysroot=$(NDK_PLATFORMDIR) \
# -Wl,-soname,$$(notdir $$@)
# -nostdlib
# -Wl,-shared,-Bsymbolic

DLLFLAGSPOST := \
  $(NDK_STL_LIBS)/libgnustl_static.a \
  -Wl,--no-undefined -Wl,-z,noexecstack \
  -L$(NDK_PLATFORMDIR)/usr/lib \
  -landroid -lEGL -lGLESv2 -ldl -llog -lc -lm

ifeq ($(ARCH),armv7a)
  DLLFLAGSPOST += \
    -Wl,--fix-cortex-a8
endif

# -Wl,--no-whole-archive
# -Wl,-rpath-link=.

DLLFLAGS_LIBDIR := -L
DLLFLAGS_LIB := -l
dllprefix := lib
dllsuffix := .so

#
# APPS
#

LD := $(DLL)
LDFLAGSPRE := $(DLLFLAGSPRE)
LDFLAGSPOST := $(DLLFLAGSPOST)
LDFLAGS_LIBDIR := $(DLLFLAGS_LIBDIR)
LDFLAGS_LIB := $(DLLFLAGS_LIB)
binsuffix := $(dllsuffix)
