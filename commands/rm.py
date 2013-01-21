
import sys
import os
import shutil

args = sys.argv
args.pop(0)
while len(args):
    d = args.pop(0)
    #print d
    if os.path.exists(d):
        if os.path.isdir(d):
            shutil.rmtree(d)
        else:
            os.unlink(d)
