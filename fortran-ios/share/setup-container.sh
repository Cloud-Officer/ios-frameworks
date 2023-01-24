#!/usr/bin/env bash
set -ex

cd /root/host
dpkg -i --force-depends deb/*.deb
export PATH="/root/host/flang/bin:${PATH}"
cd ${1}
flang "${@:2}"
