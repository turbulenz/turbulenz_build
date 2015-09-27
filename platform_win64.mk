
# CL.EXE FLAGS (https://msdn.microsoft.com/en-us/library/19z1t1wy.aspx)
# Optimization
# /O1                - Creates small code.
# /O2                - Creates fast code.
# /Ob                - Controls inline expansion.
# /Od                - Disables optimization.
# /Og                - Uses global optimizations.
# /Oi                - Generates intrinsic functions.
# /Os                - Favors small code.
# /Ot                - Favors fast code.
# /Ox                - Uses maximum optimization (/Ob2gity /Gs).
# /Oy                - Omits frame pointer. (x86 only)
# /favor             - Produces code that is optimized for a specified
#                      architecture, or for a range of architectures.

# Code Generation
# /arch              - Use SSE or SSE2 instructions in code generation.
#                      (x86 only)
# /clr               - Produces an output file to run on the common language
#                      runtime.
# /EH                - Specifies the model of exception handling.
# /fp                - Specifies floating-point behavior.
# /GA                - Optimizes for Windows applications.
# /Gd                - Uses the __cdecl calling convention. (x86 only)
# /Ge                - Activates stack probes.
# /GF                - Enables string pooling.
# /Gh                - Calls hook function _penter.
# /GH                - Calls hook function _pexit.
# /GL                - Enables whole program optimization.
# /Gm                - Enables minimal rebuild.
# /GR                - Enables run-time type information (RTTI).
# /Gr                - Uses the __fastcall calling convention. (x86 only)
# /GS                - Checks buffer security.
# /Gs                - Controls stack probes.
# /GT                - Supports fiber safety for data allocated by using
#                      static thread-local storage.
# /Gv                - Uses the __vectorcall calling convention.
#                      (x86 and x64 only)
# /Gw                - Enables whole-program global data optimization.
# /GX                - Enables synchronous exception handling.
# /Gy                - Enables function-level linking.
# /GZ                - Enables fast checks. (Same as /RTC1)
# /Gz                - Uses the __stdcall calling convention. (x86 only)
# /homeparams        - Forces parameters passed in registers to be written to
#                      their locations on the stack upon function entry. This
#                      compiler option is only for the x64 compilers (native
#                      and cross compile).
# /hotpatch          - Creates a hotpatchable image.
# /Qfast_transcendentals - Generates fast transcendentals.
# /QIfist             - Suppresses the call of the helper function _ftol when
#                       a conversion from a floating-point type to an integral
#                       type is required. (x86 only)
# /Qimprecise_fwaits - Removes fwait commands inside try blocks.
# /Qpar              - Enables automatic parallelization of loops.
# /Qpar-report       - Enables reporting levels for automatic parallelization.
# /Qsafe_fp_loads    - Uses integer move instructions for floating-point
#                      values and disables certain floating point load
#                      optimizations.
# /Qvec-report       - Enables reporting levels for automatic vectorization.
# /RTC               - Enables run-time error checking.
# /volatile          - elects how the volatile keyword is interpreted.

# Output Files
# /doc               - Processes documentation comments to an XML file.
# /FA                - Configures an assembly listing file.
# /Fa                - Creates an assembly listing file.
# /Fd                - Renames program database file.
# /Fe                - Renames the executable file.
# /Fi                - Specifies the preprocessed output file name.
# /Fm                - Creates a mapfile.
# /Fo                - Creates an object file.
# /Fp                - Specifies a precompiled header file name.
# /FR /Fr            - Generates browser files.

# Preprocessor
# /AI                - Specifies a directory to search to resolve file
#                      references passed to the #using directive.
# /C                 - Preserves comments during preprocessing.
# /D                 - Defines constants and macros.
# /E                 - Copies preprocessor output to standard output.
# /EP                - Copies preprocessor output to standard output.
# /FI                - Preprocesses the specified include file.
# /FU                - Forces the use of a file name, as if it had been
#                      passed to the #using directive.
# /Fx                - Merges injected code with the source file.
# /I                 - Searches a directory for include files.
# /P                 - Writes preprocessor output to a file.
# /U                 - Removes a predefined macro.
# /u                 - Removes all predefined macros.
# /X                 - Ignores the standard include directory.

