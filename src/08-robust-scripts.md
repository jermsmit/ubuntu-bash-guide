# Robust scripts

A script that works on your laptop once is easy. A script that fails safely,
cleans up after itself, and tells you what went wrong is a different craft.
This chapter collects the habits that separate the two.

## Strict mode, and its limits

Many scripts begin with:

```bash
set -euo pipefail
```

| Option | Effect |
| --- | --- |
| `-e` | Exit immediately if a command fails |
| `-u` | Treat use of an unset variable as an error |
| `-o pipefail` | A pipeline fails if *any* stage fails, not just the last |

This catches a lot of silent failures. See the difference:

<!-- test -->
```bash
# Without pipefail the pipeline "succeeds" because wc succeeds
false | wc -l > /dev/null; echo "no pipefail: exit $?"

set -o pipefail
false | wc -l > /dev/null || echo "with pipefail: failure detected"
```

Be aware that `set -e` has surprising corners. It is ignored inside `if`
conditions, on the left of `&&`/`||`, and in some subshell situations. Treat it
as a safety net, not a substitute for checking things that can reasonably fail:

<!-- test -->
```bash
set -e
if ! grep -q kiwi data/fruits.txt; then
    echo "no kiwi in the list, carrying on"
fi
# A command you EXPECT might fail: handle it explicitly
count=$(grep -c kiwi data/fruits.txt || true)
echo "kiwi count: $count"
```

(`grep -c` prints `0` but exits `1` when nothing matches, which would abort a
`set -e` script without the `|| true`.)

## Always quote, and prefer arrays for argument lists

The most common real-world shell bug is an unquoted variable:

<!-- test -->
```bash
dir="my project"
mkdir "$dir"
touch "$dir/a.txt" "$dir/b.txt"

# Dangerous pattern: with an empty $dir this would be `rm -rf /*`
# rm -rf $dir/*
# Safer: refuse to continue if the variable is empty, and quote it
rm -rf "${dir:?dir is not set}"/*
ls -A "$dir" | wc -l
```

When building a command from parts, use an **array**, not a string:

<!-- test -->
```bash
opts=(-l -a)
ls "${opts[@]}" data | head -n 3
if [[ -n ${EXTRA_OPT:-} ]]; then opts+=("$EXTRA_OPT"); fi
```

## Clean up with `trap`

`trap` runs a command when the script exits, however it exits: normally, on an
error, or from Ctrl+C.

<!-- test -->
```bash
set -euo pipefail

tmpdir=$(mktemp -d)                 # unique, private temp directory
cleanup() {
    rm -rf "$tmpdir"
    echo "cleaned up $tmpdir"
}
trap cleanup EXIT

echo "working in $tmpdir"
cp data/people.csv "$tmpdir/"
wc -l "$tmpdir/people.csv"
# when the script ends, cleanup runs automatically
```

Never invent temp file names like `/tmp/myscript.tmp`. They are predictable
(a security problem) and collide when two copies run at once. Use `mktemp`.

## Check your dependencies

Fail early and clearly if something you need is missing:

<!-- test -->
```bash
require() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "error: required command '$1' not found" >&2
        return 1
    }
}
require awk
require sort
require definitely-not-installed || echo "(expected failure shown above)"
```

## Errors go to stderr; use meaningful exit codes

Print diagnostics to stderr (`>&2`) so that normal output stays clean for
pipes, and exit non-zero on failure:

<!-- test -->
```bash
log()  { printf '%s [%s] %s\n' "$(date +%T)" "$1" "${*:2}" >&2; }
die()  { log ERROR "$@"; exit 1; }

log INFO "starting"
log WARN "disk is 91% full"
( die "something broke" ) || echo "die exited with status $?"
```

By convention: `0` success, `1` general error, `2` misuse (bad arguments),
`126`/`127` command not executable/not found, and `128+N` killed by signal N.

## Parsing options with `getopts`

Here is a complete, realistic template. It handles options, validates input,
cleans up, logs to stderr and does its work in `main`. Copy it as the starting
point for new scripts.

<!-- test -->
```bash
#!/usr/bin/env bash
#
# greet.sh - say hello, politely.
#
# Usage: greet.sh [-n NAME] [-c COUNT] [-v] [-h]

set -euo pipefail

readonly PROGRAM="${0##*/}"

