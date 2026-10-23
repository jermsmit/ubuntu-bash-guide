# Tooling and testing

Professionals do not rely on memory for correctness. They let tools check
their work. Three tools will catch most of your mistakes: **ShellCheck** (static
analysis), **shfmt** (formatting) and **Bats** (tests).

Install them on Ubuntu:

```bash
sudo apt install shellcheck shfmt bats
```

## ShellCheck: a code reviewer that never sleeps

ShellCheck reads a script and warns about bugs, portability problems and bad
habits, with a numbered code (like `SC2086`) you can look up.

Here is a deliberately bad script:

```bash
#!/usr/bin/env bash
files=$(ls *.txt)
for f in $files; do echo $f; done
```

![ShellCheck output for a flawed script](images/shellcheck-demo.svg)

Run it on any script, or on many at once:

```bash
shellcheck myscript.sh
shellcheck scripts/*.sh
shellcheck -x main.sh          # also follow `source`d files
```

Codes you will meet often:

| Code | Problem |
| --- | --- |
| SC2086 | Unquoted variable: word splitting and globbing |
| SC2046 | Unquoted command substitution |
| SC2164 | `cd` without handling failure (use `cd dir \|\| exit`) |
| SC2155 | `local x=$(cmd)` hides the command's exit status |
| SC2034 | Variable assigned but never used |
| SC2012 | Parsing `ls` output instead of using globs |

If you disagree with a warning, silence it **with a reason**:

```bash
# shellcheck disable=SC2034  # used by the sourced config
UNUSED_HERE=1
```

Many editors (VS Code, Vim, Neovim) can run ShellCheck as you type. Turn that
on; it is the fastest feedback loop you will find.

## shfmt: stop arguing about indentation

```bash
shfmt -d script.sh             # show what would change (a diff)
shfmt -w -i 4 script.sh        # rewrite in place with 4-space indents
shfmt -l -i 4 .                # list files that need formatting
```

Pick one style for the project and let the tool enforce it. The repository's
`.editorconfig` already sets shell files to four spaces.

## Debugging

### Built-in tracing

<!-- test -->
```bash
cat > buggy.sh <<'SCRIPT'
#!/usr/bin/env bash
total=0
for n in 1 2 3; do
    total=$(( total + n ))
done
echo "total=$total"
SCRIPT

bash -n buggy.sh && echo "syntax OK (nothing was run)"
bash -x buggy.sh 2>&1 | head -n 8      # print each command as it executes
```

| Switch | What it does |
| --- | --- |
| `bash -n script` | Check syntax only; run nothing |
| `bash -x script` | Trace: print every command after expansion |
| `bash -v script` | Print lines as they are read |
| `set -x` / `set +x` | Turn tracing on/off inside a script |

Make the trace more useful by showing file and line numbers:

```bash
export PS4='+ ${BASH_SOURCE[0]##*/}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
bash -x myscript.sh
```

### Print debugging that you can leave in

<!-- test -->
```bash
debug() { [[ ${DEBUG:-0} == 1 ]] && printf 'debug: %s\n' "$*" >&2 || true; }

debug "this is hidden"
DEBUG=1
debug "this is shown"
```

Run a script as `DEBUG=1 ./script.sh` to turn extra output on.

## Testing with Bats

**Bats** (Bash Automated Testing System) runs shell tests and reports results
like a normal test framework.

Imagine this script, `greet.sh`, written so that its logic lives in functions:

```bash
#!/usr/bin/env bash
greet() { echo "Hello, ${1:-world}!"; }

# Only run main code when executed, not when sourced by a test
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    greet "$@"
fi
```

The `if` guard is the key trick for testable scripts: a test can `source` the
file and call functions without running the program.

A Bats test file `test/greet.bats`:

```bash
#!/usr/bin/env bats

setup() {
    source "${BATS_TEST_DIRNAME}/../greet.sh"
}

@test "greets the world by default" {
    run greet
    [ "$status" -eq 0 ]
    [ "$output" = "Hello, world!" ]
}

@test "greets a named person" {
    run greet Ada
    [ "$output" = "Hello, Ada!" ]
}

@test "script runs from the command line" {
    run bash "${BATS_TEST_DIRNAME}/../greet.sh" Linus
    [ "$status" -eq 0 ]
    [ "$output" = "Hello, Linus!" ]
}
```

Run it:

```bash
bats test/
```

Inside a test, `run` captures the command's exit code in `$status` and its
output in `$output`. Keep tests small, one behavior each, and name them so a
failure message reads like a sentence.

## Automate the checks (CI)

This repository uses GitHub Actions to run its example tests on every push.
For your own scripts, a minimal workflow looks like this:

```yaml
name: shell-quality
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: sudo apt-get update && sudo apt-get install -y shellcheck shfmt bats
      - run: shellcheck scripts/*.sh
      - run: shfmt -d -i 4 scripts
      - run: bats test/
```

## Exercises

1. Run `bash -n` on a script that has a missing `fi`. What does the error say?
2. Install ShellCheck and fix every warning in the bad script above.
3. Write a Bats test for a function `is_number` that accepts only digits.

<details>
<summary>Answers</summary>

1. Bash reports an unexpected end of file, naming the line where it expected
   `fi`.
2. Replace the `ls` capture with a glob loop and quote the variable:
   `for f in *.txt; do echo "$f"; done`
3. Source the file in `setup`, then:
   `@test "digits pass" { run is_number 123; [ "$status" -eq 0 ]; }` and
   `@test "letters fail" { run is_number 12a; [ "$status" -ne 0 ]; }`

</details>
