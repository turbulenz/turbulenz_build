# Copyright (c) 2012 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

############################################################

# /Users/dtebbs/turbulenz/external/android/android-ndk-r9b/toolchains/llvm-3.3/prebuilt/darwin-x86_64/bin/clang
# -MMD -MP -MF ./obj/local/armeabi/objs-debug/hello-jni/hello-jni.o.d
# -gcc-toolchain /Users/dtebbs/turbulenz/external/android/android-ndk-r9b/toolchains/arm-linux-androideabi-4.8/prebuilt/darwin-x86_64
# -fpic -ffunction-sections -funwind-tables -fstack-protector -no-canonical-prefixes
# -target armv5te-none-linux-androideabi
# -march=armv5te
# -mtune=xscale
# -msoft-float
# -mthumb
# -marm
# -Os -g -DNDEBUG -fomit-frame-pointer -fno-strict-aliasing
# -O0 -UNDEBUG
# -fno-omit-frame-pointer -Ijni
# -DANDROID
# -Wa,--noexecstack -Wformat -Werror=format-security
# -I/Users/dtebbs/turbulenz/external/android/android-ndk-r9b/platforms/android-3/arch-arm/usr/include -c  jni/hello-jni.c -o ./obj/local/armeabi/objs-debug/hello-jni/hello-jni.o

# /Users/dtebbs/turbulenz/external/android/android-ndk-r9b/toolchains/llvm-3.3/prebuilt/darwin-x86_64/bin/clang
# -MMD -MP -MF ./obj/local/armeabi-v7a/objs/helloneon/helloneon.o.d
# hains/arm-linux-androideabi-4.8/prebuilt/darwin-x86_64
# -fpic -ffunction-sections -funwind-tables -fstack-protector -no-canonical-prefixes
# -gcc-toolchain /Users/dtebbs/turbulenz/external/android/android-ndk-r9b/toolc
# -target armv7-none-linux-androideabi -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb
# -Os -g -DNDEBUG -fomit-frame-pointer -fno-strict-aliasing
# -I/Users/dtebbs/turbulenz/external/android/android-ndk-r9b/sources//android/cpufeatures -Ijni -DANDROID -DHAVE_NEON=1 -Wa,--noexecstack -Wformat -Werror=format-security    -I/Users/dtebbs/turbulenz/external/android/android-ndk-r9b/platforms/android-4/arch-arm/usr/include -c  jni/helloneon.c -o ./obj/local/armeabi-v7a/objs/helloneon/helloneon.o

############################################################
# Util Functions
############################################################

# 1 - tzbuild arch (armv7a, x86, etc)
_android_arch_name = $(strip					\
  $(if $(filter armv5,$(1)),armeabi,			\
    $(if $(filter armv7a,$(1)),armeabi-v7a,		\
      $(1)										\
    )											\
  ))

############################################################

android_build_host := $(BUILDHOST)
ifeq (linux64,$(BUILDHOST))
  android_build_host := linux
endif
ifeq (linux32,$(BUILDHOST))
  android_build_host := linux
endif

# SDK dir

ANDROID_SDK_PATH ?= $(external_path)/android
ANDROID_SDK_TARGET ?= android-15
ANDROID_SDK_VERSION ?= 8
ANDROID_SDK ?= $(ANDROID_SDK_PATH)/android-sdk-$(android_build_host)

# NDK dir

ANDROID_NDK ?= $(ANDROID_SDK_PATH)/android-ndk-r9d
NDK_PLATFORM ?= android-9
NDK_GCC_VER ?= 4.8
NDK_CLANG_VER ?= 3.4
# NDK_HOSTOS ?= darwin
NDK_HOSTARCH ?= x86_64
NDK_STLPORT ?= 0
NDK_LIBCPP ?= 0

# Toolset for which arch

ANDROID_ARCH_NAME := $(call _android_arch_name,$(ARCH))

