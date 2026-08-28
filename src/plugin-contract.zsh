# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# Snapshot storage is process-local and excluded from parameter observations.
# Tests run in isolated ZUnit subprocesses, so values never cross test cases.
typeset -gA _zunit_plugin_contract_snapshots
typeset -gA _zunit_plugin_contract_snapshot_names
typeset -ga _zunit_plugin_contract_reply

_zunit_plugin_contract_put() {
  builtin emulate -L zsh
  local _zunit_plugin_contract_snapshot=$1
  local _zunit_plugin_contract_resource=$2
  local _zunit_plugin_contract_value=$3
  local _zunit_plugin_contract_key="${_zunit_plugin_contract_snapshot}:${_zunit_plugin_contract_resource}"

  _zunit_plugin_contract_snapshots[$_zunit_plugin_contract_key]=$_zunit_plugin_contract_value
}

_zunit_plugin_contract_parameter_is_observer_state() {
  builtin emulate -L zsh
  builtin setopt local_options extended_glob
  local _zunit_plugin_contract_name=$1

  [[ $_zunit_plugin_contract_name != [A-Za-z_][A-Za-z0-9_]# ]] && return 0
  case $_zunit_plugin_contract_name in
    _zunit_*|zunit_*|functions|functions_source|functions_trace|dis_functions|parameters|aliases|dis_aliases|galiases|saliases|options|modules|widgets|keymaps|path|PATH|fpath|FPATH|module_path)
      return 0
      ;;
    _|ARGC|argv|RANDOM|SECONDS|EPOCHSECONDS|EPOCHREALTIME|ZSH_SUBSHELL|LINENO|funcstack|functrace|zsh_eval_context|ZSH_DEBUG_CMD|TTYIDLE|HISTCMD|pipestatus|status)
      return 0
      ;;
    chpwd_functions|periodic_functions|precmd_functions|preexec_functions|zshaddhistory_functions|zshexit_functions|zsh_directory_name_functions)
      return 0
      ;;
  esac
  return 1
}

_zunit_plugin_contract_snapshot_functions() {
  builtin emulate -L zsh
  local _zunit_plugin_contract_snapshot=$1
  local _zunit_plugin_contract_name _zunit_plugin_contract_value
  local -a _zunit_plugin_contract_names

  _zunit_plugin_contract_names=(${(ok)functions})
  for _zunit_plugin_contract_name in $_zunit_plugin_contract_names; do
    _zunit_plugin_contract_value=${functions[$_zunit_plugin_contract_name]}
    if (( ${+parameters[functions_source]} && ${+functions_source[$_zunit_plugin_contract_name]} )); then
      _zunit_plugin_contract_value+=$'\x1f'${functions_source[$_zunit_plugin_contract_name]}
    fi
    if (( ${+parameters[functions_trace]} && ${+functions_trace[$_zunit_plugin_contract_name]} )); then
      _zunit_plugin_contract_value+=$'\x1f'${functions_trace[$_zunit_plugin_contract_name]}
    fi
    _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
      "function:${_zunit_plugin_contract_name}" "$_zunit_plugin_contract_value"
  done
}

_zunit_plugin_contract_snapshot_parameters() {
  builtin emulate -L zsh
  local _zunit_plugin_contract_snapshot=$1
  local _zunit_plugin_contract_name _zunit_plugin_contract_value
  local -a _zunit_plugin_contract_names

  _zunit_plugin_contract_names=(${(ok)parameters})
  for _zunit_plugin_contract_name in $_zunit_plugin_contract_names; do
    _zunit_plugin_contract_parameter_is_observer_state "$_zunit_plugin_contract_name" && continue
    _zunit_plugin_contract_value=$(builtin typeset -p -- "$_zunit_plugin_contract_name" 2>/dev/null) || \
      _zunit_plugin_contract_value="${parameters[$_zunit_plugin_contract_name]}"
    _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
      "parameter:${_zunit_plugin_contract_name}" "$_zunit_plugin_contract_value"
  done
}

