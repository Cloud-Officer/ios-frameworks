#!/usr/bin/env bash

cd /root/host || exit
dpkg -i --force-depends deb/*.deb &>/dev/null || true
export PATH="/root/host/flang/bin:${PATH}"
cd "${1}" || exit
flang "${@:2}"