ifeq ($(ARCH),armv5)
  NDK_ARCHDIR = $(ANDROID_NDK)/toolchains/arm-linux-androideabi-$(NDK_GCC_VER)
  NDK_TOOLPREFIX := arm-linux-androideabi-
  NDK_PLATFORMDIR = \
    $(ANDROID_NDK)/platforms/$(NDK_PLATFORM)/arch-arm
endif
ifeq ($(ARCH),armv7a)
  NDK_ARCHDIR = $(ANDROID_NDK)/toolchains/arm-linux-androideabi-$(NDK_GCC_VER)
  NDK_TOOLPREFIX := arm-linux-androideabi-
  NDK_CLANG_FLAGS = -target armv7-none-linux-androideabi
  NDK_PLATFORMDIR = \
    $(ANDROID_NDK)/platforms/$(NDK_PLATFORM)/arch-arm
  NDK_USE_CLANG ?= 1
endif
ifeq ($(ARCH),x86)
  NDK_ARCHDIR = $(ANDROID_NDK)/toolchains/x86-$(NDK_GCC_VER)
  NDK_TOOLPREFIX := i686-linux-android-
  NDK_CLANG_FLAGS = -target i686-none-linux-android
  NDK_PLATFORMDIR = \
    $(ANDROID_NDK)/platforms/$(NDK_PLATFORM)/arch-x86
  NDK_USE_CLANG ?= 1
endif
ifeq ($(NDK_ARCHDIR),)
  $(error Couldnt determine toolchain for android ARCH $(ARCH))
endif

# Find toolset for this platfom

ifeq ($(BUILDHOST),macosx)
  NDK_HOSTOS := darwin
endif
ifeq ($(BUILDHOST),linux64)
  NDK_HOSTOS := linux
endif
ifeq ($(NDK_HOSTOS),)
  $(error Couldnt find toolchain for BUILDHOST $(BUILDHOST))
endif

NDK_TOOLCHAIN = $(NDK_ARCHDIR)/prebuilt/$(NDK_HOSTOS)-$(NDK_HOSTARCH)
NDK_TOOLBIN = $(NDK_TOOLCHAIN)/bin
NDK_CLANG_TOOLCHAIN = \
 $(ANDROID_NDK)/toolchains/llvm-$(NDK_CLANG_VER)/prebuilt/$(NDK_HOSTOS)-$(NDK_HOSTARCH)
NDK_CLANG_TOOLBIN = $(NDK_CLANG_TOOLCHAIN)/bin

NDK_CLANG_FLAGS += -gcc-toolchain $(NDK_TOOLCHAIN) -no-canonical-prefixes

# Some include paths

NDK_GNUSTL_DIR = $(ANDROID_NDK)/sources/cxx-stl/gnu-libstdc++/$(NDK_GCC_VER)
NDK_GNUSTL_LIBS = \
  $(NDK_GNUSTL_DIR)/libs/$(ANDROID_ARCH_NAME)/libgnustl_static.a
NDK_GNUSTL_INCLUDES = $(NDK_GNUSTL_DIR)/include \
  $(NDK_GNUSTL_DIR)/libs/$(ANDROID_ARCH_NAME)/include

NDK_STLPORT_DIR = $(ANDROID_NDK)/sources/cxx-stl/stlport
NDK_STLPORT_LIBS += \
  $(NDK_STLPORT_DIR)/libs/$(ANDROID_ARCH_NAME)/libstlport_static.a
NDK_STLPORT_INCLUDES = $(NDK_STLPORT_DIR)/stlport

NDK_LIBCPP_DIR = $(ANDROID_NDK)/sources/cxx-stl/llvm-libc++
NDK_LIBCPP_LIBS = $(NDK_LIBCPP_DIR)/libs/$(ANDROID_ARCH_NAME)/libc++_static.a
NDK_LIBCPP_INCLUDES = $(NDK_LIBCPP_DIR)/libcxx/include

