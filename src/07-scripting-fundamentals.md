# Scripting fundamentals

A **shell script** is a text file of commands. Anything you can type at the
prompt you can save, repeat and share. Scripts are how you stop doing the same
task by hand.

## Your first script

Create a file called `hello.sh`:

```bash
#!/usr/bin/env bash
echo "Hello from $(hostname)"
```

- The first line, the **shebang**, tells the system which program should run
  the file. `#!/usr/bin/env bash` finds Bash on the `PATH`, which is portable.
- Make it executable, then run it with an explicit path:

<!-- test -->
```bash
cat > hello.sh <<'SCRIPT'
#!/usr/bin/env bash
echo "Hello from $(hostname)"
SCRIPT
chmod +x hello.sh
./hello.sh
bash hello.sh      # also works, no execute bit needed
```

Why `./hello.sh` and not `hello.sh`? The shell only runs programs found in the
directories listed in `$PATH`, and the current directory is deliberately not
one of them.

## Variables

No declaration, no types, **no spaces around `=`**.

<!-- test -->
```bash
name="Ubuntu"
version=26.04
echo "Welcome to $name $version"
echo "Welcome to ${name}-LTS"     # braces mark where the name ends
readonly PI=3.14159               # cannot be changed later
unset name
echo "name is now: '${name:-}'"
```

A variable set in a script is visible only inside that script. To pass it to
programs you start, **export** it:

<!-- test -->
```bash
GREETING="hi"
bash -c 'echo "child sees: [$GREETING]"'     # empty: not exported
export GREETING
bash -c 'echo "child sees: [$GREETING]"'     # now it is
```

### Special variables

| Variable | Meaning |
| --- | --- |
| `$0` | Name of the script |
| `$1`, `$2`, ... | Positional arguments |
| `$#` | Number of arguments |
| `"$@"` | All arguments, each as a separate word (use this one) |
| `"$*"` | All arguments as one single string |
| `$?` | Exit code of the last command |
| `$$` | PID of the current shell |
| `$!` | PID of the last background job |

<!-- test -->
```bash
cat > args.sh <<'SCRIPT'
#!/usr/bin/env bash
echo "script: $0"
echo "count:  $#"
echo "first:  $1"
for arg in "$@"; do
    echo "  arg: $arg"
done
SCRIPT
bash args.sh one "two words" three
```

## Quoting, again, because it matters

<!-- test -->
```bash
file="my notes.txt"
touch "$file"
ls -l "$file"          # correct: one argument
ls -l $file || true    # wrong: two arguments, "my" and "notes.txt"
```

Unquoted expansions are split on whitespace and also treated as glob patterns.
Quote every `"$variable"`, `"$(command)"` and `"${array[@]}"` unless you
have a specific reason not to. [ShellCheck](09-tooling-and-testing.md) will
remind you.

## Arithmetic

Use `$(( ))` for integer math. Bash has no floating point; for decimals use
`awk` or `bc`.

<!-- test -->
```bash
a=7; b=3
echo $(( a + b ))      # 10
echo $(( a * b ))      # 21
echo $(( a / b ))      # 2   (integer division)
echo $(( a % b ))      # 1   (remainder)
echo $(( a ** 2 ))     # 49
(( a > b )) && echo "a is bigger"
count=0
(( count++ )) || true  # note: exits 1 when the old value was 0
echo "count=$count"
awk 'BEGIN { printf "%.2f\n", 7 / 3 }'
```

## Arrays

<!-- test -->
```bash
fruits=(apple banana cherry)
echo "${fruits[0]}"            # first element (zero-based)
echo "${fruits[@]}"            # all elements
echo "${#fruits[@]}"           # how many
fruits+=(date)                 # append
for f in "${fruits[@]}"; do echo "- $f"; done
echo "${fruits[@]:1:2}"        # slice: start 1, length 2
```

**Associative arrays** (key-value maps) need `declare -A`:

<!-- test -->
```bash
declare -A capital=([France]=Paris [Japan]=Tokyo)
capital[Peru]=Lima
echo "${capital[Japan]}"
for country in "${!capital[@]}"; do      # ${!arr[@]} = the keys
    echo "$country -> ${capital[$country]}"
done | sort
```

To read a file's lines into an array: `mapfile -t lines < data/fruits.txt`.

## Working with strings (parameter expansion)

Bash can edit strings without calling any other program. These are called
*parameter expansions*.

| Syntax | Result |
| --- | --- |
| `${var:-default}` | `$var`, or `default` if unset or empty |
| `${var:=default}` | Same, and also assigns the default to `var` |
| `${var:?message}` | Exit with an error if unset or empty |
| `${#var}` | Length |
| `${var:2:3}` | Substring: from offset 2, length 3 |
| `${var#pattern}` / `${var##pattern}` | Remove shortest / longest match from the **start** |
| `${var%pattern}` / `${var%%pattern}` | Remove shortest / longest match from the **end** |
| `${var/old/new}` / `${var//old/new}` | Replace first / all matches |
| `${var^^}` / `${var,,}` | UPPERCASE / lowercase |

