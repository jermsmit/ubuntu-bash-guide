# Files and directories

Linux organizes everything as one tree starting at `/` (the **root**
directory). There are no drive letters. Your own files live under your **home
directory**, written `~` (for example `/home/learner`).

All examples in this chapter assume you are in the lab directory. Run `pwd` to
check, then look around:

<!-- test -->
```bash
pwd
ls
ls data
```

## Navigating

| Command | What it does |
| --- | --- |
| `pwd` | Print the current directory |
| `cd dir` | Change into `dir` |
| `cd ..` | Go up one level |
| `cd` or `cd ~` | Go home |
| `cd -` | Go back to the previous directory |

**Paths** are absolute if they start with `/` (`/etc/hostname`) and relative
otherwise (`data/people.csv`). `.` means "here" and `..` means "one level up".

## Listing: `ls`

<!-- test -->
```bash
ls -l data          # long format: permissions, owner, size, date
ls -la project      # include hidden files (names starting with a dot)
ls -lh data         # human-readable sizes
ls -lt data         # newest first
ls -R project       # recurse into subdirectories
```

![Long listing of the data directory](images/ls-long.svg)

Reading a long listing:

```console
-rw-r--r-- 1 learner learner 301 Oct 12 09:14 access.log
│└┬┘└┬┘└┬┘   │       │       │    └── modified   └── name
│ │  │  │    │       │       └─────── size in bytes
│ │  │  │    │       └─────────────── group
│ │  │  │    └─────────────────────── owner
│ │  │  └──────────────────────────── permissions for everyone else
│ │  └─────────────────────────────── permissions for the group
│ └────────────────────────────────── permissions for the owner
└──────────────────────────────────── type: - file, d directory, l symlink
```

For a visual overview of a directory tree, install `tree` and run `tree project`.

![tree output of the sample project](images/tree-project.svg)

## Creating, copying, moving, deleting

<!-- test -->
```bash
mkdir -p work/reports/2026      # -p creates parent directories as needed
touch work/notes.txt            # create an empty file (or update its timestamp)
cp data/notes.txt work/         # copy a file
cp -r project work/project-copy # copy a directory (-r = recursive)
mv work/notes.txt work/ideas.txt  # rename (move within the same place)
mv work/ideas.txt work/reports/   # move into a directory
ls -R work
rm work/reports/ideas.txt       # delete a file
rmdir work/reports/2026         # delete an EMPTY directory
rm -r work/project-copy         # delete a directory and everything in it
```

> **There is no recycle bin.** `rm` deletes immediately and permanently.
> Habits that help: use `rm -i` when unsure, use `ls` with the same pattern
> first to see what you are about to delete, and never run `rm -rf` with a
> variable you have not checked.

## Globbing: wildcards the shell expands

Before a command runs, the shell replaces patterns with matching file names.
The command itself never sees the `*`.

| Pattern | Matches |
| --- | --- |
| `*` | Any characters (including none) |
| `?` | Exactly one character |
| `[abc]` | One of `a`, `b`, `c` |
| `[0-9]` | One digit |
| `{a,b,c}` | Brace expansion: becomes `a b c` |

<!-- test -->
```bash
ls data/*.txt
ls data/*.{csv,log}
echo file{1..3}.txt
touch report-{jan,feb,mar}.txt
ls report-*.txt
```

## Finding files: `find`

`find` walks a directory tree and tests every file.

<!-- test -->
```bash
find . -name '*.txt'                 # by name (quote the pattern!)
find . -type d                       # directories only
find . -type f -size -1k             # files smaller than 1 KiB
find . -name '*.log' -mtime -1       # modified in the last day
find project -name '*.py' -exec wc -l {} +   # run a command on matches
```

![Using find to locate text files](images/find-txt.svg)

If you have `fd` installed (the Ubuntu package is `fd-find`, and the command is
`fdfind`), it offers shorter syntax and sensible defaults. For searching
*inside* files, see `grep` and `rg` in the [next chapter](03-text-processing.md).

## Viewing files

<!-- test -->
```bash
cat data/notes.txt          # print the whole file
head -n 2 data/notes.txt    # first 2 lines
tail -n 2 data/notes.txt    # last 2 lines
wc -l data/notes.txt        # count lines
file data/notes.txt         # what kind of file is it?
```

For long files use `less file`: **Space** to page, `/word` to search, `q` to
quit. To watch a growing log live: `tail -f /var/log/syslog` (Ctrl+C to stop).

## Permissions

Each file has three sets of permissions (owner, group, others), each made of
**r**ead, **w**rite and e**x**ecute.

| Letter | On a file | On a directory |
| --- | --- | --- |
| `r` | Read contents | List names |
| `w` | Change contents | Create/delete files inside |
| `x` | Run as a program | Enter (`cd`) and access items |

You change them with `chmod`, in symbolic or numeric form:

<!-- test -->
```bash
touch run.sh
chmod u+x run.sh        # give the owner execute permission
chmod go-w run.sh       # remove write from group and others
chmod 640 run.sh        # numeric: r=4 w=2 x=1 -> owner 6 (rw), group 4 (r), others 0
ls -l run.sh
```

![chmod changing permissions](images/chmod-demo.svg)

Common numeric modes: `644` (normal file), `755` (program or directory),
`600` (private file such as an SSH key), `700` (private directory).

`chown user:group file` changes ownership and normally needs `sudo`:

```bash
sudo chown learner:learner some-file
```

### A note on `sudo`

`sudo` runs one command with administrator rights. On Ubuntu 26.04 it is
provided by **sudo-rs**, and it shows asterisks as you type your password.
Day to day it behaves the same. Use it sparingly: only for the specific
command that needs it, never for whole sessions.

## Links

A **symbolic link** is a pointer to another path, like a shortcut:

<!-- test -->
```bash
ln -s data/people.csv people-link.csv
ls -l people-link.csv
cat people-link.csv | head -2
readlink people-link.csv
```

## Compressing and archiving

`tar` bundles many files into one archive; `gzip` (or the `z` flag) compresses.

<!-- test -->
```bash
tar -czf project.tar.gz project      # c=create z=gzip f=file
tar -tzf project.tar.gz              # t=list contents
mkdir restored
tar -xzf project.tar.gz -C restored  # x=extract, -C = into this directory
ls restored/project
gzip -k data/access.log              # compress, keep original (-k)
zcat data/access.log.gz | head -n 2  # read compressed text without unpacking
unzip -v >/dev/null 2>&1 || echo "unzip is optional"
```

## Exercises

1. Create `practice/a/b/c` in one command, then remove the whole `practice`
   tree.
2. List only the `.csv` and `.log` files in `data`, newest first.
3. Find all files under `project` whose name ends in `.txt` or `.md`.
4. Make a file readable and writable by you, readable by your group, and
   invisible to everyone else. What is its numeric mode?

<details>
<summary>Answers</summary>

1. `mkdir -p practice/a/b/c && rm -r practice`
2. `ls -t data/*.csv data/*.log`
3. `find project -name '*.txt' -o -name '*.md'`
4. `chmod 640 file`. Owner rw (6), group r (4), others none (0).

</details>
