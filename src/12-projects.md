# Projects

Time to combine everything. Each project is a complete, working script that
uses ideas from earlier chapters. Type them in, run them against the lab files,
then extend them.

## Project 1: A log analyzer

**Goal:** summarize a web server log: total requests, the busiest clients, status
code breakdown and the most-requested paths.

Create `logsummary.sh` and run it against the sample log:

<!-- test -->
```bash
cat > logsummary.sh <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

usage() { echo "Usage: ${0##*/} LOGFILE [TOP_N]" >&2; exit 2; }

[[ $# -ge 1 ]] || usage
log=$1
top=${2:-3}

[[ -r $log ]] || { echo "error: cannot read '$log'" >&2; exit 1; }
[[ $top =~ ^[0-9]+$ ]] || { echo "error: TOP_N must be a number" >&2; exit 2; }

total=$(wc -l < "$log")
echo "== Summary of $log =="
echo "Total requests: $total"

echo
echo "== Top $top clients =="
awk '{ print $1 }' "$log" | sort | uniq -c | sort -rn | head -n "$top"

echo
echo "== Status codes =="
awk '{ print $9 }' "$log" | sort | uniq -c | sort -k2n

echo
echo "== Top $top paths =="
awk '{ print $7 }' "$log" | sort | uniq -c | sort -rn | head -n "$top"

echo
errors=$(awk '$9 >= 400' "$log" | wc -l)
pct=$(awk -v e="$errors" -v t="$total" 'BEGIN { printf "%.1f", (e / t) * 100 }')
echo "Error responses (4xx/5xx): $errors (${pct}%)"
SCRIPT
chmod +x logsummary.sh

./logsummary.sh data/access.log
./logsummary.sh data/access.log 5 > /dev/null
```

**Stretch goals:** accept `-s STATUS` to filter by status code; add a
per-hour request count by cutting the timestamp.

## Project 2: A safe backup script

**Goal:** make a timestamped, compressed archive of a directory; keep only the
newest N backups; support a dry run.

<!-- test -->
```bash
cat > backup.sh <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<USAGE >&2
Usage: ${0##*/} [-k KEEP] [-n] SOURCE_DIR DEST_DIR
  -k KEEP   number of backups to keep (default 3)
  -n        dry run: show what would happen
USAGE
    exit 2
}

keep=3 dry=0
while getopts ':k:nh' opt; do
    case $opt in
        k) keep=$OPTARG ;;
        n) dry=1 ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))
[[ $# -eq 2 ]] || usage
src=$1 dest=$2

[[ -d $src ]] || { echo "error: '$src' is not a directory" >&2; exit 1; }
[[ $keep =~ ^[1-9][0-9]*$ ]] || { echo "error: -k needs a positive number" >&2; exit 2; }

run() { if (( dry )); then echo "[dry-run] $*"; else "$@"; fi; }

stamp=$(date +%Y%m%d-%H%M%S)
name=$(basename "$src")
archive="$dest/${name}-${stamp}.tar.gz"

run mkdir -p "$dest"
run tar -czf "$archive" -C "$(dirname "$src")" "$name"
echo "created $archive"

# Retention: list newest first, skip the first $keep, delete the rest
mapfile -t old < <(ls -1t "$dest"/"${name}"-*.tar.gz 2>/dev/null | tail -n +$((keep + 1)) || true)
for f in "${old[@]}"; do
    echo "removing old backup $f"
    run rm -- "$f"
done
SCRIPT
chmod +x backup.sh

./backup.sh -n project backups        # rehearse first
./backup.sh project backups
sleep 1; ./backup.sh project backups
sleep 1; ./backup.sh -k 2 project backups
ls backups | wc -l                    # two backups remain
```

Study the ideas it uses: argument parsing with `getopts`, validation before
action, a `run` wrapper that makes `--dry-run` almost free, and a retention
policy that is safe because it only touches files matching its own naming
pattern.

**Stretch goals:** exclude `*.log` files with `tar --exclude`; verify the archive
with `tar -tzf`; send a notification on failure.

## Project 3: A system health report

**Goal:** print a one-page health summary suitable for a daily email or cron job.

<!-- test -->
```bash
#!/usr/bin/env bash
set -uo pipefail          # no -e: a failing check should not hide the others

section() { printf '\n== %s ==\n' "$1"; }

echo "Health report for $(hostname) at $(date '+%F %T')"

section "Uptime"
uptime

section "Disk usage (warn above 80%)"
df -h --output=target,pcent -x tmpfs -x devtmpfs 2>/dev/null | awk '
    NR == 1 { print; next }
    { gsub("%", "", $2); flag = ($2 + 0 > 80) ? "  <-- WARNING" : ""; print $1, $2 "%" flag }
'

section "Memory"
free -h | awk 'NR <= 2'

section "Top 5 processes by memory"
ps -eo pid,comm,%mem --sort=-%mem | head -n 6

section "Failed systemd units"
if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    systemctl --failed --no-legend || true
else
    echo "(systemd not available in this environment)"
fi
```

**Stretch goals:** add a check for pending `apt` upgrades; exit non-zero if any
warning fired so cron can alert you; email the report.

## Project 4: Bulk-rename files safely

**Goal:** rename `report-jan.txt`-style files to `2026-01-report.txt`, with a
preview before touching anything.

<!-- test -->
```bash
touch report-jan.txt report-feb.txt report-mar.txt
declare -A month=([jan]=01 [feb]=02 [mar]=03)

for f in report-*.txt; do
    m=${f#report-}; m=${m%.txt}
    [[ -n ${month[$m]:-} ]] || { echo "skip $f"; continue; }
    new="2026-${month[$m]}-report.txt"
    echo "$f -> $new"
    # change `echo` to `mv -n --` once the preview looks right
done
```

`mv -n` refuses to overwrite an existing file, which makes renames much safer.

## Real-world scripts to study

Seeing finished tools is the best next step. The author's own Ubuntu Server
projects are small, readable examples of shell scripting in practice:

- [ubuntu-auto-update](https://github.com/jermsmit/ubuntu-auto-update): an
  unattended weekly update script with logging (compare it with the
  [robust script](08-robust-scripts.md) habits and
  [cron/systemd timers](11-automation.md)).
- [slideshow-kiosk](https://github.com/jermsmit/slideshow-kiosk): an
  auto-starting photo slideshow kiosk set up with shell.

## Where to go next

- Read the Bash manual: `man bash` is long but authoritative; `help` covers
  builtins.
- Read other people's scripts: `/usr/bin` and `/etc/init.d` on Ubuntu are full
  of them.
- Practice small, real tasks: rename your photos, sort your downloads, parse a
  log you actually care about.
- Learn one scripting language beside Bash (Python is the usual choice) so you
  can pick the right tool for each job.
