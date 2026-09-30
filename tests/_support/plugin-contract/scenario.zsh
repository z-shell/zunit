#!/usr/bin/env zsh

builtin emulate -L zsh
builtin setopt extended_glob typeset_silent

0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"
typeset scenario=${1:-ordinary}
typeset expected_mode=${2:-noninteractive}
typeset fixture_name=${3:-fixture}
[[ $fixture_name == [A-Za-z0-9_-]## ]] || { print -u2 -r -- "invalid fixture: $fixture_name"; exit 2 }
typeset support_dir=${0:A:h}
typeset repository_dir=${support_dir:h:h:h}
typeset fixture=${support_dir}/${fixture_name}.plugin.zsh
[[ -r $fixture ]] || { print -u2 -r -- "missing fixture: $fixture_name"; exit 2 }

source "${repository_dir}/src/plugin-contract.zsh" || exit
zunit_plugin_contract_prime || exit

if [[ $expected_mode == interactive ]]; then
  [[ -o interactive ]] || exit 20
else
  [[ ! -o interactive ]] || exit 21
fi

case $scenario in
  ordinary)
    zunit_plugin_contract_snapshot before || exit
    source "$fixture" || exit
    zunit_plugin_contract_snapshot loaded || exit
    source "$fixture" || exit
    zunit_plugin_contract_snapshot repeated || exit
    _zunit_assert_plugin_restored loaded repeated || exit
    contract_fixture_plugin_unload || exit
    zunit_plugin_contract_snapshot after || exit
    _zunit_assert_plugin_restored before after
    ;;
  hostile)
    typeset -g _contract_fixture_value=hostile
    zstyle ':contract-fixture:config' mode hostile
    zunit_plugin_contract_snapshot before || exit
    source "$fixture" || exit
    zunit_plugin_contract_snapshot loaded || exit
    contract_fixture_plugin_unload || exit
    zunit_plugin_contract_snapshot after || exit
    _zunit_assert_plugin_restored before after
    ;;
  partial)
    zstyle ':contract-fixture:test' fail-load yes
    zunit_plugin_contract_snapshot before || exit
    source "$fixture"
    (( $? == 7 )) || exit 22
    zunit_plugin_contract_snapshot partial || exit
    contract_fixture_plugin_unload || exit
    zunit_plugin_contract_snapshot after || exit
    _zunit_assert_plugin_restored before after
    ;;
  user-change)
    zunit_plugin_contract_snapshot before || exit
    source "$fixture" || exit
    zunit_plugin_contract_snapshot loaded || exit
    typeset -g _contract_fixture_value=user
    zunit_plugin_contract_snapshot user || exit
    contract_fixture_plugin_unload || exit
    zunit_plugin_contract_snapshot after || exit
    _zunit_assert_plugin_unloaded before loaded user after
    ;;
  reload)
    # Load, unload, and load again in one clean shell. The second load must
    # restore the first load's surface, and its callback must still do its
    # job: presence or a zero status alone would accept an inert stub. Exact
    # unload restoration is the ordinary scenario's job, so it is not
    # repeated here.
    source "$fixture" || exit
    zunit_plugin_contract_snapshot loaded || exit
    contract_fixture_plugin_unload || exit
    source "$fixture" || exit
    zunit_plugin_contract_snapshot reloaded || exit
    _zunit_assert_plugin_restored loaded reloaded || exit
    typeset -g _contract_fixture_effect=
    _contract_fixture_callback || exit 23
    [[ $_contract_fixture_effect == ran ]] || exit 24
    ;;
  *)
    print -u2 -r -- "unknown scenario: $scenario"
    exit 2
    ;;
esac