# Language
# /openmp            - Enables #pragma omp in source code.
# /vd                - Suppresses or enables hidden vtordisp class members.
# /vmb               - Uses best base for pointers to members.
# /vmg               - Uses full generality for pointers to members.
# /vmm               - Declares multiple inheritance.
# /vms               - Declares single inheritance.
# /vmv               - Declares virtual inheritance.
# /Z7                - Generates C 7.0–compatible debugging information.
# /Za                - Disables language extensions.
# /Zc                - Specifies standard behavior under /Ze.
# /Ze                - Enables language extensions.
# /Zg                - Generates function prototypes.
# /ZI                - Includes debug information in a program database
#                      compatible with Edit and Continue. (x86 only)
# /Zi                - Generates complete debugging information.
# /Zl                - Removes the default library name from the .obj file.
# /Zo                - Generate enhanced debugging information for
#                      optimized code in non-debug builds.
# /Zp n              - Packs structure members.
# /Zs                - Checks syntax only.
# /ZW                - Produces an output file to run on the Windows Runtime.

# Linking
# /F                 - Sets stack size.
# /LD                - Creates a dynamic-link library.
# /LDd               - Creates a debug dynamic-link library.
# /link              - Passes the specified option to LINK.
# /LN                - Creates an MSIL module.
# /MD                - Compiles to create a multithreaded DLL, by using
#                      MSVCRT.lib.
# /MDd               - Compiles to create a debug multithreaded DLL, by using
#                      MSVCRTD.lib.
# /MT                - Compiles to create a multithreaded executable file,
#                      by using LIBCMT.lib.
# /MTd               - Compiles to create a debug multithreaded executable
#                      file, by using LIBCMTD.lib.

# Precompiled Header
# /Y-                - Ignores all other precompiled-header compiler options
#                      in the current build.
# /Yc                - Creates a precompiled header file.
# /Yd                - Places complete debugging information in all object
#                      files.
# /Yu                - Uses a precompiled header file during build.

# Miscellaneous
# /?                 - Lists the compiler options.
# @                  - Specifies a response file.
# /analyze           - Enables code analysis.
# /bigobj            - Increases the number of addressable sections in an
#                      .obj file.
# /c                 - Compiles without linking.
# /cgthreads         - Specifies number of cl.exe threads to use for
#                      optimization and code generation.
# /errorReport       - Enables you to provide internal compiler error (ICE)
#                      information directly to the Visual C++ team.
# /FC                - Displays the full path of source code files passed to
#                      cl.exe in diagnostic text.
# /FS                - Forces writes to the program database (PDB) file to be
#                      serialized through MSPDBSRV.EXE.
# /H                 - Restricts the length of external (public) names.
# /HELP              - Lists the compiler options.
# /J                 - Changes the default char type.
# /kernel            - The compiler and linker will create a binary that can
#                      be executed in the Windows kernel.
# /MP                - Builds multiple source files concurrently.
# /nologo            - Suppresses display of sign-on banner.
# /sdl               - Enables additional security features and warnings.
# /showIncludes      - Displays a list of all include files during compilation.
# /Tc /TC            - Specifies a C source file.
# /Tp /TP            - Specifies a C++ source file.
# /V                 - Sets the version string.
# /Wall              - Enables all warnings, including warnings that are
#                      disabled by default.
# /W                 - Sets warning level.
# /w                 - Disables all warnings.
# /WL                - Enables one-line diagnostics for error and warning
#                      messages when compiling C++ source code from the
#                      command line.
# /Wp64              - Detects 64-bit portability problems.
# /Yd                - Places complete debugging information in all object files.
# /Yl                - Injects a PCH reference when creating a debug library.
# /Zm                - Specifies the precompiled header memory allocation limit.

# ENV:
# VS120COMNTOOLS=C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools


# WIN32:
# C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\cl.exe
#
# WIN64:
# C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\x86_amd64\cl.exe
#
# ARM:
# C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\x86_arm\cl.exe


