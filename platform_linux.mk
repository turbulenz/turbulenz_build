# Copyright (c) 2012 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

############################################################
#
# Linux
#
############################################################

#
# CCACHE
#
CCACHE:=$(shell test -n "`which ccache 2&>/dev/null`"; if [ $$? -eq 0 ] ; then echo "ccache" ; fi)

#
# RPATH the executable dir?
ifneq (1,$(DISABLE_EXECUTABLE_RPATH))
  _rpath_flags := -Wl,-rpath,'$$$$ORIGIN'
endif

#
# CXX / CMM FLAGS
#

_cxxflags_warnings := \
    -Wall -Wconversion -Wsign-compare -Wsign-conversion -Wno-unknown-pragmas \
    -Wno-overloaded-virtual -Wno-trigraphs -Wno-unused-parameter

CXX := $(CCACHE) g++

CXXFLAGSPRE := \
  -std=c++11 \
  -fmessage-length=0 -pipe \
  $(_cxxflags_warnings) \
  -fPIC \
  -ftree-vectorize -msse3 -mssse3 \
  -DXP_LINUX=1 -DXP_UNIX=1 \
  -DMOZILLA_STRICT_API \
  -fexceptions

CXXFLAGSPOST := \
  -c

# DEBUG / RELEASE

ifeq ($(CONFIG),debug)
  CXXFLAGSPRE += -g -O0 -D_DEBUG -DDEBUG -falign-functions=4
  CMMFLAGSPRE += -g -O0 -D_DEBUG -DDEBUG -falign-functions=4
else
  CXXFLAGSPRE += -g -O3 -DNDEBUG
  CMMFLAGSPRE += -g -O0 -DNDEBUG
endif

PCHFLAGS := -x c++-header

#
# LIBS
#

AR := ar
ARFLAGSPRE := cr
arout :=
ARFLAGSPOST :=

libprefix := lib
libsuffix := .a

#
# DLLS
#

DLL := g++
DLLFLAGSPRE := -shared -g
DLLFLAGSPOST := $(_rpath_flags)


DLLFLAGS_LIBDIR := -L
DLLFLAGS_LIB := -l

dllprefix := lib
dllsuffix := .so

#
# APPS
#

LDFLAGS_LIBDIR := -L
LDFLAGS_LIB := -l

LD := g++
LDFLAGSPRE := -g

LDFLAGSPOST := -lpthread $(_rpath_flags)


############################################################


# g++ \
#  -shared \
#  -Wl,-soname,turbulenz.so.0.13.0 \
#  <objects> \
#  -Wl,--rpath /usr/local/lib/turbulenz \
#  -L/usr/local/lib/turbulenz -L../../external/v8/lib/linux64 -L../../external/bullet/lib/linux64 -L../../external/zlib/lib/linux64 -L../../external/png/lib/linux64 \
#  -lv8 -lGL -lopenal -lvorbis -lvorbisfile -lpng -ljpeg -lbulletmultithreaded -lbulletdynamics -lbulletcollision -lbulletmath -ltbb `pkg-config --libs-only-l gtkglext-1.0` \
#  -o turbulenz.so.0.13.0
