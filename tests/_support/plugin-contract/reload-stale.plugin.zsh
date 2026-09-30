# Negative fixture: a plugin whose reloaded surface matches its first load
# while its callback no longer works. A one-time setup is guarded by a flag
# that unload forgets to clear, so a second load skips it. The setup's state
# lives under a name the contract observer excludes (`_zunit_*`), standing
# in for state no snapshot family covers, such as a file or a daemon. After
# unload and a second load the callback exists, returns 0 and is
# byte-identical, but its effect is gone, so only an effect check catches it.
() {
  builtin emulate -L zsh
  builtin setopt local_options typeset_silent

  (( ${+parameters[_contract_fixture_active]} )) && return 0

  if (( ! ${+parameters[_zunit_reload_stale_setup_done]} )); then
    typeset -g _zunit_reload_stale_ready=1
    typeset -gi _zunit_reload_stale_setup_done=1
  fi

  _contract_fixture_callback() {
    builtin emulate -L zsh
    (( ${_zunit_reload_stale_ready:-0} )) || return 0
    (( ${+parameters[_contract_fixture_effect]} )) && _contract_fixture_effect=ran
    return 0
  }

  contract_fixture_plugin_unload() {
    builtin emulate -L zsh
    unset _zunit_reload_stale_ready
    unfunction _contract_fixture_callback
    # The defect: _zunit_reload_stale_setup_done is left set.
    unset _contract_fixture_active
    unfunction contract_fixture_plugin_unload
  }

  typeset -gi _contract_fixture_active=1
}
