#!/usr/bin/env bash
set -e

# shellcheck source=/dev/null
. "${SCRIPTS_DIR}/environment.sh"

export PYTHON_CROSSENV=1
export PYODIDE_PACKAGE_ABI=1

cd "${SOURCES_DIR}/${3}"
git clean -xdf
git reset --hard
git checkout "${2}"
python3 setup.py bdist
rm -rf build/lib*/skimage/data
cp -r skimage/data build/lib*/skimage
cp skimage/feature/*.txt  build/lib*/skimage
cp -r build/lib*/skimage "${SITE_PACKAGES_DIR}"
