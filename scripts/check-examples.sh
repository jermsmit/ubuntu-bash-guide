#!/usr/bin/env bash
# Runs every code block in src/*.md that is marked with <!-- test --> on the
# line directly before the opening fence. Each block runs in a fresh copy of
# lab/ and must exit with status 0.
#
# Usage: scripts/check-examples.sh [file.md ...]
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

files=("$@")
if (( ${#files[@]} == 0 )); then
    files=("$root"/src/*.md)
fi

# 1. Extract marked blocks into $work/blocks/NNN__file__line.sh
mkdir -p "$work/blocks"
for f in "${files[@]}"; do
    awk -v out="$work/blocks" -v src="$(basename "$f")" '
        /^<!-- test -->[[:space:]]*$/ { armed = 1; next }
        armed && /^```/ && !inblock   { inblock = 1; armed = 0; n++
                                        file = sprintf("%s/%s__%03d__line%d.sh", out, src, n, NR + 1)
                                        next }
        inblock && /^```[[:space:]]*$/ { inblock = 0; close(file); next }
        inblock                        { print > file }
        { armed = 0 }
    ' "$f"
done

shopt -s nullglob
blocks=("$work"/blocks/*.sh)
if (( ${#blocks[@]} == 0 )); then
    echo "No <!-- test --> blocks found." >&2
    exit 1
fi

pass=0
fail=0
for b in "${blocks[@]}"; do
    name="$(basename "$b" .sh)"
    sandbox="$work/run/$name"
    mkdir -p "$sandbox"
    cp -r "$root/lab/." "$sandbox/"
    if (cd "$sandbox" && timeout 30 bash "$b" >"$work/out.txt" 2>&1); then
        pass=$((pass + 1))
        printf 'ok    %s\n' "$name"
    else
        fail=$((fail + 1))
        printf 'FAIL  %s\n' "$name"
        sed 's/^/      | /' "$b"
        echo "      --- output ---"
        sed 's/^/      | /' "$work/out.txt"
    fi
done

echo
echo "Passed: $pass   Failed: $fail"
(( fail == 0 ))
