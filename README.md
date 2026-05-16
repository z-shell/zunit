# ZUnit

ZUnit is a unit testing framework for Zsh projects.

This repository is maintained by the [Z-Shell organization](https://github.com/z-shell)
for the wider Zi/Z-Shell ecosystem.

## Installation

### Manual install

```sh
git clone https://github.com/z-shell/zunit.git
cd zunit
./build.zsh
chmod u+x ./zunit
cp ./zunit /usr/local/bin
```

ZUnit requires [Revolver](https://github.com/zdharma/revolver) to be installed
and available in your `$PATH`.

### Legacy package-manager recipes

Older package-manager recipes may still reference historical project
coordinates such as `zunit-zsh/zunit` or `zdharma/zunit`. They are not the
canonical source for this repository, so prefer the manual install path above
unless you have verified that a specific integration is still maintained.

## Writing tests

Tests use a concise syntax inspired by [Bats](https://github.com/bats-core/bats-core):

```zsh
#!/usr/bin/env zunit

@test 'my first test' {
  # Test contents here
}
```

Each test file must start with the `#!/usr/bin/env zunit` shebang. The body of a
test may contain any valid Zsh code.

## Running tests

Run the full suite from the project root:

```sh
zunit
```

You can also pass a test file, a directory, or a glob:

```sh
zunit tests/example.zunit
zunit tests
zunit 'tests/**/*.zunit'
```

## Documentation

Full documentation is available in the [Z-Shell wiki](https://wiki.zshell.dev/community/zunit).

## Contributing

Contributions are welcome. See [contributing.md](contributing.md) and
[code-of-conduct.md](code-of-conduct.md) before opening an issue or pull
request.

## License

ZUnit is licensed under the MIT License. See [LICENSE](LICENSE).
