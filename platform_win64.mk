
ifeq (,$(COMPILER))
  $(error COMPILER variable not defined)
endif

############################################################
# Setup based on vs version
############################################################

ifeq (vs2017,$(COMPILER))
  # Ideally use $(wildcard) to find which out of Enterprise, Professional or Community are installed
  VCINSTALLDIR:=$(subst \ , ,$(shell python $(realpath $(BUILDDIR))/commands/globfiles.py "C:/Program Files (x86)/Microsoft Visual Studio/2017/*"))
  ifeq ($(VCINSTALLDIR),)
    $(error Could not detect Visual Studio 2017 installation)
  endif
  VCBASEDIR:=$(VCINSTALLDIR)/VC/Tools/MSVC/14.16.27023
  WINKITDIR:=C:/Program Files (x86)/Windows Kits/8.1
  UCRTDIR:=C:/Program Files (x86)/Windows Kits/10/Include/10.0.10150.0/ucrt
endif

ifeq (vs2015,$(COMPILER))
  ifeq (,$(VS140COMNTOOLS))
    VS140COMNTOOLS = "C:\\Program Files (x86)\\Microsoft Visual Studio 14.0\\Common7\\Tools\\"
    $(warning VS140COMNTOOLS env var not set.  Is Visual Studio 2015 installed?)
    $(warning VS140COMNTOOLS: guessing $(VS140COMNTOOLS))
  endif
  VCBASEDIR:=$(VS140COMNTOOLS)/../../VC
  # WINKITDIR:=$(VS140COMNTOOLS)/../../../Windows Kits/10
  WINKITDIR:=$(VS140COMNTOOLS)/../../../Windows Kits/8.1
  UCRTDIR:=$(WINKITDIR)/../10/Include/10.0.10150.0/ucrt
endif

ifeq (vs2013,$(COMPILER))
  ifeq (,$(VS120COMNTOOLS))
    $(error VS120COMNTOOLS env var is not set.  Is Visual Studio 2013 installed?)
  endif
  VCBASEDIR:=$(VS120COMNTOOLS)/../../VC
  WINKITDIR:=$(VS120COMNTOOLS)/../../../Windows Kits/8.1
endif

ifeq (,$(VCBASEDIR))
  $(warning Cant find tools for COMPILER version: $(COMPILER))
endif

ifeq (vs2017,$(COMPILER))
  ifeq (win32,$(TARGET))
    VCBINDIR:=$(VCBASEDIR)/bin/Hostx64/x86
    VCLIBDIR:=$(VCBASEDIR)/lib/x86
  else
    ifeq (win64,$(TARGET))
      VCBINDIR:=$(VCBASEDIR)/bin/Hostx64/x64
      VCLIBDIR:=$(VCBASEDIR)/lib/x64
    else
      $(error Target $(TARGET) not supported in this platform file)
    endif
  endif
else
  ifeq (win32,$(TARGET))
    VCBINDIR:=$(VCBASEDIR)/bin
    VCLIBDIR:=$(VCBASEDIR)/lib
  else
    ifeq (win64,$(TARGET))
      VCBINDIR:=$(VCBASEDIR)/bin/amd64
      VCLIBDIR:=$(VCBASEDIR)/lib/amd64
      # ifeq (,$(shell which "$(VCBINDIR)"/cl.exe 2>NUL))
      #   # On a 64-bit machine, the x86_amd64 tools tend to require the
      #   # vcvars variables to be set up in order to find the correct
      #   # DLLs.  Try it as a last resort.

      #   VCBINDIR:=$(VCBASEDIR)/bin/x86_amd64
      #   # export PATH:="$(VS120COMNTOOLS)\\..\\..\\bin";$(PATH)
      #   # $(warning PATH = $(PATH))
      #   # export VCINSTALLDIR:="$(VCBASEDIR)"
      # endif
    else
      $(error Target $(TARGET) not supported in this platform file)
    endif
  endif
endif
# WINSDK_VERSION ?= 10.0A
# ifeq (,$(WINSDKDIR))
#   WINSDKDIR := $(VCBASEDIR)/

# $(info VS120COMNTOOLS = $(VS120COMNTOOLS))
# $(info VSBINDIR = $(VSBINDIR))
# $(info ARCH = $(ARCH))

# Windows-specific stuff in 'development' config

ifeq (development,$(CONFIG))
  CXXFLAGSPRE += -D_ITERATOR_DEBUG_LEVEL=0
endif

############################################################
# CXX
############################################################

CC := "$(VCBINDIR)/cl.exe"
CXX := "$(VCBINDIR)/cl.exe"
CXXFLAGSPRE += /W4 /errorReport:prompt /nologo /analyze- /fp:fast /Gy \
  /Zc:wchar_t /Zc:forScope /GR /Gm- /EHsc /FS /std:c++14 \
  -D_WINDOWS -D_USRDLL -DWIN32 -DWIN32_LEAN_AND_MEAN \
  -D_CRT_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS \
  -D_HAS_EXCEPTIONS=0
CXXFLAGSPOST += \
  -I"$(VCBASEDIR)/include"

ifneq (,$(UCRTDIR))
  CXXFLAGSPOST += -I"$(UCRTDIR)"
endif

# /WX
# /wd"4100" /wd"4127" /wd"4244" /wd"4245" /wd"4267" /wd"4702" /wd"4718"

