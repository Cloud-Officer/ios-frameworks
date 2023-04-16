#!/usr/bin/env bash
set -e

# shellcheck source=/dev/null
. "${SCRIPTS_DIR}/environment.sh"

cd "${SOURCES_DIR}/${3}"
git clean -xdf
git reset --hard
git checkout "${2}"
python3 setup.py bdist
make-frameworks.sh --bundle-identifier "org.pydata" --bundle-name "${1}" --bundle-version "${2}" --input-dir ./build/lib*/"${1}" --output-dir "${FRAMEWORKS_DIR}"
cp -r build/lib*/* "${SITE_PACKAGES_DIR}/${1}"
