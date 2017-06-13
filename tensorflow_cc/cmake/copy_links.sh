#!/bin/sh
set -e
for f in $(find "$1" -type l); do
    realf="$(realpath $f)"
    unlink "$f"
    cp -r "$realf" "$f"
done
