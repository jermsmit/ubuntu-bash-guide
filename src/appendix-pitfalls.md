# Common pitfalls

A field guide to mistakes almost everyone makes. Each has a quick fix.

## 1. Unquoted variables

```bash
rm -rf $dir/*          # dangerous: empty $dir becomes "rm -rf /*"
rm -rf "${dir:?}"/*    # safe: aborts if dir is empty or unset
```

## 2. Spaces around `=`

```bash
name = "Ada"     # error: runs a command called "name"
name="Ada"       # correct
```

## 3. Parsing `ls`

```bash
for f in $(ls *.txt); do ...; done     # breaks on spaces and odd characters
for f in *.txt; do ...; done           # correct
```

## 4. `cd` that might fail

```bash
cd /some/dir
rm -rf ./*             # if the cd failed, this deletes the WRONG directory
cd /some/dir || exit 1 # fix: stop if cd fails
```

## 5. Single brackets and missing quotes

```bash
[ $name = "Ada" ]      # breaks if $name is empty or has spaces
[[ $name == "Ada" ]]   # correct in Bash
```

## 6. Useless use of `cat`

```bash
cat file | grep word   # works, but spawns an extra process
grep word file         # simpler
```

## 7. A pipeline in a loop loses variables

```bash
count=0
cat data/fruits.txt | while read -r line; do (( count++ )); done
echo "$count"          # still 0! the loop ran in a subshell

count=0
while read -r line; do (( count++ )); done < data/fruits.txt
echo "$count"          # correct: no pipe, no subshell
```

## 8. `echo` and special characters

```bash
echo -n "text"         # behavior of options varies between shells
printf '%s' "text"     # predictable
```

## 9. Forgetting `sudo` applies to the command, not the redirect

```bash
sudo echo x > /etc/file            # redirect runs as YOU: permission denied
echo x | sudo tee /etc/file        # correct
```

## 10. Overwriting with `>` when you meant `>>`

Use `set -o noclobber` interactively, and always double-check the arrow.

## 11. Reading and writing the same file in one pipeline

```bash
sort file.txt > file.txt     # truncates the file BEFORE sort reads it: data lost!
sort file.txt -o file.txt    # correct: sort handles it safely
```

## 12. Assuming relative paths

A script's current directory is wherever it was *run from*, not where the
script lives. To refer to files next to the script:

```bash
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cat "$script_dir/config.ini"
```

## 13. `set -e` is not magic

It is ignored in `if` conditions, `&&`/`||` lists and some other contexts.
Handle expected failures explicitly (see [Robust scripts](08-robust-scripts.md)).

## 14. Unsafe temporary files

Use `mktemp`, and clean up with `trap ... EXIT`.

## 15. Trusting input

Scripts that act on file names, user input or network data must validate it.
A file called `-rf` or `; rm x` is legal. Use `--` to end option parsing:
`rm -- "$file"`.
