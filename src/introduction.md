# The Ubuntu Bash Guide

A practical, hands-on guide to the Linux command line and Bash scripting,
written for **Ubuntu 26.04 LTS (Resolute Raccoon)**.

You will learn to move around a system, process text, chain programs
together, and write shell scripts that are safe to run unattended. Every
chapter ends with exercises, and every example in this book is run
automatically against a real Ubuntu 26.04 container, so the output you see is
the output you will get.

## Who this is for

- New Ubuntu users who want to stop being afraid of the terminal.
- Developers and students moving from Windows or macOS (including WSL users).
- Anyone who writes shell scripts and wants to write them well.

You do not need prior experience. You do need an Ubuntu 26.04 system, a
container, or WSL.

## How to use this book

Type the examples. Do not paste them. The goal is to build muscle memory.
Break things on purpose, then read the error message.

Throughout the book:

- Lines that start with `$` are commands you type. Do not type the `$`.
- Lines without `$` are the output you should expect.
- Boxes marked **Exercise** are for you; the answers are folded underneath.

```console
$ echo "hello, Ubuntu"
hello, Ubuntu
```

## Set up your lab

Every example uses a small set of sample files (the `lab/` folder in this
repository). You have three options.

### Option 1: Docker (recommended)

This gives everyone an identical Ubuntu 26.04 environment, and you cannot
damage your real system.

```bash
git clone https://github.com/jermsmit/ubuntu-bash-guide.git
cd ubuntu-bash-guide
make shell
```

You land in `~/lab` as a normal user called `learner`, with `sudo` available.

### Option 2: Your own Ubuntu 26.04 machine

Copy the `lab/` folder to your home directory and work inside it:

```bash
cp -r lab ~/lab
cd ~/lab
```

Install the extra tools used in the book:

```bash
sudo apt update
sudo apt install -y jq ripgrep fd-find tree shellcheck shfmt bats tmux
```

### Option 3: Windows with WSL

In PowerShell, install Ubuntu, then follow Option 2 inside the Ubuntu window:

```powershell
wsl --install -d Ubuntu
```

Which Ubuntu release WSL gives you depends on what is currently offered. Check
with `lsb_release -a` and see the [Ubuntu 26.04 notes](appendix-ubuntu-26-04.md)
if yours is older.

## A word about safety

Commands like `rm`, `mv`, `chmod` and `sudo` can destroy data. In this book you
work on copies of sample files. On a real system, get in the habit of reading
a command twice before pressing Enter.

## Contributing

Found a mistake, or output that differs on your machine? Please open an issue.
See `CONTRIBUTING.md` in the repository.