_zunit_plugin_contract_snapshot_alias_map() {
  builtin emulate -L zsh
  local _zunit_plugin_contract_snapshot=$1
  local _zunit_plugin_contract_kind=$2
  local _zunit_plugin_contract_name

  case $_zunit_plugin_contract_kind in
    regular)
      for _zunit_plugin_contract_name in ${(ok)aliases}; do
        _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
          "alias:regular:${_zunit_plugin_contract_name}" "${aliases[$_zunit_plugin_contract_name]}"
      done
      ;;
    global)
      for _zunit_plugin_contract_name in ${(ok)galiases}; do
        _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
          "alias:global:${_zunit_plugin_contract_name}" "${galiases[$_zunit_plugin_contract_name]}"
      done
      ;;
    suffix)
      for _zunit_plugin_contract_name in ${(ok)saliases}; do
        _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
          "alias:suffix:${_zunit_plugin_contract_name}" "${saliases[$_zunit_plugin_contract_name]}"
      done
      ;;
    disabled)
      for _zunit_plugin_contract_name in ${(ok)dis_aliases}; do
        _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
          "alias:disabled:${_zunit_plugin_contract_name}" "${dis_aliases[$_zunit_plugin_contract_name]}"
      done
      ;;
  esac
}

_zunit_plugin_contract_snapshot_options_modules() {
  builtin emulate -L zsh
  local _zunit_plugin_contract_snapshot=$1
  shift
  local _zunit_plugin_contract_name
  local -A _zunit_plugin_contract_caller_options

  _zunit_plugin_contract_caller_options=("$@")

  for _zunit_plugin_contract_name in ${(ok)_zunit_plugin_contract_caller_options}; do
    _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
      "option:${_zunit_plugin_contract_name}" \
      "${_zunit_plugin_contract_caller_options[$_zunit_plugin_contract_name]}"
  done
  for _zunit_plugin_contract_name in ${(ok)modules}; do
    _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
      "module:${_zunit_plugin_contract_name}" "${modules[$_zunit_plugin_contract_name]}"
  done
}

_zunit_plugin_contract_snapshot_paths_hooks() {
  builtin emulate -L zsh
  local _zunit_plugin_contract_snapshot=$1
  local _zunit_plugin_contract_hook _zunit_plugin_contract_parameter
  local _zunit_plugin_contract_value
  local -a _zunit_plugin_contract_hooks

  _zunit_plugin_contract_value=$(builtin typeset -p path 2>/dev/null)
  _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" "path:@order" "$_zunit_plugin_contract_value"
  _zunit_plugin_contract_value=$(builtin typeset -p fpath 2>/dev/null)
  _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" "fpath:@order" "$_zunit_plugin_contract_value"

  _zunit_plugin_contract_hooks=(chpwd periodic precmd preexec zshaddhistory zshexit zsh_directory_name)
  for _zunit_plugin_contract_hook in $_zunit_plugin_contract_hooks; do
    _zunit_plugin_contract_parameter="${_zunit_plugin_contract_hook}_functions"
    (( ${+parameters[$_zunit_plugin_contract_parameter]} )) || continue
    _zunit_plugin_contract_value=$(builtin typeset -p -- "$_zunit_plugin_contract_parameter" 2>/dev/null)
    _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
      "hook:${_zunit_plugin_contract_hook}" "$_zunit_plugin_contract_value"
  done
}

_zunit_plugin_contract_snapshot_widgets_bindings() {
  builtin emulate -L zsh
  local _zunit_plugin_contract_snapshot=$1
  local _zunit_plugin_contract_name _zunit_plugin_contract_value
  local -a _zunit_plugin_contract_keymaps

  for _zunit_plugin_contract_name in ${(ok)widgets}; do
    _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
      "widget:${_zunit_plugin_contract_name}" "${widgets[$_zunit_plugin_contract_name]}"
  done

  _zunit_plugin_contract_value=$(builtin bindkey -lL 2>/dev/null)
  _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
    "binding:@keymaps" "$_zunit_plugin_contract_value"
  _zunit_plugin_contract_keymaps=(${(ou)keymaps})
  for _zunit_plugin_contract_name in $_zunit_plugin_contract_keymaps; do
    _zunit_plugin_contract_value=$(builtin bindkey -M "$_zunit_plugin_contract_name" -L 2>/dev/null)
    _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
      "binding:${_zunit_plugin_contract_name}" "$_zunit_plugin_contract_value"
  done
}

