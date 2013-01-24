#!/usr/bin/env python2.7
# Copyright (c) 2013 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

import os
import glob
import sys

def find(dirname, pattern):
    for root, dirs, files in os.walk(dirname):
        found = glob.glob(os.path.join(root, pattern))
        for f in found:
            print f
    return 0


def usage():
    print "Usage:  %s [<dir>] [options]" % sys.argv[0]
    print ""
    print "Options:"
    print "  -iname '<pattern>'    - find all files that match pattern,"
    print "                          e.g. '*.js'"
    print ""


if "__main__" == __name__:

    dirname = "."
    pattern = "*"

    args = sys.argv[1:]
    while len(args) > 0:
        a = args.pop(0)
        if '-iname' == a:
            pattern = args.pop(0)
        else:
            dirname = a

    exit(find(dirname, pattern))
