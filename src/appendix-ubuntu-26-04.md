# Ubuntu 26.04 notes

This guide targets **Ubuntu 26.04 LTS (Resolute Raccoon)**, released in April
2026. Most of what you learn here is the same on any recent Ubuntu, but a few
changes matter to command-line users. Details below come from the release
coverage available at the time of writing; always confirm against Canonical's
official 26.04 release notes and your own system.

## What changed that affects the shell

### `sudo` is now sudo-rs

`sudo` is provided by **sudo-rs**, a memory-safe Rust implementation. For
normal use nothing changes, except that your password now shows asterisks as
you type it (press Tab to hide them). It is not 100% compatible with the
original: plugins are not supported, and unusual `sudoers` setups or niche
options should be tested before you rely on them. The original `sudo` is
available as a package in the repositories if you need it; search with
`apt search sudo` to find the exact name.

### Core utilities may be Rust implementations (uutils)

Many everyday commands (`ls`, `cp`, `mv`, `cat` and dozens more) now come
from **uutils coreutils**, a Rust reimplementation. It aims to be a drop-in
replacement for GNU coreutils, and for typical use it is. Differences, where
they exist, are usually in obscure options, exact wording of error messages,
and edge-case behavior. GNU coreutils remains available for compatibility.

Find out which implementation you have:

```bash
ls --version | head -n 1
sudo --version | head -n 1
dpkg -l | grep -E 'coreutils|sudo'
```

![Which implementations are installed](images/version-info.svg)

### Practical advice for scripts

- **Do not parse error messages.** Check exit codes instead. Message wording
  can differ between implementations and versions.
- **Prefer widely supported options.** Stick to flags documented in the POSIX
  standard or in both `--help` outputs.
- **Test where it will run.** If a script must work on both Ubuntu 24.04 (GNU)
  and 26.04 (possibly uutils), run your tests on both. The Docker lab in this
  repo makes that easy: change the base image in the `Dockerfile`.
- **If a command behaves differently**, compare `man`/`--help`, then check the
  project's issue tracker. Reporting differences helps everyone.

### systemd

Ubuntu 26.04 ships a newer systemd. Coverage notes that it is the last Ubuntu
release to keep System V init-script compatibility, so write new services as
systemd units rather than `/etc/init.d` scripts. See
[System and processes](05-system-and-processes.md) and
[Automation](11-automation.md).

### Desktop and terminal

- The GNOME desktop no longer offers an X11/Xorg session; Wayland is the only
  session. Clipboard helpers written for X11 (`xclip`, `xsel`) may not work
  everywhere; use `wl-copy` / `wl-paste` (package `wl-clipboard`) on Wayland.
- Terminal choices: the default GNOME Terminal still works as before. Newer
  terminals such as Ghostty are available as options.

### Upgrading

Direct in-place upgrades from Ubuntu 24.04 LTS were planned to open with the
26.04.1 point release. Back up first and read the release notes before you
upgrade a machine that matters.

## Keeping this guide honest

Everything marked as a runnable example is executed against an
`ubuntu:26.04` container in continuous integration, and screenshots are
generated from real output in that container. If something here does not match
what you see, please open an issue and include the output of:

```bash
lsb_release -a
bash --version | head -n 1
ls --version | head -n 1
```
