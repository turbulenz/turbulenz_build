# Copyright (c) 2016 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

space:= #

# ensure_trailing_slash
# 1 - path
# Put a slash at the end of a path if there isn't already one there
ensure_trailing_slash=$(if $(notdir $(1)),$(1)/,$(1))