ifeq (1,$(NDK_LIBCPP))
  NDK_STL_DIR = $(NDK_LIBCPP_DIR)
  NDK_STL_LIBS = $(NDK_LIBCPP_LIBS)
  NDK_STL_INCLUDES = $(NDK_LIBCPP_INCLUDES)
else
  ifeq (1,$(NDK_STLPORT))
    NDK_STL_DIR = $(NDK_STLPORT_DIR)
    NDK_STL_LIBS = $(NDK_STLPORT_LIBS)
    NDK_STL_INCLUDES = $(NDK_STLPORT_INCLUDES)
  else
    NDK_STL_DIR = $(NDK_GNUSTL_DIR)
    NDK_STL_LIBS = $(NDK_GNUSTL_LIBS)
    NDK_STL_INCLUDES = $(NDK_GNUSTL_INCLUDES)
  endif
endif

NDK_PLATFORM_INCLUDES = \
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

# Don't use := for compiler, since the external_path location, and
# hence android NDK, may not be known yet.

ifeq (1,$(NDK_USE_CLANG))
  CXX = $(NDK_CLANG_TOOLBIN)/clang++
  CXXFLAGSPOST += $(NDK_CLANG_FLAGS)
else
  CXX = $(NDK_TOOLBIN)/$(NDK_TOOLPREFIX)g++
  CXXFLAGSPRE += -funswitch-loops -finline-limit=256 -Wno-psabi
endif

CXXFLAGSPRE += \
  -ffunction-sections -funwind-tables -fno-rtti -fstrict-aliasing \
  -std=c++11 \
  -Wall -Wno-unknown-pragmas -Wno-reorder -Wno-trigraphs \
  -Wno-unused-parameter \
  -DANDROID -DTZ_ANDROID -DTZ_USE_V8

# -fstack-protector

ifeq ($(ARCH),armv5)
  CXXFLAGSPRE += \
    -fpic \
    -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ \
    -mthumb -march=armv5te -mtune=xscale -msoft-float
endif

ifeq ($(ARCH),armv7a)
  CXXFLAGSPRE += \
    -fpic \
    -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ \
    -mthumb

  ifeq ($(TEGRA3),1)
    CXXFLAGSPRE += -mfpu=neon -mcpu=cortex-a9 -mfloat-abi=softfp
  else
    CXXFLAGSPRE += -march=armv7-a -mfloat-abi=softfp -mfpu=vfp
  endif
endif

ifeq ($(ARCH),x86)
  CXXFLAGSPRE += -Wa,--noexecstack
endif

CXXFLAGSPOST += \
 $(addprefix -I,$(NDK_STL_INCLUDES) $(NDK_PLATFORM_INCLUDES)) \
 -DFASTCALL= -Wa,--noexecstack -fexceptions

ifeq ($(CONFIG),debug)
  CXXFLAGSPOST += -DDEBUG -D_DEBUG
endif
ifeq ($(CONFIG),release)
  CXXFLAGSPOST += -DNDEBUG
endif

ifeq ($(C_OPTIMIZE),1)
  CXXFLAGSPOST += -O3 -fomit-frame-pointer -ffast-math -ftree-vectorize

  # WORKAROUND: gcc 4.8 targeting x86
  ifeq (4.8,$(NDK_GCC_VER))
    ifeq (x86,$(ARCH))
      ifneq (1,$(NDK_USE_CLANG))
        CXXFLAGSPOST += -fno-tree-vectorize
      endif
    endif
  endif
else
  CXXFLAGSPOST += -O0
endif
ifeq ($(C_SYMBOLS),1)
  CXXFLAGSPOST += -g
else
  dll-post = \
    $(NDK_TOOLBIN)/$(NDK_TOOLPREFIX)strip --strip-unneeded \
    $($(1)_dllfile)
endif
CXXFLAGSPOST += -c

PCHFLAGS := -x c++-header

#
# AR
#

AR = $(NDK_TOOLBIN)/$(NDK_TOOLPREFIX)ar

