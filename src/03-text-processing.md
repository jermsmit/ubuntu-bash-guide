# Text processing

On Linux almost everything is text: logs, configuration, command output. A
small set of tools, each doing one job, lets you slice that text any way you
like. This chapter introduces the essential ones. They become powerful once you
combine them with pipes in the [next chapter](04-redirection-and-pipes.md).

Sample files used here (all in `data/`): `fruits.txt`, `people.csv`,
`notes.txt` and `access.log`.

## Searching: `grep`

`grep` prints lines that match a pattern.

<!-- test -->
```bash
grep apple data/fruits.txt            # lines containing "apple"
grep -i QUOTE data/notes.txt          # ignore case
grep -n ' 404 ' data/access.log       # show line numbers
grep -c apple data/fruits.txt         # count matching lines
grep -v apple data/fruits.txt         # invert: lines that do NOT match
grep -E '(404|500)' data/access.log   # extended regex: alternatives
grep -o '[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}' data/access.log | head -n 3  # only the match
grep -r 'TODO' project                # search a directory recursively
```

![grep showing 404 lines with line numbers](images/grep-errors.svg)

| Option | Meaning |
| --- | --- |
| `-i` | Ignore case |
| `-v` | Invert the match |
| `-n` | Show line numbers |
| `-c` | Count matching lines |
| `-r` | Recurse into directories |
| `-l` | List only names of files with matches |
| `-E` | Extended regular expressions |
| `-F` | Treat the pattern as a fixed string, not a regex |
| `-w` | Match whole words only |
| `-A n` / `-B n` / `-C n` | Show n lines after / before / around each match |

> `egrep` and `fgrep` are old spellings of `grep -E` and `grep -F`. They still
> work but are deprecated, so use the options.

**ripgrep** (`rg`) is a faster, friendlier alternative for searching code. It
recurses by default, respects `.gitignore` and highlights matches:

```bash
rg 'TODO' project
```

## Selecting columns: `cut`

`cut` pulls fields from delimited text.

<!-- test -->
```bash
cut -d, -f1,4 data/people.csv    # fields 1 and 4, comma-delimited
cut -d: -f1,7 data/passwd-sample # username and shell
cut -c1-5 data/notes.txt         # first five characters of each line
```

![cut selecting two CSV columns](images/cut-fields.svg)

`cut` is simple and fast, but it cannot handle quoted CSV fields that contain
commas. For real CSV use a proper tool (Python's `csv`, or `csvkit`).

## Sorting and counting: `sort`, `uniq`, `wc`

<!-- test -->
```bash
sort data/fruits.txt                  # alphabetical
sort -r data/fruits.txt               # reverse
sort -u data/fruits.txt               # sort and drop duplicates
sort -t, -k3 -n data/people.csv       # numeric sort on 3rd comma-separated field
sort data/fruits.txt | uniq -c        # count occurrences (input must be sorted)
sort data/fruits.txt | uniq -c | sort -rn   # most common first
wc -l data/*.txt data/*.csv           # lines per file (and a total)
```

![Counting duplicates with sort and uniq](images/sort-uniq.svg)

`uniq` only collapses *adjacent* duplicates, which is why you nearly always
`sort` first. The `sort | uniq -c | sort -rn` pattern is one of the most-used
idioms in shell work.

## Translating characters: `tr`

`tr` swaps or deletes single characters. It reads standard input only.

<!-- test -->
```bash
echo "Hello World" | tr 'a-z' 'A-Z'        # uppercase
echo "a,b,c" | tr ',' '\n'                 # commas to newlines
echo "too    many   spaces" | tr -s ' '    # squeeze repeats
echo "phone: 555-1234" | tr -d '0-9'       # delete digits
```

## Editing streams: `sed`

`sed` applies edits to each line as text flows past. The command you will use
90% of the time is substitute: `s/old/new/`.

<!-- test -->
```bash
sed 's/apple/APPLE/' data/fruits.txt            # first match per line
sed 's/a/A/g' data/fruits.txt | head -n 3       # every match (g = global)
sed -n '2,4p' data/notes.txt                    # print only lines 2-4
sed '/^$/d' data/notes.txt                      # delete empty lines
sed 's/[0-9]\+/N/g' data/access.log | head -n 2 # regex: runs of digits
cp data/notes.txt edit-me.txt
sed -i 's/Quote/QUOTE/' edit-me.txt             # -i edits the file in place
grep QUOTE edit-me.txt
```

> `sed -i` overwrites the file with no undo. Keep a copy while experimenting:
> `sed -i.bak 's/a/b/' file` saves the original as `file.bak`.

## Programming on a line: `awk`

`awk` splits each line into fields (`$1`, `$2`, ...; `$0` is the whole line) and
runs small programs against them. Think of it as `cut` with a calculator.

<!-- test -->
```bash
awk -F, 'NR>1 { print $1, $2 }' data/people.csv      # skip header, print 2 columns
awk -F, 'NR>1 && $3 > 35' data/people.csv            # filter rows by a number
awk -F, 'NR>1 { sum += $3 } END { print "average age:", sum/(NR-1) }' data/people.csv
awk '{ bytes += $NF } END { print bytes " bytes served" }' data/access.log
awk '$9 == 404 { print $7 }' data/access.log         # field 9 is the status code
awk -F, 'NR>1 { count[$2]++ } END { for (c in count) print c, count[c] }' data/people.csv | sort
```

![awk printing selected columns](images/awk-columns.svg)

Key ideas: `NR` is the current line number, `NF` the number of fields, `$NF`
the last field, and `END { ... }` runs after the last line. Patterns before the
braces decide which lines the action applies to.

## JSON: `jq`

Modern tools speak JSON, and `jq` is its command-line workhorse. Install with
`sudo apt install jq`.

```bash
echo '{"name":"Ubuntu","version":"26.04","tags":["lts","linux"]}' | jq .
echo '{"name":"Ubuntu","version":"26.04","tags":["lts","linux"]}' | jq -r '.tags[]'
```

![jq pretty-printing JSON](images/jq-demo.svg)

Common filters: `.field`, `.a.b`, `.[]` (every array element),
`select(.x > 3)`, `map(.name)`, and `-r` to print raw strings without quotes.

## Choosing the right tool

| Job | Tool |
| --- | --- |
| Find lines containing something | `grep` / `rg` |
| Take columns by position | `cut` |
| Replace text | `sed` |
| Compute on columns, group, sum | `awk` |
| Sort, dedupe, count | `sort`, `uniq`, `wc` |
| Change or delete characters | `tr` |
| Structured JSON | `jq` |

If a task needs a data structure or real parsing, switch to Python instead.
Knowing when to stop using shell is a skill too.

## Exercises

1. How many lines in `access.log` contain a 200 status?
2. Print only the usernames in `passwd-sample` whose shell is `/bin/bash`.
3. Replace every `Austin` in `people.csv` with `Dallas`, writing the result to
   a new file without touching the original.
4. Which city appears most often in `people.csv`?

<details>
<summary>Answers</summary>

1. `grep -c ' 200 ' data/access.log`
2. `awk -F: '$7 == "/bin/bash" { print $1 }' data/passwd-sample`
3. `sed 's/Austin/Dallas/' data/people.csv > people-dallas.csv`
4. `cut -d, -f2 data/people.csv | tail -n +2 | sort | uniq -c | sort -rn | head -n 1`

</details>
