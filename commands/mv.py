#!/usr/bin/python

def _verbose(msg):
    print msg
def _verbose_dummy(msg):
    pass

def usage():
    print """
Usage:

    mv src dst

"""

def main():
    from shutil import move
    from sys import argv
    from os.path import exists

    global verbose
    verbose = _verbose_dummy

    args = argv
    args.pop(0)
    if 2 != len(args):
        usage()
        exit(1)

    if not exists(argv[0]):
        print "No such file '%s'" % argv[0]
        usage()
        exit(1)

    move(argv[0], argv[1])
    return 0

if "__main__" == __name__:
    exit(main())
