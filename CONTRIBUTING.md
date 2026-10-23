# Contributing

Thank you for helping make this guide better. Fixes to typos, unclear
explanations and wrong commands are all welcome.

## Ground rules

- **Target Ubuntu 26.04 LTS.** If something differs on other releases, mention
  it in a short note, but do not write the main text for them.
- **Explain why, not only how.** A command without its reason is easy to forget.
- **Quote your variables** in every example: `"$var"`, not `$var`.
- **Short paragraphs, plain words.** Define a term the first time it appears.
- Examples that print output show a `$` prompt in a `console` block. Examples
  you type or run use a `bash` block.

## Making examples testable

Put `<!-- test -->` on the line directly above a `bash` code block and CI will
run it in a fresh copy of `lab/` and require exit status 0.

````markdown
<!-- test -->
```bash
grep -c apple data/fruits.txt
```
````

Do not mark blocks that need the network, a real system service, or root.
If a command is expected to fail, end it with `|| true` or restructure the
example so the block as a whole succeeds.

## Adding a screenshot

Never commit screenshots by hand. Add one line to `scripts/screenshots.txt`:

```text
name | command to run
```

Run `make screenshots`, then reference the image in Markdown as
`![alt text](images/name.svg)`. Always write meaningful alt text and keep the
command in the page as copyable text as well.

## Working locally

```bash
make lab           # build the Ubuntu 26.04 image
make test          # run the examples
make screenshots   # build the images
make serve         # preview the book
make lint          # Markdown lint (needs npx)
```

## Pull requests

- Keep each PR focused on one topic.
- Tick the checklist in the PR template.
- If CI fails because output differs on 26.04, that is useful information: fix
  the example, or explain the difference in the text.

## Reporting problems

Use the issue templates. For "the output differs on my machine", please include
the output of `lsb_release -a`, `bash --version` and `ls --version`.
