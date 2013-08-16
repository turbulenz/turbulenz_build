# Copyright (c) 2013 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

# /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
#   -x objective-c
#   -arch armv7
#   -fmessage-length=0 -std=c99 -Wno-trigraphs -fpascal-strings -Os -Wno-missing-field-initializers -Wno-missing-prototypes -Wreturn-type -Wno-implicit-atomic-properties -Wno-receiver-is-weak -Wformat -Wno-missing-braces -Wparentheses -Wswitch -Wno-unused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wno-empty-body -Wno-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wno-constant-conversion -Wno-int-conversion -Wno-enum-conversion -Wno-shorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wno-undeclared-selector -Wno-deprecated-implementations -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk -fstrict-aliasing -Wprotocol -Wdeprecated-declarations -g -fvisibility=hidden -Wno-sign-conversion -miphoneos-version-min=5.0 -iquote /Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Release-iphoneos/Ejecta.build/Ejecta-generated-files.hmap -I/Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Release-iphoneos/Ejecta.build/Ejecta-own-target-headers.hmap -I/Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Release-iphoneos/Ejecta.build/Ejecta-all-target-headers.hmap -iquote /Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Release-iphoneos/Ejecta.build/Ejecta-project-headers.hmap -I/Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Products/Release-iphoneos/include -I/Users/dtebbs/tmp/ejecta -I/Users/dtebbs/tmp/ejecta/Source/lib -I/Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Release-iphoneos/Ejecta.build/DerivedSources/armv7 -I/Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Release-iphoneos/Ejecta.build/DerivedSources -F/Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Products/Release-iphoneos -DNS_BLOCK_ASSERTIONS=1 -fobjc-arc -include /Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/PrecompiledHeaders/Prefix-gbqdzzlukuvchcekgkkmzggdhemg/Prefix.pch -MMD -MT dependencies -MF /Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Release-iphoneos/Ejecta.build/Objects-normal/armv7/SRWebSocket.d --serialize-diagnostics /Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Release-iphoneos/Ejecta.build/Objects-normal/armv7/SRWebSocket.dia -c /Users/dtebbs/tmp/ejecta/Source/lib/SocketRocket/SRWebSocket.m -o /Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Release-iphoneos/Ejecta.build/Objects-normal/armv7/SRWebSocket.o

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
  -stdlib=libc++ \
  -fmessage-length=0 -fpascal-strings -fexceptions -fasm-blocks \
  -fvisibility=hidden -fvisibility-inlines-hidden \
  -fobjc-abi-version=2 \
  -fobjc-legacy-dispatch "-DIBOutlet=__attribute__((iboutlet))" \
  "-DIBOutletCollection(ClassName)=__attribute__((iboutletcollection(ClassName)))" \
  "-DIBAction=void)__attribute__((ibaction)" \
  -Wall -Wno-c++11-extensions \
  -isysroot $(XCODE_SIM_SDKROOT) \
  -mios-simulator-version-min=5.0 \
  -DTZ_IOS=1

CMMFLAGSPRE := -x objective-c++ \
  -arch i386 \
  -stdlib=libc++ \
  -fmessage-length=0 -fpascal-strings -fexceptions -fasm-blocks \
  -fvisibility=hidden -fvisibility-inlines-hidden \
  -fobjc-abi-version=2 \
  -fobjc-legacy-dispatch "-DIBOutlet=__attribute__((iboutlet))" \
  "-DIBOutletCollection(ClassName)=__attribute__((iboutletcollection(ClassName)))" \
  "-DIBAction=void)__attribute__((ibaction)" \
  -Wall -Wno-c++11-extensions \
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

DLL := $(AR)
DLLFLAGSPRE :=
DLLFLAGSPOST :=
DLLFLAGS_LIBDIR :=
DLLFLAGS_LIB :=

dllprefix := lib
dllsuffix := .a
dll-post =

#
# APPS
#

LDFLAGS_LIBDIR := -L
LDFLAGS_LIB := -l
LD :=
LDFLAGSPRE :=
LDFLAGSPOST :=

app-post =

############################################################