ifeq (i386,$(ARCH))
  CXXFLAGSPRE += /Gd
endif

ifeq (1,$(C_OPTIMIZE))
  CXXFLAGSPRE += /Ob2ity -DNDEBUG
  # ifeq (i386,$(ARCH))
  #   CXXFLAGSPRE += /Oy
  # endif
else
  CXXFLAGSPRE += /GS /Od /RTC1 -DDEBUG
  ifeq (i386,$(ARCH))
    CXXFLAGSPRE += /Oy-
  endif
endif

ifeq (release,$(WIN_DLL))
  CXXFLAGSPRE += /MD
else
  CXXFLAGSPRE += /MDd /D_DEBUG
endif

# ifeq (1$(C_SYMBOLS))
  CXXFLAGSPRE +=  /Zi
# endif

CFLAGSPRE := $(CXXFLAGSPRE)
CFLAGSPOST := $(CXXFLAGSPOST)

cdeps := ""
cout := /Fo:
cobj := .obj
csrc := /c

############################################################
# AR
############################################################

AR := "$(VCBINDIR)/lib.exe"
ARFLAGSPRE := /NOLOGO
arout := /OUT:
ifeq (i386,$(ARCH))
  ARFLAGSPRE += \
    /MACHINE:X86 \
    /LIBPATH:"$(WINKITDIR)/Lib/winv6.3/um/x86"
else
  ARFLAGSPRE += \
    /MACHINE:X64 \
    /LIBPATH:"$(WINKITDIR)/Lib/winv6.3/um/x64"
endif
libprefix:=
libsuffix:=.lib

DISABLE_FLAG_CHECKS:=1
DISABLE_DEP_GEN:=1

############################################################
# DLL
############################################################

pdbsuffix := .pdb
dlllibsuffix := .lib

DLL := "$(VCBINDIR)/link.exe"
DLLFLAGSPRE := /MANIFEST /NXCOMPAT /DYNAMICBASE
dllout := /OUT:
DLLFLAGS_PDB := /PDB:
DLLFLAGS_DLLLIB := /IMPLIB:
DLLFLAGS_LIBDIR := /LIBPATH:
DLLFLAGSPOST := /DLL /NOLOGO /ERRORREPORT:PROMPT /TLBID:1 /BASE:"0x23400000"

ifeq (i386,$(ARCH))
  DLLFLAGSPOST += /MACHINE:X86 /SAFESEH
else
  DLLFLAGSPOST += /MACHINE:X64
endif

ifeq (1,$(C_OPTIMIZE))
  DLLFLAGSPOST += /OPT:REF /INCREMENTAL:NO /OPT:ICF /NODEFAULTLIB:"libcmt.lib" \
    /NODEFAULTLIB:"libcpmt.lib"
else
  DLLFLAGSPOST += /DEBUG /INCREMENTAL /NODEFAULTLIB:"libcmt.lib" \
    /NODEFAULTLIB:"msvcrt.lib" /NODEFAULTLIB:"libcpmt.lib"
endif

# /PGD:"..\..\bin\win32-debug-v8\jsstandalone\jsstandalone.pgd"
# /ManifestFile:"..\..\bin\win32-debug-v8\jsstandalone\jsstandalone.exe.intermediate.manifest"
# /MANIFESTUAC:"level='asInvoker' uiAccess='false'"
# /LIBPATH:"../../../external_turbulenz/directx/lib/win32"

# /OUT:"..\..\bin\win32-debug-v8\jsstandalone\jsstandalone.dll"
# /MANIFEST /NXCOMPAT
# /DYNAMICBASE
# /PDB:"..\..\bin\win32-debug-v8\jsstandalone\jsstandalone.pdb"
# <libs>
# /IMPLIB:"..\..\bin\win32-debug-v8\jsstandalone\jsstandalone.lib"

# /DLL
# /SAFESEH
# /NOLOGO
# /ERRORREPORT:PROMPT
# /TLBID:1

dllprefix :=
dllsuffix := .dll

LD := "$(VCBINDIR)/link.exe"
LDFLAGSPRE := \
  /MANIFEST /NXCOMPAT  \
  /DYNAMICBASE \
  "winmm.lib" "ws2_32.lib" "gdi32.lib" "user32.lib" "advapi32.lib" "ole32.lib" \
  "shell32.lib" "version.lib"
# "dinput8.lib" "XInput9_1_0.lib" "dxguid.lib"

LDFLAGSPOST += \
  /BASE:"0x23400000" \
  /MACHINE:X64 \

ifeq (1,$(C_OPTIMIZE))
  LDFLAGSPOST += /OPT:REF /INCREMENTAL:NO /OPT:ICF \
    /NODEFAULTLIB:"libcmt.lib" /NODEFAULTLIB:"libcpmt.lib"
else
  LDFLAGSPOST += "dbghelp.lib" \
    /NODEFAULTLIB:"libcmt.lib" /NODEFAULTLIB:"libcpmt.lib"
    /NODEFAULTLIB:"msvcrt.lib"  \
    /INCREMENTAL
endif

LDFLAGSPOST += \
  /MANIFESTUAC:"level='asInvoker' uiAccess='false'"  \
  /NOLOGO /ERRORREPORT:PROMPT  \
  /TLBID:1

LDFLAGS_PDB := /PDB:
appout := /OUT:
binsuffix := .exe

# $(info Entering directory `$(shell echo %CD%)')
