#!/usr/bin/env bash

alias python3=python3.10

SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
XCRUN="iosxcrun"
NUMPY1="${SOURCES_DIR}/numpy/numpy/core/include"
NUMPY2="${SOURCES_DIR}/numpy/build/src.iphoneos-arm64-3.10/numpy/core/include/numpy"

export PATH="${BASE_DIR}/bin:${PATH}"
export _PYTHON_HOST_PLATFORM=iphoneos-arm64
export IPHONEOS_DEPLOYMENT_TARGET=12.0
export LD="${XCRUN}"
export CC="${XCRUN} --sdk iphoneos clang -arch arm64 -mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
export CXX="${XCRUN} --sdk iphoneos clang -arch arm64 -lstdc++ -mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
export LDFLAGS="-arch arm64 -mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET} -isysroot ${SDK}"
export CPPFLAGS="-arch arm64 -isysroot ${SDK} -UHAVE_FEATURES_H -I'${NUMPY1}' -I'${NUMPY2}' -Wno-unknown-attributes -Wno-unused-function -Wno-unused-variable -Wno-unknown-warning-option -Wno-unused-but-set-variable -Wno-unreachable-code-fallthrough -Wno-undefined-internal -Wno-implicit-function-declaration -Wno-unreachable-code -Wno-sometimes-uninitialized -Wno-sign-compare -Wno-incompatible-pointer-types"
export CFLAGS="-arch arm64 -isysroot ${SDK} -UHAVE_FEATURES_H -I'${NUMPY1}' -I'${NUMPY2}' -Wno-unknown-attributes -Wno-unused-function -Wno-unused-variable -Wno-unknown-warning-option -Wno-unused-but-set-variable -Wno-unreachable-code-fallthrough -Wno-undefined-internal -Wno-implicit-function-declaration -Wno-unreachable-code -Wno-sometimes-uninitialized -Wno-sign-compare -Wno-incompatible-pointer-types"
export ARCHFLAGS="-arch arm64"

parse_command_line()
{
  local append argument default_value help_text line required variable_name
  printf "# default values\n\n"

  while read -r line; do
    IFS=, read -r argument variable_name default_value required append help_text <<< "${line}"

    if [ "${default_value}" != "-1" ]; then
      printf "%s=\"%s\"\n" "${variable_name}" "${default_value}"
    fi
  done < <(awk '/^#\[/,/^#\]/ { print }' <"${0}" | grep -v '\[' | grep -v '\]' | tr -d '#')

  printf "\n# parse command line\n\npositional=()\n\n"
  printf "while [[ \$# -gt 0 ]]; do\n"
  printf "  key=\"\${1}\"\n\n"
  printf "  case \"\${key}\" in\n"
  printf "  --help)\n"
  printf "  echo \"Usage: \${0##*/} options\n"
  printf "\n    options\n"

  while read -r line; do
    IFS=, read -r argument variable_name default_value required append help_text <<< "${line}"
    printf "            %s %s\n" "${argument}" "${help_text}"
  done < <(awk '/^#\[/,/^#\]/ { print }' <"${0}" | grep -v '\[' | grep -v '\]' | tr -d '#')

  printf "\"\n    exit 0\n    ;;\n\n"

  while read -r line; do
    IFS=, read -r argument variable_name default_value required append help_text <<< "${line}"

    if [ "${append}" == "1" ]; then
      printf "  %s)\n    %s=\"\${%s} %s \${2}\"\n    shift\n    shift\n    ;;\n\n" "${argument}" "${variable_name}" "${variable_name}" "${argument}"
    else
      printf "  %s)\n    %s=\"\${2}\"\n    shift\n    shift\n    ;;\n\n" "${argument}" "${variable_name}"
    fi
  done < <(awk '/^#\[/,/^#\]/ { print }' <"${0}" | grep -v '\[' | grep -v '\]' | tr -d '#')

  printf "  *)\n    positional+=(\"\${1}\")\n    shift\n    ;;\n  esac\ndone\n\nset -- \"\${positional[@]}\"\n\n"

  while read -r line; do
    IFS=, read -r argument variable_name default_value required append help_text <<< "${line}"

    if [ "${required}" == "1" ]; then
      printf "if [ -z \"\${%s}\" ]; then\n  echo \"Error: %s required !\"\n  exit 1\nfi\n\n" "${variable_name}" "${argument}"
    fi
  done < <(awk '/^#\[/,/^#\]/ { print }' <"${0}" | grep -v '\[' | grep -v '\]' | tr -d '#')
}
