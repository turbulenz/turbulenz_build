from os import makedirs
from os.path import exists
from sys import argv

d = argv[1]
if not exists(d):
    print "Making dir: %s" % d
    try:
        makedirs(d)
    except OSError, e:
        # Directory may have already been created after the check
        # above
        pass

    if not exists(d):
        print "Error creating dir: %s" % d
        exit(1)