<!-- test -->
```bash
path="/home/learner/report.final.txt"
echo "${path##*/}"        # report.final.txt  (basename)
echo "${path%/*}"         # /home/learner     (dirname)
echo "${path%.*}"         # /home/learner/report.final
echo "${path##*.}"        # txt  (extension)
echo "${path/learner/alice}"
word="ubuntu"
echo "${word^^} ${word^} ${#word}"
echo "${UNSET_VAR:-fallback}"
```

## Conditionals

`if` runs a command and checks its exit code. `[[ ... ]]` is Bash's test
command, and it is the one to use in Bash scripts.

<!-- test -->
```bash
n=15
if [[ $n -gt 10 ]]; then
    echo "big"
elif [[ $n -gt 5 ]]; then
    echo "medium"
else
    echo "small"
fi

file=data/notes.txt
[[ -f $file ]] && echo "$file exists"
[[ -z "" ]] && echo "empty string"
[[ "ubuntu" == u* ]] && echo "starts with u"
[[ "2026" =~ ^[0-9]+$ ]] && echo "all digits"
```

Common tests:

| Test | True when |
| --- | --- |
| `-e path` | exists |
| `-f path` / `-d path` | is a regular file / directory |
| `-r` / `-w` / `-x` | readable / writable / executable |
| `-s path` | exists and is not empty |
| `-z str` / `-n str` | string is empty / non-empty |
| `a == b`, `a != b` | strings equal / different |
| `a -eq b`, `-ne`, `-lt`, `-le`, `-gt`, `-ge` | integer comparisons |
| `a =~ regex` | matches an extended regular expression |

Combine with `&&`, `||` and `!` inside `[[ ]]`. Inside `(( ))` you can use
normal operators: `(( n > 5 && n < 20 ))`.

### `case` for many branches

<!-- test -->
```bash
for answer in yes No maybe quit; do
    case "${answer,,}" in
        y|yes) echo "$answer: confirmed" ;;
        n|no)  echo "$answer: declined" ;;
        q*)    echo "$answer: quitting" ;;
        *)     echo "$answer: unknown" ;;
    esac
done
```

## Loops

<!-- test -->
```bash
# for over a list
for city in Lisbon Austin Tokyo; do echo "city: $city"; done

# for over files (glob, not `ls`!)
for f in data/*.txt; do echo "$f has $(wc -l < "$f") lines"; done

# C-style
for (( i = 1; i <= 3; i++ )); do echo "i=$i"; done

# a range
for i in {1..3}; do echo "n=$i"; done

# while with a condition
n=3
while (( n > 0 )); do echo "countdown $n"; (( n-- )); done
```

**Reading a file line by line** is a pattern you will use constantly:

<!-- test -->
```bash
while IFS= read -r line; do
    echo "got: $line"
done < data/fruits.txt | head -n 3

# splitting fields while reading a CSV
while IFS=, read -r name city age team; do
    [[ $name == name ]] && continue       # skip header
    echo "$name lives in $city"
done < data/people.csv | head -n 3
```

`IFS=` stops Bash from trimming whitespace and `-r` stops it from mangling
backslashes. Use both, always.

`break` leaves a loop; `continue` skips to the next iteration.

## Functions

<!-- test -->
```bash
greet() {
    local name="${1:-world}"      # local keeps the variable inside the function
    echo "Hello, $name!"
}

greet
greet Ubuntu

is_even() {
    (( $1 % 2 == 0 ))             # the exit code is the "return value"
}

if is_even 10; then echo "10 is even"; fi

square() { echo $(( $1 * $1 )); }  # to return data, print it
result=$(square 9)
echo "9 squared is $result"
```

Functions use `return N` for exit codes (0-255) and `echo` for data. Variables
in functions are global unless declared `local`, so always use `local`.

> Prefer the `name() { ... }` form. The `function name { ... }` form is Bash-only
> and gains you nothing.

## Reading input

<!-- test -->
```bash
read -r -p "Your name: " name <<< "Ada"
echo "Hi, $name"
read -r -s -p "Password: " secret <<< "hunter2" ; echo
echo "(${#secret} characters)"
```

In real scripts, `read -r -p "Question? " answer` reads from the keyboard.
`-s` hides what is typed. (The here-strings above only simulate typing so the
example runs unattended.)

## Printing properly with `printf`

`echo` behaves inconsistently with special characters and options. For
anything beyond trivial output, use `printf`:

<!-- test -->
```bash
printf '%s is %d years old\n' "Alice" 34
printf '%-10s|%5.1f|\n' "left" 3.14159
printf '%s\n' "${fruits[@]:-none}"
printf '%05d\n' 42
```

## Exercises

1. Write a script `sum.sh` that prints the sum of all its arguments.
2. Given `f="archive.tar.gz"`, print `archive` using only parameter expansion.
3. Loop over every `.csv` file in `data` and print its name and line count.
4. Write a function `is_number` that succeeds only if its argument is all
   digits.

<details>
<summary>Answers</summary>

1. A script like this:

   ```bash
   #!/usr/bin/env bash
   total=0
   for n in "$@"; do (( total += n )); done
   echo "$total"
   ```

2. `echo "${f%%.*}"`
3. `for f in data/*.csv; do echo "$f: $(wc -l < "$f")"; done`
4. `is_number() { [[ $1 =~ ^[0-9]+$ ]]; }`

</details>