ARFLAGSPRE := cr
arout :=
ARFLAGSPOST :=

libprefix := lib
libsuffix := .a

#
# OBJDUMP
#

OBJDUMP = $(NDK_TOOLBIN)/$(NDK_TOOLPREFIX)objdump
OBJDUMP_DISASS := -S

#
# OTHER TOOLS
#

NM = $(NDK_TOOLBIN)/$(NDK_TOOLPREFIX)nm
READELF = $(NDK_TOOLBIN)/$(NDK_TOOLPREFIX)readelf

#
# DLLS
#

# From ndk-build:
# /Users/dtebbs/turbulenz/external/android/android-ndk-r8/toolchains/arm-linux-androideabi-4.4.3/prebuilt/darwin-x86/bin/arm-linux-androideabi-g++
# -Wl,-soname,libturbulenz.so -shared
# --sysroot=/Users/dtebbs/turbulenz/external/android/android-ndk-r8/platforms/android-9/arch-arm
# <objects>
# <libs>
# -Wl,--fix-cortex-a8  -Wl,--no-undefined -Wl,-z,noexecstack -L/Users/dtebbs/turbulenz/external/android/android-ndk-r8/platforms/android-9/arch-arm/usr/lib -llog -landroid -lEGL -lGLESv2 -ldl -llog -lc -lm -o /Users/dtebbs/turbulenz/build/android/obj/local/armeabi-v7a/libturbulenz.so

# From ndk-build:
# /Users/dtebbs/turbulenz/external/android/android-ndk-r9b/toolchains/llvm-3.3/prebuilt/darwin-x86_64/bin/clang++
# -Wl,-soname,libhelloneon.so -shared
# --sysroot=/Users/dtebbs/turbulenz/external/android/android-ndk-r9b/platforms/android-4/arch-arm
# ./obj/local/armeabi-v7a/objs/helloneon/helloneon.o ./obj/local/armeabi-v7a/objs/helloneon/helloneon-intrinsics.o ./obj/local/armeabi-v7a/libcpufeatures.a
# -lgcc
# -gcc-toolchain /Users/dtebbs/turbulenz/external/android/android-ndk-r9b/toolchains/arm-linux-androideabi-4.8/prebuilt/darwin-x86_64
# -no-canonical-prefixes
# -target armv7-none-linux-androideabi -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb
# -Wl,--fix-cortex-a8  -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now
# -llog -lc -lm -o ./obj/local/armeabi-v7a/libhelloneon.so

ifeq (1,$(NDK_USE_CLANG))
  DLL = $(NDK_CLANG_TOOLBIN)/clang++
  DLLFLAGSPOST += $(NDK_CLANG_FLAGS)
else
  DLL = $(NDK_TOOLBIN)/$(NDK_TOOLPREFIX)gcc
  DLLFLAGSPOST =
endif
DLLFLAGSPRE += -shared \
  --sysroot=$(NDK_PLATFORMDIR) \
# -Wl,-soname,$$(notdir $$@)
# -nostdlib
# -Wl,-shared,-Bsymbolic

DLLFLAGSPOST += \
  $(NDK_STL_LIBS) \
  -Wl,--no-undefined -Wl,-z,noexecstack \
  -L$(NDK_PLATFORMDIR)/usr/lib \
  -ldl -llog -lc -lm
# -landroid -lEGL -lGLESv2

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

DLLKEEPSYM_PRE := -Wl,-whole-archive
DLLKEEPSYM_POST := -Wl,-no-whole-archive

#
# APPS
#

LD = $(DLL)
LDFLAGSPRE = $(DLLFLAGSPRE)
LDFLAGSPOST = $(DLLFLAGSPOST)
LDFLAGS_LIBDIR = $(DLLFLAGS_LIBDIR)
LDFLAGS_LIB = $(DLLFLAGS_LIB)
binsuffix = $(dllsuffix)
