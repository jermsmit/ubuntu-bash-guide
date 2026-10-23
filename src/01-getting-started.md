# Getting started

## Terminal, shell, Bash: what is what?

Three words get mixed up constantly:

- The **terminal** is the window. It shows text and sends your keystrokes.
- The **shell** is the program inside the window that reads your commands and
  runs them.
- **Bash** is the shell Ubuntu uses by default. Others exist (`zsh`, `fish`,
  `dash`), and they differ in details.

Open a terminal on Ubuntu with **Ctrl+Alt+T**. You will see a prompt, which
looks something like this:

```console
learner@ubuntu:~/lab$
```

Read it left to right: your username, the machine name, your current
directory (`~` means your home), and `$`, which means "ready for input". A `#`
instead of `$` means you are root, the administrator. Be careful there.

Check which shell you are in and which version:

```bash
echo "$BASH_VERSION"
```

![Versions of bash, ls and sudo on Ubuntu 26.04](images/version-info.svg)

Ubuntu 26.04 ships Rust rewrites of some core tools. The screenshot above shows
which implementations you are running. See the
[Ubuntu 26.04 notes](appendix-ubuntu-26-04.md) for what that changes in practice.

## Anatomy of a command

```console
$ ls -l --all /etc
  │   │    │    └── argument: what to act on
  │   │    └─────── long option
  │   └──────────── short option
  └──────────────── the command
```

- **Options** (also called flags) change behavior. Short ones use one dash
  (`-l`), long ones use two (`--all`). Short options can be combined: `-la`
  means `-l -a`.
- **Arguments** say what to act on: files, directories, text.
- Everything is separated by spaces, which is why spaces in file names cause
  trouble. More on that in [Scripting fundamentals](07-scripting-fundamentals.md).

## Getting help

You will look things up constantly. Use these, roughly in this order:

<!-- test -->
```bash
type cd          # is it a builtin, alias, function or program?
type ls
command -v grep  # where is the program?
help cd | head -3 # help for shell builtins
ls --help | head -5
```

For full documentation, read the manual page:

```bash
man ls          # q to quit, / to search, n for next match
man -k archive  # search manual pages by keyword (same as: apropos archive)
whatis grep     # one-line description
```

A command is one of four things, and `type` tells you which:

| Kind | Example | Where it lives |
| --- | --- | --- |
| Builtin | `cd`, `echo`, `type` | Inside Bash itself |
| Program | `ls`, `grep` | A file on disk, found via `$PATH` |
| Alias | `ll` | A shortcut you or Ubuntu defined |
| Function | your own | Defined in a script or startup file |

> **Tip:** `which` only finds programs. `type` and `command -v` understand
> everything, so prefer them.

## The keyboard is faster than the mouse

These shortcuts work in Bash's line editor (called Readline):

| Keys | Action |
| --- | --- |
| **Tab** | Complete a command or file name. Press twice to list options. |
| **↑ / ↓** | Previous / next command in history |
| **Ctrl+R** | Search history as you type |
| **Ctrl+A / Ctrl+E** | Jump to start / end of line |
| **Alt+B / Alt+F** | Move back / forward one word |
| **Ctrl+W** | Delete the word before the cursor |
| **Ctrl+U** | Delete from cursor to start of line |
| **Ctrl+L** | Clear the screen (same as `clear`) |
| **Ctrl+C** | Stop the running program |
| **Ctrl+D** | End of input; at an empty prompt it exits the shell |

## Exit codes: how commands report success

Every command finishes with a number. `0` means success; anything else means
some kind of failure. The shell stores the last one in `$?`.

<!-- test -->
```bash
true
echo "true returned $?"
false
echo "false returned $?"
ls /does/not/exist 2>/dev/null
echo "ls on a missing path returned $?"
```

```console
true returned 0
false returned 1
ls on a missing path returned 2
```

(The exact non-zero number for a failed `ls` can differ between GNU and Rust
implementations. Scripts should test for "zero or not zero", not a specific
value, unless the command's documentation promises one.)

Exit codes are the foundation of shell scripting: `if`, `&&` and `||` all
react to them. You will use them heavily from
[Chapter 7](07-scripting-fundamentals.md).

## Quoting in one minute

The shell treats spaces as separators and `$`, `*`, `?` and others as special.
Quotes control that:

<!-- test -->
```bash
name="Ubuntu 26.04"
echo $name            # unquoted: split into two words (works, but risky)
echo "$name"          # double quotes: variables expand, spaces preserved
echo '$name'          # single quotes: completely literal
echo "Today is $(date +%A)"   # command substitution works in double quotes
```

Default rule: **always put double quotes around variable expansions** (`"$var"`)
unless you specifically want splitting. This one habit prevents most shell bugs.

## Exercises

1. Use `type` to find out whether `echo` is a builtin, a program, or both.
2. Open the manual for `grep` and find the option that makes it ignore case.
3. Run a command that is guaranteed to fail and print its exit code.

<details>
<summary>Answers</summary>

1. `type -a echo` shows it is both a builtin and a program (`/usr/bin/echo`).
   When you type `echo`, the builtin wins.
2. `man grep`, then type `/ignore-case` and press Enter. The option is
   `-i` / `--ignore-case`.
3. `false; echo $?` prints `1`.

</details>
