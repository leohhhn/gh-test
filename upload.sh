#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <root_directory>"
    exit 1
fi

root_dir="$1"

cd "$root_dir" || { echo "Failed to change to directory $root_dir"; exit 1; }

find . -type f -name "*.json" | while read json_file; do
    pkg_dir=$(dirname "$json_file")

    echo "found pkg at $pkg_dir"
    echo "staging..."
    git add "$pkg_dir"
    echo "committing..."
    git commit -m "Add package: $pkg_dir"
done

