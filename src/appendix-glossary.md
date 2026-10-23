# Glossary

**Alias**: A short name Bash expands into a longer command.

**Argument**: A value passed to a command, such as a file name.

**Bash**: The Bourne-Again Shell, Ubuntu's default interactive shell.

**Builtin**: A command implemented inside the shell itself (`cd`, `echo`).

**Command substitution**: Using `$( ... )` to insert a command's output.

**Environment variable**: A named value passed from a shell to the programs it
starts (exported variables).

**Exit code (status)**: The number a command returns when it finishes; `0`
means success.

**Glob**: A wildcard pattern like `*.txt` that the shell expands to file names.

**Here-document**: Multi-line input fed to a command with `<<EOF ... EOF`.

**Home directory**: Your personal directory, written `~`.

**PATH**: The list of directories searched for programs.

**PID**: Process ID, the number identifying a running process.

**Pipe**: The `|` operator that connects one command's output to another's
input.

**POSIX**: A standard describing the portable core of Unix shells and tools.

**Process**: A running instance of a program.

**Prompt**: The text the shell shows when it is ready for input (`PS1`).

**Root**: The administrator account, and also the top directory `/`.

**Shebang**: The `#!` first line of a script naming its interpreter.

**Shell**: A program that reads commands and runs them.

**Signal**: A message sent to a process (`SIGTERM`, `SIGKILL`, `SIGINT`).

**stderr / stdin / stdout**: The standard error, input and output streams.

**Subshell**: A child copy of the shell, created by `( ... )`, pipelines and
command substitution. Variable changes inside it do not escape.

**sudo**: Runs a command with administrator rights. On Ubuntu 26.04 this is
sudo-rs.

**systemd**: Ubuntu's service manager (`systemctl`, `journalctl`).

**Terminal**: The window that displays the shell.

**uutils**: A Rust reimplementation of the core GNU utilities, used by Ubuntu
26.04.
