#!/usr/bin/env bash
set -ex

source "${SCRIPTS_DIR}/environment.sh"

cd "${SOURCES_DIR}/${3}"
git clean -xdf
git reset --hard
git checkout "${2}"
python3 setup.py bdist
make_frameworks.py "${1}"
cp -r build/lib*/pyemd "${SITE_PACKAGES_DIR}"
