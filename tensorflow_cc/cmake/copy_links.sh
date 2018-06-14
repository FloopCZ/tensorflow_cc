#!/bin/bash
set -e
# This file recursively traverses a directory and replaces each
# link by a copy of its target.

echo "Replacing links with the copies of their targets."
echo "This may take a while..."
# To properly handle whitespace characters in filenames, we need to use
# an ugly `find` and `read` trick.
find -L "$1" -depth -print0 |
    while IFS= read -r -d $'\0' f; do
        # We need to check whether the file is still a link.
        # It may have happened that we have already replaced it by
        # the original when some of its parent directories were copied.
        # Also the first check is to detect whether the file (after
        # symlink dereference) exists so that `realpath` does not fail.
        if [[ -w "$f" ]] && [[ -L "$f" ]]; then
            realf="$(realpath "$f")"
            rm "$f"
            cp -r --link "$realf" "$f" 2>/dev/null || cp -r "$realf" "$f"
        fi
    done
