# Redirection and pipes

Every program starts with three connections, called **streams**:

| Name | Number | Default | Purpose |
| --- | --- | --- | --- |
| stdin | 0 | Keyboard | Input |
| stdout | 1 | Screen | Normal output |
| stderr | 2 | Screen | Error messages |

Redirection and pipes rewire these streams. This is the idea that makes the
shell more than a way to launch programs.

## Redirecting output

<!-- test -->
```bash
echo "first" > out.txt        # > overwrites the file
echo "second" >> out.txt      # >> appends
cat out.txt
ls data > listing.txt         # capture a command's output
wc -l listing.txt
```

> `>` silently destroys whatever was in the file. In an interactive session,
> `set -o noclobber` makes Bash refuse to overwrite existing files (use `>|` to
> force it).

## Redirecting errors

Errors go to stderr, so a plain `>` does not capture them:

<!-- test -->
```bash
ls data nope > good.txt 2> bad.txt   # stdout to one file, stderr to another
cat good.txt
cat bad.txt
ls data nope > all.txt 2>&1          # both into one file (order matters!)
ls data nope &> all2.txt             # Bash shorthand for the same
ls nope 2>/dev/null || true         # discard errors (|| true: keep going)
```

(These `ls` commands exit non-zero on purpose. In a script that uses
`set -e` you would need to handle that; see [Robust scripts](08-robust-scripts.md).)

`/dev/null` is a black hole: anything written to it vanishes. Remember the
order rule: `> file 2>&1` means "send stdout to the file, *then* point stderr
to where stdout now goes". Reversing it (`2>&1 > file`) does something
different.

## Redirecting input

<!-- test -->
```bash
wc -l < data/people.csv               # file becomes stdin
sort <<'EOF'
pear
apple
mango
EOF
grep -c apple <<< "apple pie and apple tart"   # here-string
```

The `<<'EOF'` form is a **here-document**: everything up to the closing `EOF`
line is fed to the command. Quoting the marker (`'EOF'`) prevents variable
expansion inside, which is almost always what you want when writing files.

## Pipes

A pipe `|` connects one command's stdout to the next command's stdin. The
programs run at the same time, passing data along as it is produced.

<!-- test -->
```bash
cat data/access.log | wc -l
awk '{ print $1 }' data/access.log | sort | uniq -c | sort -rn | head -n 3
```

![Top client IPs using a pipeline](images/pipeline-top-ips.svg)

Read a pipeline left to right as a story: take the log, keep the first column
(client address), sort it, count repeats, put the biggest first, show the top
three. Build pipelines one stage at a time, checking the output after each `|`.

To send stderr down the pipe too, use `|&`:

```bash
make |& tee build.log
```

## `tee`: save and show

`tee` copies stdin to both the screen and a file, so you can watch a long
command and also keep its output:

<!-- test -->
```bash
ls data | tee listing.txt | wc -l
cat listing.txt
echo "line" | tee -a listing.txt       # -a appends
```

Needing `sudo` to write a file? `sudo echo x > /etc/file` fails, because the
redirect is done by *your* shell, not by sudo. Use `tee` instead:

```bash
echo "setting=1" | sudo tee /etc/example.conf
```

## Command substitution and process substitution

`$( ... )` runs a command and substitutes its output:

<!-- test -->
```bash
count=$(wc -l < data/people.csv)
echo "people.csv has $count lines"
echo "Today is $(date +%F)"
```

**Process substitution** `<( ... )` makes a command's output look like a file,
which is handy for commands that expect file names:

<!-- test -->
```bash
diff <(sort data/fruits.txt) <(sort -r data/fruits.txt) | head -n 5
comm -12 <(cut -d, -f2 data/people.csv | sort -u) <(printf 'Austin\nParis\nTokyo\n' | sort)
```

## Combining commands: `;`, `&&`, `||`

| Syntax | Meaning |
| --- | --- |
| `a ; b` | Run `a`, then `b`, regardless |
| `a && b` | Run `b` only if `a` succeeded |
| `a \|\| b` | Run `b` only if `a` failed |
| `a & b` | Run `a` in the background, start `b` immediately |

<!-- test -->
```bash
mkdir -p build && echo "created build/"
grep -q banana data/fruits.txt && echo "banana found"
grep -q kiwi data/fruits.txt || echo "no kiwi"
[ -d build ] && echo yes || echo no
```

## `xargs`: turn lines into arguments

Many commands take arguments, not stdin. `xargs` bridges the gap:

<!-- test -->
```bash
find data -name '*.txt' | xargs wc -l
find . -name '*.log' -print0 | xargs -0 ls -l   # safe for names with spaces
printf '1\n2\n3\n' | xargs -I{} echo "item {}"
```

Use `-print0` with `xargs -0` whenever file names might contain spaces or
newlines. This is the safe default.

## Exercises

1. Write the first three lines of `fruits.txt` to a file called `top3.txt`.
2. Run `ls data missing-dir` so that normal output goes to `ok.txt` and the
   error goes to `err.txt`.
3. Find how many distinct HTTP status codes appear in `access.log`.
4. Using a here-document, create a file `hello.sh` containing a two-line script.

<details>
<summary>Answers</summary>

1. `head -n 3 data/fruits.txt > top3.txt`
2. `ls data missing-dir > ok.txt 2> err.txt`
3. `awk '{ print $9 }' data/access.log | sort -u | wc -l`
4. Like this:

   ```bash
   cat > hello.sh <<'EOF'
   #!/usr/bin/env bash
   echo "hello"
   EOF
   ```

</details>
