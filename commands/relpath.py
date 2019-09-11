
from __future__ import print_function

from os.path import relpath as path_relpath
from sys import argv

def usage():
    print("Usage: %s <path> [<path> ...]")
    print("")

def relpath():

    args = argv[1:]
    if 0 == len(args):
        usage()
        exit(1)
    for a in args:
        print(path_relpath(a, "."))
    return 0

if "__main__" == __name__:
    exit(relpath())
