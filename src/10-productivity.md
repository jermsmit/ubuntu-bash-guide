# Productivity

You now know enough commands to be dangerous. This chapter is about making
the shell *comfortable*: shortcuts, history tricks, aliases, a good prompt and
tools that remove friction.

## Startup files

Which file does Bash read? On Ubuntu:

| File | Read when |
| --- | --- |
| `~/.bashrc` | Every interactive non-login shell: **put your aliases and functions here** |
| `~/.profile` | Login shells (SSH logins, console). Ubuntu's version also loads `~/.bashrc` |
| `~/.bash_aliases` | Loaded by Ubuntu's default `.bashrc` if it exists: a tidy place for aliases |
| `~/.bash_logout` | When a login shell exits |

> Older guides tell you to edit `~/.bash_profile`. That is the macOS habit. On
> Ubuntu, use `~/.bashrc` (or `~/.bash_aliases`). A `~/.bash_profile` file, if
> present, can even stop `~/.profile` from being read.

After editing, load the changes into your current shell:

```bash
source ~/.bashrc
```

## Aliases and functions

An alias is a short name for a longer command:

```bash
# ~/.bash_aliases
alias ll='ls -alFh'
alias ..='cd ..'
alias gs='git status -sb'
alias grep='grep --color=auto'
alias please='sudo $(fc -ln -1)'   # re-run the last command with sudo
```

If you need arguments in the middle, or any logic, write a **function**:

```bash
# make a directory and go into it
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# extract any common archive
extract() {
    case "$1" in
        *.tar.gz|*.tgz) tar -xzf "$1" ;;
        *.tar.xz)       tar -xJf "$1" ;;
        *.tar.bz2)      tar -xjf "$1" ;;
        *.zip)          unzip "$1" ;;
        *.gz)           gunzip "$1" ;;
        *) echo "don't know how to extract '$1'" >&2; return 1 ;;
    esac
}
```

Check what an alias does with `type ll`, remove one with `unalias ll`, and
bypass an alias once with a leading backslash (`\ls`).

## History

Bash remembers what you type. Use it.

| Command | Result |
| --- | --- |
| **Ctrl+R** | Reverse search: type part of an old command |
| `history \| tail -n 20` | Recent commands |
| `!!` | Repeat the last command |
| `sudo !!` | Repeat the last command with sudo |
| `!$` | The last argument of the previous command |
| `!grep` | Last command that started with `grep` |
| `^old^new` | Repeat the last command, replacing `old` with `new` |
| **Alt+.** | Insert the last argument of the previous command (press again to cycle) |

Better history settings for `~/.bashrc`:

```bash
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups   # skip duplicates and commands starting with a space
shopt -s histappend                # do not overwrite history from other terminals
```

Because `HISTCONTROL` includes `ignorespace`, you can type a leading space
before a command containing a secret, and it will not be saved.

## Shell options worth enabling

```bash
shopt -s globstar     # ** matches files in any depth: ls **/*.md
shopt -s autocd       # type a directory name to cd into it
shopt -s cdspell      # fix small typos in cd arguments
shopt -s checkwinsize # update $LINES/$COLUMNS after resizing the window
```

## Tab completion

Ubuntu ships `bash-completion`, so Tab completes more than file names: package
names after `apt install`, services after `systemctl`, branches after
`git checkout`. If it is not working in a minimal install:

```bash
sudo apt install bash-completion
```

## Your prompt

The prompt is controlled by `PS1`. A compact, informative one:

```bash
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '
```

`\u` is the user, `\h` the host, `\w` the working directory and `\$` becomes
`$` (or `#` for root). The `\[ \]` pairs wrap color codes so line editing
measures the prompt correctly.

For git branch info, icons and more, look at **starship** or **oh-my-posh**,
which are fast, cross-shell prompts.

## Your own scripts on the PATH

Put personal scripts in `~/.local/bin`. Ubuntu's default `~/.profile` adds that
directory to `PATH` if it exists (log out and back in once after creating it).

```bash
mkdir -p ~/.local/bin
cp greet.sh ~/.local/bin/greet
chmod +x ~/.local/bin/greet
greet Ada
```

## Environment variables for the long term

`export FOO=bar` only affects the current shell. To keep it, put the line in
`~/.bashrc`, for example:

```bash
echo 'export EDITOR=nano' >> ~/.bashrc
```

Do not put secrets (API keys) in files you commit or share. Keep them in a
file such as `~/.config/myapp/env` with mode `600` and source it.

## Modern replacements worth knowing

| Classic | Modern | Why |
| --- | --- | --- |
| `grep -r` | `rg` (ripgrep) | Faster, ignores `.git`, readable output |
| `find` | `fd` (`fdfind` on Ubuntu) | Short syntax, sane defaults |
| `cat` | `bat` (`batcat` on Ubuntu) | Syntax highlighting, paging |
| `top` | `htop` | Interactive and colored |
| `ls` | `eza` | Icons, git status, tree view |
| `cd` | `zoxide` (`z`) | Jump to frequent directories |
| Ctrl+R | `fzf` | Fuzzy-search history and files |

On Ubuntu some commands install under a different name (`fdfind`, `batcat`)
to avoid conflicts. Add aliases if you like the short names:

```bash
alias fd=fdfind
alias bat=batcat
```

## `tmux`: terminals that persist

`tmux` keeps your sessions alive on a server after you disconnect and lets you
split one terminal into panes.

```bash
tmux new -s work       # start a session called "work"
# Ctrl+b then d        # detach (leave it running)
tmux ls                # list sessions
tmux attach -t work    # come back later
```

Inside tmux, the **prefix** is `Ctrl+b`. Then press `%` to split vertically,
`"` to split horizontally, an arrow key to move between panes, `c` for a new
window and `n`/`p` for next/previous window.

## Dotfiles

Once your setup is comfortable, keep `.bashrc`, `.bash_aliases`, `.tmux.conf`
and similar files in a git repository so you can reproduce your environment on
any new machine in minutes.

## Exercises

1. Create an alias `ll` that shows hidden files with human-readable sizes, and
   make it permanent.
2. Write a function `backup` that copies its first argument to
   `<name>.bak`.
3. Use history expansion to rerun your last `apt update` with `sudo`.

<details>
<summary>Answers</summary>

1. Add `alias ll='ls -alh'` to `~/.bash_aliases`, then `source ~/.bashrc`.
2. `backup() { cp -- "$1" "$1.bak"; }`
3. `sudo !!` (or `sudo !apt` to repeat the last command starting with `apt`).

</details>