_zunit_plugin_contract_snapshot_traps_styles() {
  builtin emulate -L zsh
  local _zunit_plugin_contract_snapshot=$1
  local _zunit_plugin_contract_traps=$2
  local _zunit_plugin_contract_line _zunit_plugin_contract_context
  local _zunit_plugin_contract_property _zunit_plugin_contract_signal
  local _zunit_plugin_contract_output
  local -a _zunit_plugin_contract_lines _zunit_plugin_contract_words

  _zunit_plugin_contract_output=$_zunit_plugin_contract_traps
  _zunit_plugin_contract_lines=("${(@f)_zunit_plugin_contract_output}")
  for _zunit_plugin_contract_line in $_zunit_plugin_contract_lines; do
    [[ -n $_zunit_plugin_contract_line ]] || continue
    _zunit_plugin_contract_words=(${(z)_zunit_plugin_contract_line})
    _zunit_plugin_contract_signal=${(Q)_zunit_plugin_contract_words[-1]}
    _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
      "trap:${_zunit_plugin_contract_signal}" "$_zunit_plugin_contract_line"
  done

  _zunit_plugin_contract_output=$(builtin zstyle -L)
  _zunit_plugin_contract_lines=("${(@f)_zunit_plugin_contract_output}")
  for _zunit_plugin_contract_line in $_zunit_plugin_contract_lines; do
    [[ -n $_zunit_plugin_contract_line ]] || continue
    _zunit_plugin_contract_words=(${(z)_zunit_plugin_contract_line})
    (( ${#_zunit_plugin_contract_words} >= 3 )) || continue
    if [[ ${(Q)_zunit_plugin_contract_words[2]} == -e ]]; then
      (( ${#_zunit_plugin_contract_words} >= 4 )) || continue
      _zunit_plugin_contract_context=${(Q)_zunit_plugin_contract_words[3]}
      _zunit_plugin_contract_property=${(Q)_zunit_plugin_contract_words[4]}
    else
      _zunit_plugin_contract_context=${(Q)_zunit_plugin_contract_words[2]}
      _zunit_plugin_contract_property=${(Q)_zunit_plugin_contract_words[3]}
    fi
    _zunit_plugin_contract_put "$_zunit_plugin_contract_snapshot" \
      "style:${_zunit_plugin_contract_context}:${_zunit_plugin_contract_property}" \
      "$_zunit_plugin_contract_line"
  done
}

zunit_plugin_contract_prime() {
  builtin emulate -L zsh
  builtin setopt local_options no_aliases

  builtin zmodload zsh/parameter || return 2
  builtin zmodload zsh/zutil || return 2
  builtin zmodload zsh/zle || return 2
  : ${#widgets} ${#keymaps}
  builtin bindkey -L >/dev/null 2>&1 || return 2
  builtin zstyle -L >/dev/null 2>&1 || return 2
  builtin trap >/dev/null 2>&1 || return 2
}

zunit_plugin_contract_snapshot() {
  # Capture state that `emulate -L` intentionally localizes before selecting a
  # deterministic implementation environment. The captured values, not the
  # observer's localized values, are recorded below.
  local _zunit_plugin_contract_trap_file
  _zunit_plugin_contract_trap_file=$(command mktemp \
    "${TMPDIR:-/tmp}/zunit-plugin-contract-traps.XXXXXX") || return 2
  builtin trap >| "$_zunit_plugin_contract_trap_file"
  local _zunit_plugin_contract_caller_traps=$(< "$_zunit_plugin_contract_trap_file")
  command rm -f -- "$_zunit_plugin_contract_trap_file"
  local -A _zunit_plugin_contract_caller_options
  _zunit_plugin_contract_caller_options=("${(@kv)options}")
  builtin emulate -L zsh
  builtin setopt local_options no_aliases extended_glob typeset_silent
  local _zunit_plugin_contract_snapshot=$1

  if [[ $_zunit_plugin_contract_snapshot != [A-Za-z][A-Za-z0-9_]# ]]; then
    print -u2 -r -- "Snapshot name must use portable ASCII letters, digits, and underscores"
    return 2
  fi
  if (( ${+_zunit_plugin_contract_snapshot_names[$_zunit_plugin_contract_snapshot]} )); then
    print -u2 -r -- "Snapshot already exists: $_zunit_plugin_contract_snapshot"
    return 2
  fi

  _zunit_plugin_contract_snapshot_functions "$_zunit_plugin_contract_snapshot"
  _zunit_plugin_contract_snapshot_parameters "$_zunit_plugin_contract_snapshot"
  _zunit_plugin_contract_snapshot_alias_map "$_zunit_plugin_contract_snapshot" regular
  _zunit_plugin_contract_snapshot_alias_map "$_zunit_plugin_contract_snapshot" global
  _zunit_plugin_contract_snapshot_alias_map "$_zunit_plugin_contract_snapshot" suffix
  _zunit_plugin_contract_snapshot_alias_map "$_zunit_plugin_contract_snapshot" disabled
  _zunit_plugin_contract_snapshot_options_modules "$_zunit_plugin_contract_snapshot" \
    "${(@kv)_zunit_plugin_contract_caller_options}"
  _zunit_plugin_contract_snapshot_paths_hooks "$_zunit_plugin_contract_snapshot"
  _zunit_plugin_contract_snapshot_widgets_bindings "$_zunit_plugin_contract_snapshot"
  _zunit_plugin_contract_snapshot_traps_styles "$_zunit_plugin_contract_snapshot" \
    "$_zunit_plugin_contract_caller_traps"
  _zunit_plugin_contract_snapshot_names[$_zunit_plugin_contract_snapshot]=1
}

_zunit_plugin_contract_require_snapshots() {
  builtin emulate -L zsh
  local _zunit_plugin_contract_snapshot

  for _zunit_plugin_contract_snapshot in "$@"; do
    if (( ! ${+_zunit_plugin_contract_snapshot_names[$_zunit_plugin_contract_snapshot]} )); then
      print -u2 -r -- "Unknown plugin contract snapshot: $_zunit_plugin_contract_snapshot"
      return 2
    fi
  done
}

_zunit_plugin_contract_collect_resources() {
  builtin emulate -L zsh
  builtin setopt local_options typeset_silent
  local _zunit_plugin_contract_snapshot _zunit_plugin_contract_key
  local _zunit_plugin_contract_prefix _zunit_plugin_contract_resource
  local -A _zunit_plugin_contract_seen

  _zunit_plugin_contract_reply=()
  for _zunit_plugin_contract_snapshot in "$@"; do
    _zunit_plugin_contract_prefix="${_zunit_plugin_contract_snapshot}:"
    for _zunit_plugin_contract_key in ${(k)_zunit_plugin_contract_snapshots}; do
      [[ $_zunit_plugin_contract_key == ${_zunit_plugin_contract_prefix}* ]] || continue
      _zunit_plugin_contract_resource=${_zunit_plugin_contract_key#$_zunit_plugin_contract_prefix}
      _zunit_plugin_contract_seen[$_zunit_plugin_contract_resource]=1
    done
  done
  _zunit_plugin_contract_reply=(${(ok)_zunit_plugin_contract_seen})
}

_zunit_plugin_contract_states_equal() {
  builtin emulate -L zsh
  local _zunit_plugin_contract_left=$1
  local _zunit_plugin_contract_right=$2
  local _zunit_plugin_contract_resource=$3
  local _zunit_plugin_contract_left_key="${_zunit_plugin_contract_left}:${_zunit_plugin_contract_resource}"
  local _zunit_plugin_contract_right_key="${_zunit_plugin_contract_right}:${_zunit_plugin_contract_resource}"
  local _zunit_plugin_contract_left_exists=${+_zunit_plugin_contract_snapshots[$_zunit_plugin_contract_left_key]}
  local _zunit_plugin_contract_right_exists=${+_zunit_plugin_contract_snapshots[$_zunit_plugin_contract_right_key]}

  (( _zunit_plugin_contract_left_exists == _zunit_plugin_contract_right_exists )) || return 1
  (( _zunit_plugin_contract_left_exists == 0 )) && return 0
  [[ ${_zunit_plugin_contract_snapshots[$_zunit_plugin_contract_left_key]} == \
    ${_zunit_plugin_contract_snapshots[$_zunit_plugin_contract_right_key]} ]]
}

_zunit_plugin_contract_report() {
  builtin emulate -L zsh
  local _zunit_plugin_contract_heading=$1
  shift
  local _zunit_plugin_contract_resource
  local -a _zunit_plugin_contract_resources

  _zunit_plugin_contract_resources=("$@")
  print -r -- "$_zunit_plugin_contract_heading"
  for _zunit_plugin_contract_resource in ${(o)_zunit_plugin_contract_resources}; do
    print -r -- "  $_zunit_plugin_contract_resource"
  done
}

_zunit_assert_plugin_load_surface() {
  builtin emulate -L zsh
  builtin setopt local_options typeset_silent
  local _zunit_plugin_contract_before=$1
  local _zunit_plugin_contract_after=$2
  shift 2
  local _zunit_plugin_contract_resource
  local -A _zunit_plugin_contract_allowed
  local -a _zunit_plugin_contract_unexpected

  _zunit_plugin_contract_require_snapshots \
    "$_zunit_plugin_contract_before" "$_zunit_plugin_contract_after" || return $?
  for _zunit_plugin_contract_resource in "$@"; do
    _zunit_plugin_contract_allowed[$_zunit_plugin_contract_resource]=1
  done
  _zunit_plugin_contract_collect_resources \
    "$_zunit_plugin_contract_before" "$_zunit_plugin_contract_after"
  for _zunit_plugin_contract_resource in $_zunit_plugin_contract_reply; do
    _zunit_plugin_contract_states_equal \
      "$_zunit_plugin_contract_before" "$_zunit_plugin_contract_after" \
      "$_zunit_plugin_contract_resource" && continue
    (( ${+_zunit_plugin_contract_allowed[$_zunit_plugin_contract_resource]} )) && continue
    _zunit_plugin_contract_unexpected+=("$_zunit_plugin_contract_resource")
  done
  (( ${#_zunit_plugin_contract_unexpected} == 0 )) && return 0
  _zunit_plugin_contract_report "Unexpected plugin load surface:" \
    "${_zunit_plugin_contract_unexpected[@]}"
  return 1
}

_zunit_assert_plugin_restored() {
  builtin emulate -L zsh
  builtin setopt local_options typeset_silent
  local _zunit_plugin_contract_before=$1
  local _zunit_plugin_contract_after=$2
  local _zunit_plugin_contract_resource
  local -a _zunit_plugin_contract_changed

  _zunit_plugin_contract_require_snapshots \
    "$_zunit_plugin_contract_before" "$_zunit_plugin_contract_after" || return $?
  _zunit_plugin_contract_collect_resources \
    "$_zunit_plugin_contract_before" "$_zunit_plugin_contract_after"
  for _zunit_plugin_contract_resource in $_zunit_plugin_contract_reply; do
    _zunit_plugin_contract_states_equal \
      "$_zunit_plugin_contract_before" "$_zunit_plugin_contract_after" \
      "$_zunit_plugin_contract_resource" || \
      _zunit_plugin_contract_changed+=("$_zunit_plugin_contract_resource")
  done
  (( ${#_zunit_plugin_contract_changed} == 0 )) && return 0
  _zunit_plugin_contract_report "Plugin did not restore the pre-load state:" \
    "${_zunit_plugin_contract_changed[@]}"
  return 1
}

_zunit_assert_plugin_unloaded() {
  builtin emulate -L zsh
  builtin setopt local_options typeset_silent
  local _zunit_plugin_contract_before=$1
  local _zunit_plugin_contract_loaded=$2
  local _zunit_plugin_contract_user=$3
  local _zunit_plugin_contract_after=$4
  local _zunit_plugin_contract_resource _zunit_plugin_contract_expected
  local -a _zunit_plugin_contract_changed

  _zunit_plugin_contract_require_snapshots \
    "$_zunit_plugin_contract_before" "$_zunit_plugin_contract_loaded" \
    "$_zunit_plugin_contract_user" "$_zunit_plugin_contract_after" || return $?
  _zunit_plugin_contract_collect_resources \
    "$_zunit_plugin_contract_before" "$_zunit_plugin_contract_loaded" \
    "$_zunit_plugin_contract_user" "$_zunit_plugin_contract_after"

  for _zunit_plugin_contract_resource in $_zunit_plugin_contract_reply; do
    if _zunit_plugin_contract_states_equal \
      "$_zunit_plugin_contract_loaded" "$_zunit_plugin_contract_user" \
      "$_zunit_plugin_contract_resource"; then
      _zunit_plugin_contract_expected=$_zunit_plugin_contract_before
    else
      _zunit_plugin_contract_expected=$_zunit_plugin_contract_user
    fi
    _zunit_plugin_contract_states_equal \
      "$_zunit_plugin_contract_expected" "$_zunit_plugin_contract_after" \
      "$_zunit_plugin_contract_resource" || \
      _zunit_plugin_contract_changed+=("$_zunit_plugin_contract_resource")
  done
  (( ${#_zunit_plugin_contract_changed} == 0 )) && return 0
  _zunit_plugin_contract_report "Plugin unload violated resource ownership:" \
    "${_zunit_plugin_contract_changed[@]}"
  return 1
}
