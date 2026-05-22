# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
############################
# The 'zunit init' command #
############################

###
# Output usage information and exit
###
function _zunit_init_usage() {
  echo "$(_zunit_color yellow 'Usage:')"
  echo "  zunit init [options]"
  echo
  echo "$(_zunit_color yellow 'Options:')"
  echo "  -h, --help            Output help text and exit"
  echo "  -g, --github-actions  Generate .github/workflows/zunit.yml in project"
  echo "  -t, --travis          Generate legacy .travis.yml in project"
}

###
# Parse a YAML config file
# Based on https://gist.github.com/pkuczynski/8665367
###
function _zunit_parse_yaml() {
  local s w fs prefix=$2
  s='[[:space:]]*'
  w='[a-zA-Z0-9_]*'
  fs="$(echo @|tr @ '\034')"
  sed -ne "s|^\(${s}\)\(${w}\)${s}:${s}\"\(.*\)\"${s}\$|\1${fs}\2${fs}\3|p" \
      -e "s|^\(${s}\)\(${w}\)${s}[:-]${s}\(.*\)${s}\$|\1${fs}\2${fs}\3|p" "$1" |
  awk -F"${fs}" '{
  indent = length($1)/2;
  vname[indent] = $2;
  for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
          vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
          printf("%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, $3);
      }
  }' | sed 's/_=/+=/g'
}

function _zunit_init() {
  local with_github_actions with_travis zunit_version

  zparseopts -D \
    g=with_github_actions -github-actions=with_github_actions \
    t=with_travis -travis=with_travis

  # The contents of .zunit.zsh
  local zunit_zsh="# ZUnit configuration
ZUNIT_TESTS_DIR='tests'
ZUNIT_OUTPUT_DIR='tests/_output'
ZUNIT_SUPPORT_DIR='tests/_support'
ZUNIT_FAIL_FAST=false
ZUNIT_ALLOW_RISKY=false
ZUNIT_TIME_LIMIT=0
ZUNIT_TAP=false
ZUNIT_VERBOSE=false"

  # An example test file
  local example="#!/usr/bin/env zunit

@test 'Example' {
  assert \"true\" same_as \"true\"
}"

  # An empty bootstrap script
  local bootstrap="#!/usr/bin/env zsh

# Write your bootstrap code here"

  # An example .travis.yml config
  local travis_yml="addons:
  apt:
    packages:
      zsh
install:
  - mkdir .bin
  - curl -L https://github.com/zunit-zsh/zunit/releases/download/v$(_zunit_version)/zunit > .bin/zunit
before_script:
  - chmod u+x .bin/{zunit}
  - export PATH=\"\$PWD/.bin:\$PATH\"
script: zunit"

  zunit_version="$(_zunit_version)"

  # An example GitHub Actions workflow
  local github_actions_yml="---
name: \"ZUnit\"

on:
  push:
  pull_request:
  workflow_dispatch: {}

permissions:
  contents: read

jobs:
  zunit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -yq zsh
          mkdir -p .bin
          curl -fsSL 'https://github.com/zunit-zsh/zunit/releases/download/v${zunit_version}/zunit' > .bin/zunit
          chmod u+x .bin/{zunit}
      - name: Test
        run: PATH=\"\$PWD/.bin:\$PATH\" zunit --tap tests"

  # Check that a config file doesn't already exist so that
  # we don't overwrite it
  if [[ -f "$PWD/.zunit.zsh" ]]; then
    echo "$(_zunit_color yellow "ZUnit config file already exists at $PWD/.zunit.zsh. Skipping...")"
  elif [[ -f "$PWD/.zunit.yml" ]]; then
    echo "$(_zunit_color yellow "ZUnit config file already exists at $PWD/.zunit.yml. Skipping...")"
  else
    # Write the contents to the config file
    echo "Writing ZUnit config file to $PWD/.zunit.zsh"
    echo "$zunit_zsh" > "$PWD/.zunit.zsh"
  fi

  # Check that the tests directory doesn't already exist so that
  # we don't overwrite it
  if [[ -d "$PWD/tests" ]]; then
    echo "$(_zunit_color yellow "Test directory already exists at $PWD/tests. Skipping...")"
  else
    echo "Creating test directory at $PWD/tests"
    # Create the directory structure for tests
    mkdir -p tests/_{output,support}
    touch tests/_{output,support}/.gitkeep

    # Save the bootstrap script and example test
    echo "$bootstrap" > "$PWD/tests/_support/bootstrap"
    echo "$example" > "$PWD/tests/example.zunit"
  fi

  # If GitHub Actions config has been requested
  if [[ -n $with_github_actions ]]; then
    if [[ -f "$PWD/.github/workflows/zunit.yml" ]]; then
      echo "$(_zunit_color yellow "GitHub Actions workflow already exists at $PWD/.github/workflows/zunit.yml. Skipping...")"
    else
      echo "Writing GitHub Actions workflow to $PWD/.github/workflows/zunit.yml"
      mkdir -p "$PWD/.github/workflows"
      echo "$github_actions_yml" > "$PWD/.github/workflows/zunit.yml"
    fi
  fi

  # If travis config has been requested
  if [[ -n $with_travis ]]; then
    # Check that a travis config doesn't already exist so that
    # we don't overwrite it
    if [[ -f "$PWD/.travis.yml" ]]; then
      echo "$(_zunit_color yellow "Travis config already exists at $PWD/.travis.yml. Skipping...")"
    else
      echo "Writing Travis CI config to $PWD/.travis.yml"
      # Write the contents to the config file
      echo "$travis_yml" > "$PWD/.travis.yml"
    fi
  fi
}
