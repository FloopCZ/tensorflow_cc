#!/bin/bash
set -e
# This file recursively traverses a directory and replaces each
# link by a copy of its target.

# To properly handle whitespace characters in filenames, we need to use
# an ugly `find` and `read` trick.
find -L "$1" -print0 |
    while IFS= read -r -d $'\0' f; do
        # We need to check whether the file is still a link.
        # It may have happened that we have already replaced it by
        # the original when some of its parent directories were copied.
        if [[ -L "$f" ]]; then
            realf="$(realpath "$f")"
            rm "$f"
            cp -r "$realf" "$f"
        fi
    done