# /I"C:\Program Files (x86)\Windows Kits\8.1\Include\um"
# /D "_CRT_SECURE_NO_DEPRECATE" /D "_SCL_SECURE_NO_WARNINGS"
# /D "_HAS_EXCEPTIONS=0" /D "_DEBUG" /D "_MBCS"
# /Fd"C:\Users\dtebbs\oyk\dev\angle\build\Debug_Win32\obj\libANGLE\vc120.pdb"
# /Fa"C:\Users\dtebbs\oyk\dev\angle\build\Debug_Win32\obj\libANGLE\"
# /Fo"C:\Users\dtebbs\oyk\dev\angle\build\Debug_Win32\obj\libANGLE\"
# /Fp"C:\Users\dtebbs\oyk\dev\angle\build\Debug_Win32\obj\libANGLE\libANGLE.pch"
#
# /I"C:\Program Files (x86)\Windows Kits\8.1\Include\shared"
# /I"C:\Program Files (x86)\Windows Kits\8.1\Include\um"
# /D "_CRT_SECURE_NO_DEPRECATE" /D "_SCL_SECURE_NO_WARNINGS"
# /D "_HAS_EXCEPTIONS=0" /D "NDEBUG" /D "_MBCS"
# /Fd"C:\Users\dtebbs\oyk\dev\angle\build\Release_Win32\obj\libANGLE\vc120.pdb"
# /Fa"C:\Users\dtebbs\oyk\dev\angle\build\Release_Win32\obj\libANGLE\"
# /Fo"C:\Users\dtebbs\oyk\dev\angle\build\Release_Win32\obj\libANGLE\"
# /Fp"C:\Users\dtebbs\oyk\dev\angle\build\Release_Win32\obj\libANGLE\libANGLE.pch"

ifeq (,$(COMPILER))
  $(error COMPILER variable not defined)
endif

############################################################
# Setup based on vs version
############################################################

ifeq (vs2013,$(COMPILER))
  ifeq (,$(VS120COMNTOOLS))
    $(error VS120COMNTOOLS env var is not set.  Is Visual Studio 2013 installed?)
  endif
  VCBASEDIR:=$(VS120COMNTOOLS)/../../VC
  WINKITDIR:=$(VS120COMNTOOLS)/../../../Windows Kits/8.1
endif

ifeq (vs2015,$(COMPILER))
  ifeq (,$(VS140COMNTOOLS))
    $(error VS140COMNTOOLS env var is not set.  Is Visual Studio 2015 installed?)
  endif
  VCBASEDIR:=$(VS140COMNTOOLS)/../../VC
  # WINKITDIR:=$(VS140COMNTOOLS)/../../../Windows Kits/10
  WINKITDIR:=$(VS140COMNTOOLS)/../../../Windows Kits/8.1
  UCRTDIR:=$(WINKITDIR)/../10/Include/10.0.10150.0/ucrt
endif

ifeq (,$(VCBASEDIR))
  $(error Unrecognized COMPILER version: $(COMPILER))
endif

ifeq (win32,$(TARGET))
  VCBINDIR:=$(VCBASEDIR)/bin
else
  ifeq (win64,$(TARGET))
    VCBINDIR:=$(VCBASEDIR)/bin/amd64
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

# $(info VS120COMNTOOLS = $(VS120COMNTOOLS))
# $(info VSBINDIR = $(VSBINDIR))
# $(info ARCH = $(ARCH))

############################################################
# CXX
############################################################

CXX := "$(VCBINDIR)/cl.exe"
CXXFLAGSPRE += /W4 /errorReport:prompt /nologo /analyze- /fp:fast /Gy \
  /Zc:wchar_t /Zc:forScope /GR /Gm- /EHsc /FS \
  -D_WINDOWS -D_USRDLL -DWIN32 -DWIN32_LEAN_AND_MEAN \
  -D_CRT_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS \
  -I"$(VCBASEDIR)/include" \
  -I"$(WINKITDIR)/Include/shared" \
  -I"$(WINKITDIR)/Include/um" \

ifneq (,$(UCRTDIR))
  CXXFLAGSPRE += -I"$(UCRTDIR)"
endif

# /WX
# /wd"4100" /wd"4127" /wd"4244" /wd"4245" /wd"4267" /wd"4702" /wd"4718"

ifeq (i386,$(ARCH))
  CXXFLAGSPRE += /Gd
endif

ifeq (1,$(C_OPTIMIZE))
  CXXFLAGSPRE += /O2 /MD -DNEDBUG
  ifeq (i386,$(ARCH))
    CXXFLAGSPRE += /Oy
  endif
else
  CXXFLAGSPRE += /GS /Od /RTC1 /MDd -DDEBUG -D_DEBUG
  ifeq (i386,$(ARCH))
    CXXFLAGSPRE += /Oy-
  endif
endif

# ifeq (1$(C_SYMBOLS))
  CXXFLAGSPRE +=  /Zi
# endif

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

$(info Entering directory `$(shell echo %CD%)')
