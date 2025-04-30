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
outpdir = os.path.abspath("$output_dir")
mxdepth= int("$max_depth") if "$max_depth" else None
for root, dirs, files in os.walk(inpdir):
    repath = os.path.relpath(root, inpdir)
    reparts = repath.split(os.sep) if repath != '.' else []
    depth = len(reparts) + 1
    if mxdepth is not None and depth > max_depth:
        dirs[:] = []
        continue
    outdir = os.path.join(outpdir, *reparts) if repath != '.' else outpdir
    os.makedirs(outdir, exist_ok=True)
    usednames = set(os.listdir(outdir))
    for fname in files:
        src = os.path.join(root, fname)
        dst = os.path.join(outdir, fname)
        if fname in usednames:
            base, ext = os.path.splitext(fname)
            i = 1
            newname = f"{base}{i}{ext}"
            while newname in usednames:
                i += 1
                newname = f"{base}{i}{ext}"
            dst = os.path.join(outdir, newname)
            usednames.add(newname)
        else:
            usednames.add(fname)
        shutil.copy2(src, dst)
END