usage() {
    cat <<USAGE
Usage: $PROGRAM [-n NAME] [-c COUNT] [-v] [-h]

  -n NAME    who to greet (default: world)
  -c COUNT   how many times (default: 1)
  -v         verbose output
  -h         show this help
USAGE
}

log() { printf '%s\n' "$*" >&2; }
die() { log "error: $*"; exit 1; }

main() {
    local name="world" count=1 verbose=0 opt

    while getopts ':n:c:vh' opt; do
        case "$opt" in
            n) name=$OPTARG ;;
            c) count=$OPTARG ;;
            v) verbose=1 ;;
            h) usage; exit 0 ;;
            :) die "option -$OPTARG needs an argument" ;;
            *) usage >&2; exit 2 ;;
        esac
    done
    shift $((OPTIND - 1))          # what is left in "$@" are positional args

    [[ $count =~ ^[1-9][0-9]*$ ]] || die "count must be a positive integer, got '$count'"
    (( verbose )) && log "greeting $name $count time(s)"

    local i
    for (( i = 0; i < count; i++ )); do
        echo "Hello, $name!"
    done
}

main "$@"
```

A few things worth noticing:

- `main "$@"` at the bottom means the whole script is defined before anything
  runs, so a half-written file cannot execute half a program.
- `local` keeps function variables contained.
- Input is validated *before* it is used.
- `die` writes to stderr and exits non-zero.

For long options (`--name`), use a `while`/`case` loop over `"$1"` with `shift`.

## Make scripts safe to run twice (idempotency)

A good script can be run again without breaking anything. Prefer commands that
describe a *desired state*:

<!-- test -->
```bash
mkdir -p backups                       # fine if it already exists
ln -sfn data current-data              # replace the link if present
grep -qxF 'export EDITOR=nano' notes.txt || echo 'export EDITOR=nano' >> notes.txt
grep -qxF 'export EDITOR=nano' notes.txt || echo 'export EDITOR=nano' >> notes.txt
grep -c 'EDITOR' notes.txt             # still 1
```

## Prevent two copies running at once

`flock` gives you a simple lock:

```bash
exec 9>/tmp/myjob.lock
flock -n 9 || { echo "another copy is already running" >&2; exit 1; }
# ... the lock is released when the script ends
```

## Confirm destructive actions

<!-- test -->
```bash
confirm() {
    local reply
    read -r -p "${1:-Are you sure?} [y/N] " reply
    [[ ${reply,,} == y* ]]
}

# simulate a user typing "y"
if confirm "Delete everything?" <<< "y"; then echo "(would delete)"; fi
# simulate pressing Enter (the default is No)
if confirm "Delete everything?" <<< ""; then echo "(would delete)"; else echo "cancelled"; fi
```

Also give destructive scripts a `--dry-run` option that prints what *would*
happen. People will thank you.

## Security checklist

- Quote everything. Validate arguments before using them.
- Never build commands with `eval` and untrusted input.
- Use `mktemp`, not fixed temp names.
- Do not put secrets in command-line arguments; other users can see them in
  `ps`. Read them from files with tight permissions (`chmod 600`) or environment
  variables.
- Do not run scripts as root unless you must; if you do, use absolute paths or
  set `PATH` yourself.
- Download, read, then run. Do not pipe unknown scripts into `bash`.

## When to stop using Bash

If your script needs nested data structures, real parsing of JSON/YAML/CSV,
heavy string processing, or runs past a couple of hundred lines, Python is
usually the better tool. Shell shines at gluing programs together, not at
being a programming language.

## Exercises

1. Add a `--dry-run`-style `-d` flag to the template that prints the greeting
   prefixed with `[dry-run]`.
2. Write a script that creates a temp directory, copies `data/people.csv`
   into it, counts the lines, and always deletes the directory, even if the
   script is interrupted.
3. What goes wrong with `for f in $(ls *.txt)` and what is the fix?

<details>
<summary>Answers</summary>

1. Add `d` to the `getopts` string, set `dry=1` for `d)`, and print
   `[dry-run] Hello, $name!` instead when `dry` is set.
2. See the `trap cleanup EXIT` example above; `EXIT` also fires on Ctrl+C
   and on errors with `set -e`.
3. Command output is split on whitespace, so a file named `my notes.txt`
   becomes two words, and `ls` output should never be parsed. Use a glob:
   `for f in *.txt; do ...; done`.

</details>
