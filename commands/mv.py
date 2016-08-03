#!/usr/bin/python

def _verbose(msg):
    print msg
def _verbose_dummy(msg):
    pass

def usage():
    print """
Usage:

    mv [--replace-if-different] src dst

"""

def are_same(a, b):
    with open(a, "rb") as af:
        ad = af.read()
        with open(b, "rb") as bf:
            bd = bf.read()
            return ad == bd

def main():
    from shutil import move
    from sys import argv
    from os.path import exists
    from os import unlink

    global verbose
    verbose = _verbose_dummy

    src = None
    dst = None
    replace_if_different = False

    args = argv
    args.pop(0)
    while len(args):
        a = args.pop(0)
        if "--replace-if-different" == a:
            replace_if_different = True
        elif src is None:
            src = a
        elif dst is None:
            dst = a
        else:
            print "Invalid argument: %s" % a
            usage()
            return 1

    if not exists(src):
        print "No such file '%s'" % src
        usage()
        exit(1)

    if replace_if_different:
        if are_same(src, dst):
            unlink(src)
            return 0

    move(src, dst)
    return 0

if "__main__" == __name__:
    exit(main())
