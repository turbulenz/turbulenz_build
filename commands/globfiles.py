#!/usr/bin/python

from __future__ import print_function

import os.path
import sys
import glob

def main():

    join = os.path.join

    _wildcards = []
    _paths = []

    args = sys.argv
    args.pop(0)
    while 0 != len(args):
        a = args.pop(0)
        if "--wildcard" == a:
            _wildcards.append(args.pop(0))
        else:
            _paths.append(a)

    # print("_wildcard: %s" % _wildcard)
    # print("_paths: %s" % _paths)

    files = []
    if 0 != len(_wildcards):
        for p in _paths:
            for w in _wildcards:
                files += [f.replace('\\', '/').replace(' ', '\\ ') \
                          for f in glob.glob(join(p, w))]
    else:
        for p in _paths:
            files += [f.replace('\\', '/').replace(' ', '\\ ') \
                      for f in glob.glob(p)]

    #print(sys.argv[1])
    #sys.stderr.write("GLOB: %s,  RESULT: %s\n" % (sys.argv[1], result))
    result = " ".join(files)
    print("%s" % result)
    return 0

if "__main__" == __name__:
    exit(main())
