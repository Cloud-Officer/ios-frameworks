#!/usr/bin/env bash
set -ex

source "${SCRIPTS_DIR}/environment.sh"

cd "${SOURCES_DIR}/${3}"
git clean -xdf
git reset --hard
git checkout "${2}"
python3 setup.py bdist_wheel
make_frameworks.py "${1}"
cp -r build/lib*/Cython "${SITE_PACKAGES_DIR}/${1}"
cp -r build/lib*/cython.py "${SITE_PACKAGES_DIR}/cython.py"
cp -r build/lib*/pyximport "${SITE_PACKAGES_DIR}/pyximport"
