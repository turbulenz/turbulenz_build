#!/usr/bin/python

import shutil
import sys

all_files = sys.argv[1:]
if len(all_files) < 2:
    usage()
    exit(1)

src_files = all_files[:-1]
dest = all_files[-1]

for s in src_files:
    shutil.copy(s, dest)
