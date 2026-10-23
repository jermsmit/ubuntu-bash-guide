#!/usr/bin/env bash
# One-time helper: replaces the placeholder GitHub username everywhere.
# Usage: scripts/init-repo.sh your-github-username [repo-name]
set -euo pipefail

user="${1:?usage: $0 github-username [repo-name]}"
repo="${2:-ubuntu-bash-guide}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

{ grep -rl --exclude-dir=.git --exclude-dir=book --exclude=init-repo.sh 'YOUR_GITHUB_USERNAME' "$root" || true; } |
    while IFS= read -r f; do
        sed -i "s#YOUR_GITHUB_USERNAME#${user}#g" "$f"
        echo "updated ${f#"$root"/}"
    done

if [[ "$repo" != "ubuntu-bash-guide" ]]; then
    { grep -rl --exclude-dir=.git --exclude-dir=book --exclude=init-repo.sh 'ubuntu-bash-guide' "$root" || true; } |
        while IFS= read -r f; do
            sed -i "s#ubuntu-bash-guide#${repo}#g" "$f"
        done
    echo "repo name set to ${repo}"
fi
echo "Done. Your site will be at https://${user}.github.io/${repo}/"
