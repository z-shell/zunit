#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

builtin emulate -L zsh
builtin setopt err_return no_unset pipe_fail

local tag="${1:-}"
local binary="${2:-./zunit}"

if [[ ! "$tag" =~ '^v[0-9]+[.][0-9]+[.][0-9]+$' ]]; then
  print -ru2 -- "Expected semantic version tag like v1.2.3, got '${tag:-<empty>}'"
  exit 1
fi

if [[ ! -x "$binary" ]]; then
  print -ru2 -- "Release binary '$binary' is missing or is not executable"
  exit 1
fi

local expected_version="${tag#v}"
local actual_version
actual_version="$($binary --version)"

if [[ "$actual_version" != "$expected_version" ]]; then
  print -ru2 -- "Release tag $tag does not match zunit version $actual_version"
  exit 1
fi

print -r -- "Release tag $tag matches zunit version $actual_version"
