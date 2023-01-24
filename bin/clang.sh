#!/usr/bin/env bash
set -ex

iosxcrun.py --sdk iphoneos clang -arch arm64 ${@}
