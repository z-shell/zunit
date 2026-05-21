#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Register the plugin's directory
typeset -gA Plugins
Plugins[zunit]="${0:h}"

# Add to fpath if not already handled
if [[ $PMSPEC != *f* ]]; then
  fpath+=( "${0:h}/functions" )
fi

setopt extendedglob typesetsilent

######################
# Main zunit process #
######################

###
# Output usage information and exit
###
function _zunit_usage() {
  echo "$(_zunit_color yellow 'Usage:')"
  echo "  zunit [options] [command] [tests...]"
  echo
  echo "$(_zunit_color yellow 'Commands:')"
  echo "  init               Bootstrap zunit in a new project"
  echo "  run [tests...]     Run tests"
  echo
  echo "$(_zunit_color yellow 'Options:')"
  echo "  -h, --help         Output help text and exit"
  echo "  -v, --version      Output version information and exit"
  echo "  -f, --fail-fast    Stop the test runner immediately after the first failure"
  echo "  -t, --tap          Output results in a TAP compatible format"
  echo "      --verbose      Prints full output from each test"
  echo "      --output-text  Print results to a text log, in TAP compatible format"
  echo "      --output-html  Print results to a HTML page"
  echo "      --allow-risky  Suppress warnings generated for risky tests"
  echo "      --time-limit   Set a time limit in seconds for each test"
}

###
# Output the version number
###
function _zunit_version() {
  echo '0.8.2'
}

###
# The main zunit process
###
function _zunit() {
  local help version ctx="$1" missing_dependencies=0 missing_config=1

  if [[ -f .zunit.zsh ]]; then
    if ! source .zunit.zsh 2>/dev/null; then
      echo "\033[0;31mFailed to source .zunit.zsh config file\033[0;m" >&2
      exit 1
    fi
    [[ -n $ZUNIT_TESTS_DIR ]] && zunit_config_directories_tests="$ZUNIT_TESTS_DIR"
    [[ -n $ZUNIT_OUTPUT_DIR ]] && zunit_config_directories_output="$ZUNIT_OUTPUT_DIR"
    [[ -n $ZUNIT_SUPPORT_DIR ]] && zunit_config_directories_support="$ZUNIT_SUPPORT_DIR"
    [[ -n $ZUNIT_FAIL_FAST ]] && zunit_config_fail_fast="$ZUNIT_FAIL_FAST"
    [[ -n $ZUNIT_ALLOW_RISKY ]] && zunit_config_allow_risky="$ZUNIT_ALLOW_RISKY"
    [[ -n $ZUNIT_TIME_LIMIT ]] && zunit_config_time_limit="$ZUNIT_TIME_LIMIT"
    [[ -n $ZUNIT_TAP ]] && zunit_config_tap="$ZUNIT_TAP"
    [[ -n $ZUNIT_VERBOSE ]] && zunit_config_verbose="$ZUNIT_VERBOSE"
    missing_config=0
  elif [[ -f .zunit.yml ]]; then
    # Try and parse the config file within a subprocess,
    # to avoid killing the main thread
    $(eval $(_zunit_parse_yaml .zunit.yml 'zunit_config_') >/dev/null 2>&1)
    if [[ $? -eq 0 ]]; then
      # The config file was parsed successfully, so we Perform the parse
      # again, but this time on the main thread so that the config vars are
      # loaded into the enviroment
      eval $(_zunit_parse_yaml .zunit.yml 'zunit_config_') >/dev/null 2>&1
      missing_config=0
    else
      # The config file failed to parse, so we report this to the user and exit
      echo "\033[0;31mFailed to parse config file\033[0;m" >&2
      exit 1
    fi
  fi

  zparseopts -D -E \
    h=help -help=help \
    v=version -version=version

  # If the version option is passed,
  # output version information and exit
  if [[ -n $version ]]; then
    _zunit_version
    exit 0
  fi

  # Check for the 'revolver' dependency only when a command may actually run
  # tests. Introspection and bootstrap commands should remain usable before
  # dependencies are installed.
  if [[ -z $help && $ctx != init ]]; then
    if ! (( $+functions[_zunit_revolver] )); then
      echo "\033[0;31mInternal error: _zunit_revolver function missing. Try rebuilding zunit.\033[0;m" >&2
      exit 1
    fi
  fi

  # Check which command has been passed, and run it. If the command
  # is not recognised, then we'll assume it's a test file and pass
  # it to `zunit run`, since that will catch it if it's not a valid file
  case "$ctx" in
    init )
      # If the help option is passed,
      # output usage information and exit
      if [[ -n $help ]]; then
        _zunit_init_usage
        exit 0
      fi

      _zunit_init "${(@)@:2}"
      ;;
    run )
      # If the help option is passed,
      # output usage information and exit
      if [[ -n $help ]]; then
        _zunit_run_usage
        exit 0
      fi

      _zunit_run "${(@)@:2}"
      ;;
    * )
      # If the help option is passed,
      # output usage information and exit
      if [[ -n $help ]]; then
        _zunit_usage
        exit 0
      fi

      _zunit_run "$@"
      ;;
  esac
}

_zunit "$@"
