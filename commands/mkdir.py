from os import makedirs
from os.path import exists
from sys import argv

def mkdir():

    args = argv[1:]

    d = None
    verbose = False
    create_intermediate = True

    while len(args) > 0:
        a = args.pop(0)
        if "-v" == a:
            verbose = True
        elif "-p" == a:
            # TODO: ?
            create_intermediate = True
        else:
            if not d is None:
                usage()
                return 1
            d = a

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
