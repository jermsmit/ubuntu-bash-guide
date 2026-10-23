#!/usr/bin/env bash
# Renders real command output as SVG images using Charm's `freeze`.
# Run this INSIDE the Ubuntu 26.04 lab container so the output is authentic:
#     make screenshots
#
# Reads scripts/screenshots.txt ("name | command" per line).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${OUT_DIR:-$root/src/images}"
manifest="$root/scripts/screenshots.txt"
fmt="${FORMAT:-svg}"

command -v freeze >/dev/null || { echo "freeze is not installed (see Dockerfile)" >&2; exit 1; }
mkdir -p "$out"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

count=0
while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    name="${line%%|*}"; name="${name// /}"
    cmd="${line#*|}"; cmd="${cmd# }"

    sandbox="$work/$name"
    mkdir -p "$sandbox"
    cp -r "$root/lab/." "$sandbox/"

    {
        printf '\033[1;32mlearner@ubuntu\033[0m:\033[1;34m~/lab\033[0m$ %s\n' "$cmd"
        (cd "$sandbox" && bash -c "$cmd" 2>&1) || true
    } > "$work/$name.ansi"

    freeze "$work/$name.ansi" \
        --language ansi --window --padding 20,24 --margin 0 \
        --font.size 14 --line-height 1.3 --theme dracula \
        --output "$out/$name.$fmt" </dev/null >/dev/null
    count=$((count + 1))
    echo "wrote $name.$fmt"
done < "$manifest"

echo "Generated $count images in $out"
