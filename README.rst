
Introduction
============

A build description file uses Make syntax.  It is usually called
`Makefile` and typically takes the form::

    BUILDDIR := tzbuild           # Path to the tzbuild directory
    include $(BUILDDIR)/config.mk


    # ...
    # Module declarations
    # ...


    include $(BUILDDIR)/rules.mk

The header sets the BUILDDIR variable to point to the root of tzbuild
(required), and calls config.mk, which sets up several variables
related to the build environment.  Module declarations are then made,
which describe the modules to be built and dependencies between them.
Finally, rules.mk is called, which generates all build rules based on
the module delcarations.

Modules
=======

Modules are just a set of variables describing properties such as the
location of source code, or depedent modules.  Below is an example of
a TypeScript module declaration

    mymod_src := mymod/file1.ts mymod/file2.ts
    mymod_deps := someothermod
    TSLIBS += mymod

The last line here adds the name of the module `mymod` to the special
variable TSLIBS.  The system will later check this variable to find
the complete list of modules to build.  Here we have defined just two
properties of `mymod`, the source files, and a module `someothermode`
on which it depends.  Given this name, tzbuild will check for
variables of the appropriate name, for example `mymod_src`, etc. to
find source files.

Dependencies result in different behavior depending on the module
types (and in some cases build configuration), but the intention is
that the user only needs to specify dependencies between modules, and
tzbuild will calculate all include paths, linked libraries (in the
case of C++) and other build related parameters.  For TypeScript
modules, the system ensures that declarations for dependent modules
are available, and generates the appropriate commandlines to include
them.

There should be no need to specify this information by hand, and it
should be automatically applied to all build configurations.  This is
in stark contrast to 'project' based systems, where the user must
often specify project dependencies, include paths to dependencies and
library files to link against by hand, often for each build
configuration.

TypeScript
==========

TypeScript modules are added to the `TSLIB` variable.  Each module can
define the following variables:

 `<modname>_src`

   (required) A list of source files to build

 `<modname>_deps`

   (optional) A list of dependent modules

 `<modname>_nodecls`

   (optional) Set to 1 if declarations should not be created for this
   module.

Global variables that control the building of TypeScript modules include:

  `TSLIBS`

    (required) The list of TypeScript modules to build

  `TS_SRC_DIR`

    (required for non-modular builds) The base directory of all source
    files.  This is required when buildling TS files one-to-one into a
    destination directory so that the system can reconstruct the
    layout of source and destination files.

  `TS_REFCHECK`

    (optional) Set to 1 to enable reference checking.  This ensures
    that all reference statements in the code are in order.  Note that
    references are not a requirement of tzbuild, since tzbuild can
    calculate all dependencies from the module declarations.  Some
    IDEs require that references be inserted into the code, and this
    mode can be used to ensure that references are correct.

  `TS_MODULAR`  (1 by default)

    (optional) Set to 1 to enable a modular build.  This uses the
    dependencies described in the module declarations to build each
    module into a .js file.  All modules are expected to compile with
    no type errors, and a .d.ts declaration file is also generated
    (unless the `_nodecls` variable has been set).

If neither `TS_MODULAR` or `TS_REFCHECK` are set to `1`, the build
turns each .ts file into a .js file in the destination directory, and
does NO type checking.  This is intended for people migrating to
typescript who wish to introduce a build and enable type checking
later.  Modular and refcheck builds inist that code is type-correct.

By default, modular builds are performed.  Set `TS_MODULAR` or
`TS_REFCHECK` appropriately in your Makefile to enable a different
mode by default.

Below are some advanced / internal variables.  All optional.

  `TS_OUTPUT_DIR`

    Controls the destination of build output.  By default this is one
    of `jslib`, `jslib-modular`, `jslib-refcheck` based on the build
    mode, but it can be overriden.

  `_<mod>_out_js`

    Overrides the destination file for the given module.  Used only
    when `TS_MODULAR` is set.

Configuration Variables
=======================

`TARGET`
`TARGETNAME`

`CONFIG`
