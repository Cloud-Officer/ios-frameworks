#!/usr/bin/env bash
set -ex

source "${SCRIPTS_DIR}/environment.sh"

export NPY_BLAS_ORDER=""
export NPY_LAPACK_ORDER=""

cd "${SOURCES_DIR}/${3}"
git clean -xdf
git reset --hard
git checkout "${2}"
python3 setup.py bdist --force
make_frameworks.py "${1}"
cp -r build/lib*/* "${SITE_PACKAGES_DIR}/${1}"
