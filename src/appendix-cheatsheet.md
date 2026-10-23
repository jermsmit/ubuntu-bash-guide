# Cheat sheet

## Navigation and files

| Task | Command |
| --- | --- |
| Where am I? | `pwd` |
| List (long, all, human) | `ls -lah` |
| Change directory | `cd dir`, `cd ..`, `cd ~`, `cd -` |
| Make directories | `mkdir -p a/b/c` |
| Copy / move / remove | `cp -r src dst` / `mv src dst` / `rm -r dir` |
| Create empty file | `touch file` |
| Find by name | `find . -name '*.txt'` |
| View file | `cat`, `less`, `head -n 5`, `tail -n 5`, `tail -f` |
| Permissions | `chmod 644 file`, `chmod u+x file`, `chown u:g file` |
| Archive | `tar -czf out.tar.gz dir`, `tar -xzf out.tar.gz` |
| Link | `ln -s target linkname` |

## Text

| Task | Command |
| --- | --- |
| Search text | `grep -rn 'text' dir`, `rg 'text'` |
| Columns | `cut -d, -f1,3 file`, `awk -F, '{print $1}' file` |
| Replace | `sed 's/old/new/g' file` |
| Sort / unique / count | `sort file \| uniq -c \| sort -rn` |
| Count lines / words | `wc -l file`, `wc -w file` |
| Translate chars | `tr 'a-z' 'A-Z'` |
| JSON | `jq '.field' file.json` |

## Streams

| Syntax | Meaning |
| --- | --- |
| `> f` / `>> f` | stdout to file (overwrite / append) |
| `2> f` | stderr to file |
| `&> f` | both to file |
| `2>&1` | stderr to wherever stdout goes |
| `< f` | stdin from file |
| `a \| b` | stdout of `a` into stdin of `b` |
| `<<'EOF'` | here-document |
| `<( cmd )` | output of `cmd` as a file |
| `a && b` / `a \|\| b` | run `b` if `a` succeeds / fails |

## System

| Task | Command |
| --- | --- |
| Disk / dir size | `df -h`, `du -sh dir` |
| Memory | `free -h` |
| Processes | `ps aux`, `pgrep name`, `top`, `htop` |
| Stop a process | `kill PID`, `kill -9 PID`, `pkill name` |
| Services | `systemctl status\|start\|stop\|restart\|enable name` |
| Logs | `journalctl -u name -f` |
| Packages | `sudo apt update`, `apt install`, `apt remove`, `apt search` |
| Who / OS / kernel | `whoami`, `lsb_release -a`, `uname -r` |

## Network

| Task | Command |
| --- | --- |
| Download | `curl -fsSLO URL`, `wget URL` |
| Reachability | `ping -c 4 host` |
| Addresses / routes | `ip -br addr`, `ip route` |
| Listening ports | `ss -tulpn` |
| DNS | `dig +short host` |
| Remote shell / copy | `ssh user@host`, `scp f host:dir/`, `rsync -avh src/ host:dst/` |

## Scripting

```bash
#!/usr/bin/env bash
set -euo pipefail

var="value"                 # no spaces around =
echo "${var:-default}"      # default value
arr=(a b c); echo "${arr[@]}"
declare -A map; map[k]=v

if [[ -f $file && $n -gt 3 ]]; then ...; elif ...; else ...; fi
for x in "$@"; do ...; done
while IFS= read -r line; do ...; done < file
case "$x" in a|b) ... ;; *) ... ;; esac

f() { local x=$1; echo "$x"; }      # function
result=$(f arg)                     # capture output
trap 'rm -rf "$tmp"' EXIT           # cleanup
```

| Parameter expansion | Result |
| --- | --- |
| `${v:-d}` | default if unset/empty |
| `${v#p}` `${v##p}` | strip shortest/longest prefix |
| `${v%p}` `${v%%p}` | strip shortest/longest suffix |
| `${v/a/b}` `${v//a/b}` | replace first / all |
| `${v^^}` `${v,,}` | upper / lower case |
| `${#v}` | length |

## Shortcuts

| Keys | Action |
| --- | --- |
| Tab | Complete |
| Ctrl+R | Search history |
| Ctrl+A / E | Start / end of line |
| Ctrl+W / U | Delete word / to start |
| Ctrl+C / Z / D | Interrupt / suspend / end input |
| `!!` / `sudo !!` | Repeat last / repeat with sudo |
| Alt+. | Last argument of previous command |
