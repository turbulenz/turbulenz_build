# Copyright (c) 2013 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

# Include the appropriate rules files based on which modules types
# have been defined.

ifneq (,$(strip $(LIBS) $(DLLS) $(APPS)))
  ifneq (win32,$(TARGET))
    include $(BUILDDIR)/rules_c.mk
  endif
endif

ifneq (,$(TSLIBS))
  include $(BUILDDIR)/rules_typescript.mk
endif
