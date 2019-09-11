
from __future__ import print_function

import sys
import os
import shutil

def try_catch_n(fn, times):
    if 0 >= times:
        return
    try:
        fn()
    except Exception:
        try_catch_n(fn, times-1)

args = sys.argv
args.pop(0)

while len(args):
    d = args.pop(0)
    #print(d)

    def delete():
        if os.path.exists(d):
            if os.path.isdir(d):
                shutil.rmtree(d)
            else:
                os.unlink(d)

    try_catch_n(delete, 4)
