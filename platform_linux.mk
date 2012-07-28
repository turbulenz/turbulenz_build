############################################################
#
# Linux
#
############################################################

$(call log,LINUX BUILD CONFIGURATION)

#
# CCACHE
#
CCACHE:=$(shell test -n "`which ccache 2&>/dev/null`"; if [ $$? -eq 0 ] ; then echo "ccache" ; fi)

#
# CXX / CMM FLAGS
#

CXX := $(CCACHE) g++

CXXFLAGSPRE := \
    -fmessage-length=0 -pipe \
    -Wall -Werror \
    -Wno-reorder -Wno-trigraphs \
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
DLLFLAGSPOST :=


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
LDFLAGSPRE := \
    -g \

LDFLAGSPOST := \
    -lpthread


############################################################


# g++ \
#  -shared \
#  -Wl,-soname,turbulenz.so.0.13.0 \
#  <objects> \
#  -Wl,--rpath /usr/local/lib/turbulenz \
#  -L/usr/local/lib/turbulenz -L../../external/v8/lib/linux64 -L../../external/bullet/lib/linux64 -L../../external/zlib/lib/linux64 -L../../external/png/lib/linux64 \
#  -lv8 -lGL -lopenal -lvorbis -lvorbisfile -lpng -ljpeg -lbulletmultithreaded -lbulletdynamics -lbulletcollision -lbulletmath -ltbb `pkg-config --libs-only-l gtkglext-1.0` \
#  -o turbulenz.so.0.13.0
