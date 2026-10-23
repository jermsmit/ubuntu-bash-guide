# System and processes

This chapter covers inspecting a running Ubuntu system: who you are, what is
running, how much disk and memory is used, and how to manage services and
packages.

## Who and where am I?

<!-- test -->
```bash
whoami              # your username
id                  # user id, group id and group memberships
hostname            # machine name
uname -srm          # kernel name, release and architecture
date                # current date and time
uptime              # how long the system has been up, and load
```

For the release you are running:

```bash
lsb_release -a
cat /etc/os-release
```

## Disk and memory

<!-- test -->
```bash
df -h /             # free space on the filesystem holding /
du -sh data         # total size of a directory
du -h --max-depth=1 project | sort -h   # size of each subdirectory, smallest first
free -h             # memory and swap
```

`df` reports **filesystems** (how full is the disk?). `du` reports
**directories** (what is using the space?). Use `df` to notice a problem and
`du` to find the cause.

To see block devices and mount points: `lsblk`.

## Processes

A **process** is a running program. Each has a numeric **PID**.

<!-- test -->
```bash
ps                          # processes in this terminal
ps -o pid,ppid,comm -p $$   # this shell: its PID, parent PID and name
ps -eo pid,comm,%mem --sort=-%mem | head -n 5   # top memory users
pgrep -l bash | head -n 3   # find processes by name
```

`ps aux` and `ps -ef` list every process on the system. Pipe them to `grep`
to find one, or use `pgrep`, which is cleaner.

For a live view, use `top`, or the friendlier `htop`
(`sudo apt install htop`). In `htop`: **F6** sorts, **F9** kills, **F10** or
**q** quits.

### Stopping processes

`kill` sends a **signal**. The default, `SIGTERM` (15), politely asks a program
to exit. `SIGKILL` (9) ends it instantly with no chance to clean up, so use it
only when the polite request failed.

<!-- test -->
```bash
sleep 300 &            # start something in the background
pid=$!                 # $! is the PID of the last background job
echo "started $pid"
kill "$pid"            # ask it to stop
wait "$pid" 2>/dev/null || echo "process ended"
```

```bash
kill -9 1234           # force kill PID 1234 (last resort)
pkill firefox          # signal by name
killall sleep          # signal every process with that exact name
```

### Jobs: background and foreground

| Action | How |
| --- | --- |
| Run in background | `command &` |
| Suspend the current program | **Ctrl+Z** |
| Resume it in background | `bg` |
| Bring it to foreground | `fg` |
| List jobs | `jobs` |
| Keep running after you log out | `nohup command &` (or use `tmux`) |

For anything long-running over SSH, use `tmux`: sessions survive disconnects
and you can reattach later. See [Productivity](10-productivity.md).

## Services with systemd

Ubuntu uses **systemd** to run background services (web servers, databases,
SSH). Its control tool is `systemctl`.

```bash
systemctl status ssh              # is it running? recent log lines
sudo systemctl start ssh          # start now
sudo systemctl stop ssh
sudo systemctl restart ssh
sudo systemctl enable ssh         # start at boot
sudo systemctl enable --now ssh   # enable and start in one step
systemctl list-units --type=service --state=running
systemctl --failed                # anything broken?
```

> Ubuntu 26.04 is reported to be the last release that supports legacy System V
> init-script compatibility, so write new services as systemd units, not
> `/etc/init.d` scripts. See the [Ubuntu 26.04 notes](appendix-ubuntu-26-04.md).

### Reading logs with `journalctl`

systemd collects logs from services and the kernel in one place:

```bash
journalctl -u ssh                 # logs for one service
journalctl -u ssh -f              # follow live (Ctrl+C to stop)
journalctl -b                     # everything since this boot
journalctl --since "1 hour ago"
journalctl -p err -b              # only errors and worse, this boot
```

## Packages with `apt`

```bash
sudo apt update                   # refresh the package list
apt list --upgradable             # what can be upgraded?
sudo apt upgrade                  # install upgrades
sudo apt install jq tree          # install packages
sudo apt remove tree              # remove (keep config)
sudo apt purge tree               # remove including config
sudo apt autoremove               # remove unneeded dependencies
apt search json                   # search packages
apt show jq                       # details about a package
dpkg -l | grep jq                 # is it installed?
dpkg -L jq                        # which files did it install?
```

Always `apt update` before installing, or you may get stale versions.
Ubuntu also offers **snap** packages (`snap list`, `sudo snap install ...`),
which bundle their own dependencies.

## Users and groups

```bash
getent passwd learner             # look up a user
groups                            # groups you belong to
sudo adduser alice                # create a user interactively
sudo usermod -aG sudo alice       # add to the sudo group (-a = append!)
sudo passwd alice                 # set a password
```

Always include `-a` with `-G`. Without it, `usermod -G` *replaces* all of the
user's groups.

## Exercises

1. Show the five largest subdirectories under `project`.
2. Start `sleep 120` in the background, then find its PID with `pgrep` and
   stop it.
3. Show only filesystems with more than 50% usage (hint: `df` plus `awk`).
4. Find out which kernel version you are running.

<details>
<summary>Answers</summary>

1. `du -h --max-depth=1 project | sort -rh | head -n 5`
2. `sleep 120 & pgrep -n sleep` then `pkill -n sleep` (or `kill $!`).
3. `df -h | awk 'NR==1 || $5+0 > 50'`
4. `uname -r`

</details>
