# Automation

Scripts become truly useful when they run without you: on a schedule, in
parallel, or in response to something. This chapter covers the practical tools.

## Running things in parallel

The simplest parallelism is background jobs plus `wait`:

<!-- test -->
```bash
slow_task() { sleep 1; echo "task $1 done"; }

for i in 1 2 3; do
    slow_task "$i" &        # & starts each in the background
done
wait                        # block until all background jobs finish
echo "all tasks finished"
```

All three tasks finish in about one second, not three. (Note: these are
separate *processes*, not threads.)

To run at most N at a time over many inputs, `xargs -P` is the easiest tool:

<!-- test -->
```bash
printf '%s\n' a b c d e f | xargs -P 3 -I{} sh -c 'sleep 0.2; echo "processed {}"' | sort
```

`-P 3` means "three at once". For heavier needs, GNU `parallel`
(`sudo apt install parallel`) adds progress bars, retries and remote execution.

Capture each job's exit status when it matters:

<!-- test -->
```bash
pids=()
for n in 0 1 0; do
    ( exit "$n" ) &
    pids+=($!)
done
failed=0
for pid in "${pids[@]}"; do
    wait "$pid" || failed=$((failed + 1))
done
echo "$failed job(s) failed"
```

## Repeating a command: `watch`

```bash
watch -n 2 'df -h /'          # rerun every 2 seconds
watch -d 'ls -l /var/log'     # highlight what changed
```

## Scheduling with cron

`cron` runs commands on a schedule. Edit your personal schedule with:

```bash
crontab -e        # edit
crontab -l        # list
```

Each line has five time fields, then the command:

```text
┌──────── minute (0-59)
│ ┌────── hour (0-23)
│ │ ┌──── day of month (1-31)
│ │ │ ┌── month (1-12)
│ │ │ │ ┌ day of week (0-7, Sunday is 0 or 7)
│ │ │ │ │
* * * * *  command
```

Examples:

```text
*/15 * * * *   /home/learner/bin/check-disk.sh            # every 15 minutes
0 2 * * *      /home/learner/bin/backup.sh                # daily at 02:00
30 6 * * 1-5   /home/learner/bin/report.sh                # weekdays at 06:30
@reboot        /home/learner/bin/on-boot.sh               # at startup
```

### Why cron jobs "work in my terminal but not in cron"

Cron runs with a tiny environment: a minimal `PATH`, no aliases and none of
your `.bashrc`. The fixes:

- Use **absolute paths** for the script and for programs it calls, or set
  `PATH=...` at the top of the crontab.
- Set `SHELL=/bin/bash` at the top of the crontab if you use Bash features.
- **Capture output** so you can see errors:

```text
0 2 * * * /home/learner/bin/backup.sh >> /home/learner/backup.log 2>&1
```

- Test the script by running it with a clean environment first:
  `env -i /home/learner/bin/backup.sh`.

## Scheduling with systemd timers

On modern Ubuntu, **systemd timers** are the more capable alternative to cron:
they log to the journal, can run missed jobs after downtime, and are easy to
inspect.

Create a service, `~/.config/systemd/user/backup.service`:

```ini
[Unit]
Description=Back up my project

[Service]
Type=oneshot
ExecStart=%h/.local/bin/backup.sh
```

and its timer, `~/.config/systemd/user/backup.timer`:

```ini
[Unit]
Description=Run the backup every night

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

Enable and inspect it (these are *user* units, so no `sudo`):

```bash
systemctl --user daemon-reload
systemctl --user enable --now backup.timer
systemctl --user list-timers
journalctl --user -u backup.service
systemd-analyze calendar "*-*-* 02:00:00"    # check your schedule expression
```

`Persistent=true` means that if the machine was off at 02:00, the job runs as
soon as it comes back.

## One-off scheduling with `at`

```bash
sudo apt install at
echo "/home/learner/bin/report.sh" | at 17:30
atq                       # list queued jobs
atrm 3                    # remove job number 3
```

## Reacting to changes

For simple polling, a loop is enough:

```bash
while true; do
    if [[ -f /tmp/trigger ]]; then
        echo "trigger found"
        rm /tmp/trigger
    fi
    sleep 5
done
```

To react immediately to file changes, use `inotifywait`
(`sudo apt install inotify-tools`):

```bash
inotifywait -m -e create,modify ~/incoming |
while read -r dir event file; do
    echo "$event: $file"
done
```

## Notifications

A script that fails silently at 2 a.m. is not much use. Send yourself a note,
whichever way suits you:

```bash
notify-send "Backup finished"                                # desktop popup
curl -fsS -d "Backup finished" https://ntfy.sh/your-secret-topic   # phone push via ntfy
mail -s "Backup failed" you@example.com <<< "see the log"   # needs a mail setup
```

## Exercises

1. Write a crontab line that runs `/home/learner/bin/report.sh` every Monday
   at 07:45 and appends all output to `report.log`.
2. Process the numbers 1 to 10 with `xargs -P 4`, printing each squared (hint:
   `sh -c 'echo $(( $1 * $1 ))' _ {}`).
3. Why might a script behave differently when run from cron?

<details>
<summary>Answers</summary>

1. `45 7 * * 1 /home/learner/bin/report.sh >> /home/learner/report.log 2>&1`
2. `seq 1 10 | xargs -P 4 -I{} sh -c 'echo $(( $1 * $1 ))' _ {}`
3. Cron's environment is minimal: different `PATH`, no aliases, no profile,
   and a different working directory.

</details>
