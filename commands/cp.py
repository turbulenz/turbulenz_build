#!/usr/bin/python

import shutil
import sys
import glob

all_files = sys.argv[1:]
if len(all_files) < 2:
    usage()
    exit(1)

src_args = all_files[:-1]
dest = all_files[-1]

for src_pattern in src_args:
    src_files = glob.glob(src_pattern)
    for src in src_files:
        shutil.copy(src, dest)
