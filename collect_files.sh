#!/bin/bash

max_depth=""
if [[ "$1" == "--max_depth" ]]; then
    max_depth="$2"
    shift 2
fi

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 [--max_depth N] /path/to/input_dir /path/to/output_dir"
    exit 1
fi

input_dir="$1"
output_dir="$2"

if [[ ! -d "$input_dir" ]]; then
    echo "Input directory does not exist: $input_dir"
    exit 1
fi

mkdir -p "$output_dir"

python3 - <<END
import os
import shutil

inpdir = os.path.abspath("$input_dir")
outdir = os.path.abspath("$output_dir")
mxdepth = int("$max_depth") if "$max_depth" else None
usednames = dict()
lenofinpdir = len(inpdir.rstrip(os.sep).split(os.sep))
for root, dirs, files in os.walk(inpdir):
    depth = len(root.rstrip(os.sep).split(os.sep)) - lenofinpdir + 1
    if mxdepth is not None and depth > mxdepth:
        dirs[:] = []
        continue
    for fname in files:
        base, ext = os.path.splitext(fname)
        name = fname
        count = usednames.get(fname, 0)
        while os.path.exists(os.path.join(outdir, name)) or name in usednames.values():
            count += 1
            name = f"{base}{count}{ext}"
        usednames[fname] = count
        src = os.path.join(root, fname)
        dst = os.path.join(outdir, name)
        shutil.copy2(src, dst)
END
