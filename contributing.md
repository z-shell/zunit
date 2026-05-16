# Contributing to ZUnit

Thank you for contributing to ZUnit.

Before you start, please read the [code of conduct](code-of-conduct.md). ZUnit
follows the organization-wide policies maintained in
[`z-shell/.github`](https://github.com/z-shell/.github). For larger changes,
open an issue first so the direction can be discussed before you invest time in
implementation.

## What helps

- Documentation fixes, examples, and clarifications
- Bug reports with clear reproduction steps
- Focused pull requests with tests for behavioral changes
- Improvements that keep ZUnit useful for the wider Zi/Z-Shell ecosystem

## Development workflow

1. Create a topic branch from `main`.
2. Keep the change focused and include tests or documentation when behavior
   changes.
3. Build the executable with `./build.zsh`.
4. Run the test suite with `./zunit --tap tests`.
5. Open a pull request targeting `main`.

Please use clear commit messages, avoid unrelated changes, and explain the
reason for the change in the pull request description.

## Releases

`main` is the active development branch. Changes merged there should be
validated continuously, but they should not create a user-facing release by
default.

Releases should be intentional, versioned with semantic tags such as `v0.9.0`,
and published from those tags when the project is ready to ship a new version.
If release automation is added later, it should automate the tag-to-release
publication step rather than minting a new release for every update to `main`.
