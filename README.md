![ZUnit](https://zunit.xyz/img/logo.png)

[![GitHub release](https://img.shields.io/github/release/zunit-zsh/zunit.svg)](https://github.com/zunit-zsh/zunit/releases/latest) [![ZUnit (native)](https://github.com/z-shell/zunit/actions/workflows/test-native.yml/badge.svg)](https://github.com/z-shell/zunit/actions/workflows/test-native.yml) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/zunit-zsh/zunit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

ZUnit is a powerful unit testing framework for Zsh.

## Portable plugin lifecycle contract

ZUnit includes observer-safe snapshots for testing the clean portable lifecycle
defined by Zsh Plugin Standard 2. Prime the observer before the baseline, then
name each snapshot with portable ASCII letters, digits, or underscores:

```zsh
zunit_plugin_contract_prime
zunit_plugin_contract_snapshot before

source ./example.plugin.zsh
zunit_plugin_contract_snapshot loaded

assert before plugin_load_surface loaded \
  function:example_refresh \
  function:example_plugin_unload \
  parameter:_example_state \
  style::example:config:mode

source ./example.plugin.zsh
zunit_plugin_contract_snapshot repeated
assert loaded plugin_restored repeated

example_plugin_unload
zunit_plugin_contract_snapshot after
assert before plugin_restored after
```

The load-surface allowlist accepts exact resource identities. Available
families are `function`, `parameter`, `alias`, `option`, `trap`, `module`,
`path`, `fpath`, `hook`, `widget`, `binding`, and `style`. A failure reports
resource identities only; captured parameter values are never printed.

For an ownership-aware unload test, take a snapshot after load, another after
simulating post-load user changes, and one after unload:

```zsh
assert before plugin_unloaded loaded user_changed after
```

For each resource, this assertion restores the pre-load value when the user did
not change the plugin-owned value, otherwise it requires unload to preserve the
user's newer value. Use separate clean-shell tests for hostile initial state,
partial initialization failure, and interactive behavior. The repository's
`tests/_support/plugin-contract/scenario.zsh` demonstrates repeated source,
partial failure, hostile state, post-load changes, and both `zsh -f` and
`zsh -f -i` execution.

## 📖 Documentation

The canonical documentation for ZUnit, including installation guides, test syntax, and CI integration, has moved to the **Z-Shell Wiki**:

👉 **[Z-Shell Wiki: ZUnit Documentation](https://wiki.zshell.dev/community/zunit)**

---

## Repository Purpose

This repository is maintained by the Z-Shell organization as the active
workspace mirror used by the wider Zi/Z-Shell ecosystem. Historical upstream
links are preserved where they still describe the original project, while
runtime integrations continue to follow the currently published package
coordinates used across the ecosystem.

> **Note:** The `z-shell/zunit` repository is the active development mirror;
> runtime package coordinates (e.g. for Homebrew or zplug) may still reference
> `z-shell/zunit` to avoid breaking existing user configurations.

## Maintenance

The Z-Shell mirror validates the project with GitHub Actions using native tests,
Zsh syntax checks, and a scheduled Zsh compatibility matrix.

As a maintained Z-Shell repository, this mirror follows the organization's
[class-2 testing and CI strategy](https://github.com/z-shell/.github/blob/main/decisions/0009-testing-ci-strategy.md)
and [repository settings baseline](https://github.com/z-shell/.github/blob/main/decisions/0013-repository-settings-baseline.md).
Its fork status affects audit sampling, not the applicability of those policies.

## License

Copyright (c) 2016 James Dinsdale <hi@molovo.co> (molovo.co)
ZUnit is licensed under The MIT License (MIT)
