#!/usr/bin/env bash
set -e

# shellcheck disable=SC2068
iosxcrun.py --sdk iphoneos clang -arch arm64 ${@}
