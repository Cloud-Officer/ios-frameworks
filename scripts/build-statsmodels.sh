#!/usr/bin/env bash
set -e

# shellcheck source=/dev/null
. "${SCRIPTS_DIR}/environment.sh"

export LDFLAGS="-L'${FRAMEWORKS_DIR}'"

cd "${SOURCES_DIR}/${3}"
git clean -xdf
git reset --hard
git checkout "${2}"
python3 setup.py bdist
make-statsmodels-dylibs.py
make_frameworks.py "${1}"
cp -r build/lib*/* "${SITE_PACKAGES_DIR}/${1}"
