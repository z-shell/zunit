() {
  builtin emulate -L zsh
  builtin setopt local_options typeset_silent

  (( ${+parameters[_contract_fixture_active]} )) && return 0

  typeset -gi _contract_fixture_had_value=${+parameters[_contract_fixture_value]}
  typeset -g _contract_fixture_previous_value=${_contract_fixture_value-}
  typeset -gi _contract_fixture_had_callback=${+functions[_contract_fixture_callback]}
  typeset -g _contract_fixture_previous_callback=${functions[_contract_fixture_callback]-}
  typeset -gi _contract_fixture_had_style=0
  typeset -g _contract_fixture_previous_style
  zstyle -s ':contract-fixture:config' mode _contract_fixture_previous_style &&
    _contract_fixture_had_style=1

  _contract_fixture_callback() {
    builtin emulate -L zsh
    :
  }
  typeset -g _contract_fixture_callback_body=${functions[_contract_fixture_callback]}
  typeset -g _contract_fixture_value=plugin
  zstyle ':contract-fixture:config' mode plugin

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
    local _contract_fixture_current_style

    if [[ ${_contract_fixture_value-} == plugin ]]; then
      if (( _contract_fixture_had_value )); then
        typeset -g _contract_fixture_value=$_contract_fixture_previous_value
      else
        unset _contract_fixture_value
      fi
    fi

    if zstyle -s ':contract-fixture:config' mode _contract_fixture_current_style &&
      [[ $_contract_fixture_current_style == plugin ]]; then
      if (( _contract_fixture_had_style )); then
        zstyle ':contract-fixture:config' mode "$_contract_fixture_previous_style"
      else
        zstyle -d ':contract-fixture:config' mode
      fi
    fi

    if (( _contract_fixture_owned_hook )); then
      precmd_functions=(${precmd_functions:#_contract_fixture_callback})
      (( ${#precmd_functions} )) || unset precmd_functions
    fi

    if (( _contract_fixture_interactive )); then
      bindkey -D contract-fixture-map
      zle -D contract-fixture-widget
    fi

    if [[ ${functions[_contract_fixture_callback]-} == $_contract_fixture_callback_body ]]; then
      if (( _contract_fixture_had_callback )); then
        functions[_contract_fixture_callback]=$_contract_fixture_previous_callback
      else
        unfunction _contract_fixture_callback
      fi
    fi

    unset _contract_fixture_active
    unset _contract_fixture_had_value _contract_fixture_previous_value
    unset _contract_fixture_had_callback _contract_fixture_previous_callback
    unset _contract_fixture_had_style _contract_fixture_previous_style
    unset _contract_fixture_callback_body _contract_fixture_owned_hook
    unset _contract_fixture_interactive
    unfunction contract_fixture_plugin_unload
  }

  if zstyle -t ':contract-fixture:test' fail-load; then
    return 7
  fi
  typeset -gi _contract_fixture_active=1
}
