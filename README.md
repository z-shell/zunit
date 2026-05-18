![ZUnit](https://zunit.xyz/img/logo.png)

[![GitHub release](https://img.shields.io/github/release/zunit-zsh/zunit.svg)](https://github.com/zunit-zsh/zunit/releases/latest) [![ZUnit (native)](https://github.com/z-shell/zunit/actions/workflows/test-native.yml/badge.svg)](https://github.com/z-shell/zunit/actions/workflows/test-native.yml) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/zunit-zsh/zunit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

ZUnit is a powerful unit testing framework for ZSH.

This repository is maintained by the Z-Shell organization as the active
workspace mirror used by the wider Zi/Z-Shell ecosystem. Historical upstream
links are preserved where they still describe the original project, while
runtime integrations continue to follow the currently published package
coordinates used across the ecosystem.

> **Note:** The install snippets below intentionally reference `zdharma/zunit`
> and `zdharma/revolver` — those are the package coordinates that zplug,
> Homebrew, and related tooling still resolve at runtime. The `z-shell/zunit`
> repository (where this README and the CI badges live) is the active
> development mirror; the `zdharma/*` names are preserved to avoid breaking
> existing user configurations.

## Maintenance

The Z-Shell mirror validates the project with GitHub Actions using native tests,
Zsh syntax checks, and a scheduled Zsh compatibility matrix. The matrix follows
the versions used by the surrounding Z-Shell test infrastructure so downstream
projects can rely on the same compatibility baseline.

## Installation

> **WARNING**: Although the majority of ZUnit's functionality works as expected, it is in the early stages of development, and as such bugs are likely to be present. Please continue with caution, and [report any issues](https://github.com/zunit-zsh/zunit/issues/new) you may have.

### [Zulu](https://github.com/zulu-zsh/zulu)

```sh
zulu install zunit
```

> **NOTE:** In versions of Zulu prior to `1.2.0`, there is an additional step required after install:

```sh
cd ~/.zulu/packages/zunit
./build.zsh
zulu link zunit
```

### [zplug](https://github.com/zplug/zplug)

ZUnit and its dependencies can all be installed with zplug.

```sh
zplug 'zdharma/revolver', \
  as:command, \
  use:revolver
zplug 'zdharma/zunit', \
  as:command, \
  use:zunit, \
  hook-build:'./build.zsh'
```

### Homebrew

```sh
brew install zunit-zsh/zunit/zunit
```

### Manual

```sh
git clone https://github.com/zdharma/zunit
cd ./zunit
./build.zsh
chmod u+x ./zunit
cp ./zunit /usr/local/bin
```

> ZUnit requires [Revolver](https://github.com/zdharma/revolver) to be installed, and in your `$PATH`. The zulu or homebrew installation methods will install this dependency for you.

## Writing Tests

### Test syntax

Tests in ZUnit have a simple syntax, which is inspired by the [BATS](https://github.com/sstephenson/bats) framework.

```sh
#!/usr/bin/env zunit

@test 'My first test' {
	# Test contents here
}
```

The body of each test can contain any valid ZSH code. The zunit shebang `#!/usr/bin/env zunit` **MUST** appear at the top of each test file, or ZUnit will not run it.

To bootstrap a new project with a current CI example, run:

```sh
zunit init --github-actions
```

## Documentation

For a full breakdown of ZUnit's syntax and functionality, check out the [official documentation](https://zunit.xyz/docs/).

## Contributing

All contributions are welcome, and encouraged. Please read our [contribution guidelines](contributing.md) and [code of conduct](code-of-conduct.md) for more information.

## License

Copyright (c) 2016 James Dinsdale <hi@molovo.co> (molovo.co)

ZUnit is licensed under The MIT License (MIT)

## Team

- [James Dinsdale](http://molovo.co)
