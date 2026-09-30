# Negative fixture: the shipped fixture with the reload defect of
# z-shell/z-a-meta-plugins#54. Load defines its callback only when the name
# is free, and unload leaves the callback as an inert stub instead of removing
# it (as a plugin must when a manager can still dispatch to the name). The
# first load and repeated source are correct; after unload and a second load
# the stub survives, so the callback exists and returns 0 but does nothing.
() {
  builtin emulate -L zsh
  builtin setopt local_options typeset_silent

  (( ${+parameters[_contract_fixture_active]} )) && return 0

  (( ${+functions[_contract_fixture_callback]} )) || _contract_fixture_callback() {
    builtin emulate -L zsh
    (( ${+parameters[_contract_fixture_effect]} )) && _contract_fixture_effect=ran
    return 0
  }
  typeset -g _contract_fixture_value=plugin

  typeset -gi _contract_fixture_owned_hook=0
  if (( ${precmd_functions[(Ie)_contract_fixture_callback]:-0} == 0 )); then
    precmd_functions+=(_contract_fixture_callback)
    _contract_fixture_owned_hook=1
  fi

  typeset -gi _contract_fixture_interactive=0
  if [[ -o interactive ]]; then
    zle -N contract-fixture-widget _contract_fixture_callback
    bindkey -N contract-fixture-map emacs
    bindkey -M contract-fixture-map '^Xz' contract-fixture-widget
    _contract_fixture_interactive=1
  fi

  contract_fixture_plugin_unload() {
    builtin emulate -L zsh
    builtin setopt local_options typeset_silent

    [[ ${_contract_fixture_value-} == plugin ]] && unset _contract_fixture_value
    if (( _contract_fixture_owned_hook )); then
      precmd_functions=(${precmd_functions:#_contract_fixture_callback})
      (( ${#precmd_functions} )) || unset precmd_functions
    fi
    if (( _contract_fixture_interactive )); then
      bindkey -D contract-fixture-map
      zle -D contract-fixture-widget
    fi

    # The defect: keep the name defined but inert.
    functions[_contract_fixture_callback]='return 0'

    unset _contract_fixture_active _contract_fixture_owned_hook
    unset _contract_fixture_interactive
    unfunction contract_fixture_plugin_unload
  }

  typeset -gi _contract_fixture_active=1
}
