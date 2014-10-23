#!/usr/bin/python

import shutil
import sys
import glob
import os
import stat

def _verbose(msg):
    print msg
def _verbose_dummy(msg):
    pass

def usage():
    print """
Usage:

    cp [--timestamp|-v] src0 src1 ... srcN dst

"""

def _check_timestamp(src, dst):
    global verbose
    if os.path.isdir(dst):
        dst = os.path.join(dst, os.path.split(src)[1])
    if os.path.exists(dst):
        if (os.stat(src).st_mtime <= os.stat(dst).st_mtime):
            verbose("(dst %s not older than src %s.  Skipping)" % (dst, src))
            return False
        verbose("(dst %s older than src %s.  Copying)" % (dst, src))
    else:
        verbose("(no file '%s'. Copying)" % dst)
    return True

def main():
    global verbose

    all_files = []
    timestamp = False
    verbose = _verbose_dummy

    args = sys.argv
    args.pop(0)
    while len(args) > 0:
        a = args.pop(0)
        if "--timestamp" == a:
            timestamp = True
        elif "--verbose" == a or "-v" == a:
            verbose = _verbose
        else:
            all_files.append(a)

    if len(all_files) < 2:
        usage()
        exit(1)

    src_args = all_files[:-1]
    dest = all_files[-1]

    verbose("CWD: %s" % os.getcwd())

    for src_pattern in src_args:
        verbose("PATTERN: %s" % src_pattern)
        src_files = glob.glob(src_pattern)
        for src in src_files:
            verbose("FILE: %s" % src)
            if timestamp:
                if not _check_timestamp(src, dest):
                    continue
            shutil.copy(src, dest)

if "__main__" == __name__:
    exit(main())
