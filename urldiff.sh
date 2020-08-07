#!/bin/sh
# diffs contents of two different URLs

file1="$(mktemp)"
file2="$(mktemp)"

curl -so "$file1" "$1"
curl -so "$file2" "$2"

git diff --no-index "$file1" "$file2"
rm "$file1" "$file2"