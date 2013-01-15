import os
import sys

############################################################

def _read_file(filename):
    with open(filename, 'rb') as f:
        return f.read()

def cat(infiles):

    if len(infiles) < 1:
        usage()
        return 1

    # Dump all files to stdout

    for f in infiles:
        print _read_file(f)
    return 0

############################################################

if "__main__" == __name__:
    exit(cat(sys.argv[1:]))
