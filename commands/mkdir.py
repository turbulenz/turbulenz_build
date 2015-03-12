from os import makedirs
from os.path import exists
from sys import argv

def mkdir():

    args = argv[1:]

    dirs = []
    verbose = False
    create_intermediate = True

    while len(args) > 0:
        a = args.pop(0)
        if "-v" == a:
            verbose = True
        elif "-p" == a:
            # TODO: ?
            create_intermediate = True
        elif "-h" == a or "--help" == a:
            usage()
            exit(0)
        else:
            dirs.append(a)

    for d in dirs:
        if not exists(d):
            if verbose:
                print "Making dir: %s" % d

            try:
                makedirs(d)
            except OSError, e:
                # Directory may have already been created after the check
                # above
                pass

            if not exists(d):
                print "Error creating dir: %s" % d
                return 1

    return 0

if "__main__" == __name__:
    exit(mkdir())
