# The Ubuntu Bash Guide

A modern, hands-on guide to the Linux command line and Bash scripting, written
for **Ubuntu 26.04 LTS (Resolute Raccoon)**.

**Read it online:** <https://jermsmit.github.io/ubuntu-bash-guide/>

## What you will learn

| Part | Topics |
| --- | --- |
| **1. The command line** | Navigation, files and permissions, text processing (`grep`, `sed`, `awk`, `jq`), pipes and redirection, processes, systemd, `apt`, networking, SSH |
| **2. Bash scripting** | Variables, arrays, conditionals, loops, functions, strict mode, `trap`, `getopts`, ShellCheck, shfmt, Bats tests |
| **3. Daily use** | Aliases, history, prompts, tmux, cron and systemd timers, parallel jobs, four complete projects |
| **Appendices** | Ubuntu 26.04 notes (sudo-rs, uutils), common pitfalls, cheat sheet, glossary |

Every chapter has exercises with answers.

## Why you can trust the output

- Runnable examples are marked in the Markdown and **executed in CI inside an
  `ubuntu:26.04` container**. If a command's behavior changes, the build fails.
- Screenshots are **generated from real command output** in that same
  container; none are edited by hand.
- The Docker lab gives every reader an identical environment, so nobody has to
  risk their own system.

## Quick start

You need Docker and `make`.

```bash
git clone https://github.com/jermsmit/ubuntu-bash-guide.git
cd ubuntu-bash-guide

make shell         # a throwaway Ubuntu 26.04 shell with the sample files
```

To work on the book itself:

```bash
make test          # run every <!-- test --> example in the lab
make screenshots   # regenerate src/images/*.svg from real output
make serve         # live preview at http://localhost:3000 (needs mdBook)
```

Install [mdBook](https://rust-lang.github.io/mdBook/guide/installation.html) for
`make serve` and `make book`. Run `make help` to see every target.

## Repository layout

```text
src/                 the book: one Markdown file per chapter (+ SUMMARY.md)
lab/                 sample files that every example runs against
scripts/
  check-examples.sh  runs the <!-- test --> blocks
  make-screenshots.sh + screenshots.txt   builds the images
  init-repo.sh       one-time: fills in your GitHub username
Dockerfile           the Ubuntu 26.04 lab image
book.toml            mdBook configuration
.github/workflows/   CI and GitHub Pages deployment
```

## Publishing your own copy

1. Create a repository on GitHub and push this code to the `main` branch.
2. Run `scripts/init-repo.sh YOUR_USERNAME` once to replace the placeholder
   username, then commit the result.
3. In the repository, go to **Settings, then Pages** and set **Source** to
   **GitHub Actions**.
4. Push to `main`. The *Deploy to GitHub Pages* workflow tests the examples,
   generates the screenshots, builds the book and publishes it.

## Author

Written and maintained by Jermal Smith ([@jermsmit](https://github.com/jermsmit)).

## Contributing

Corrections and new content are welcome. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) first, and follow the
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

Released under the MIT License. See [LICENSE.md](LICENSE.md).
