import os
import sys

############################################################

def _read_file(filename):
    try:
        with open(filename, 'rb') as f:
            return f.read()
    except IOError:
        exit(-1)

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
