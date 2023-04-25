#!/usr/bin/env bash
set -e

# shellcheck source=/dev/null
. "${SCRIPTS_DIR}/environment.sh"

export PYTHON_CROSSENV=1
export PYODIDE_PACKAGE_ABI=1
export SKLEARN_NO_OPENMP=TRUE

cd "${SOURCES_DIR}/${3}"
git clean -xdf
git reset --hard
git checkout "${2}"
python3 setup.py bdist
find ./build/lib*/"${1}" -name '*-darwin.so' -exec sh -c 'mv "$0" "${0/darwin.so/iphoneos.dylib}"' {} \;
make-frameworks.sh --bundle-identifier "org.image" --bundle-name "${1}" --bundle-version "${2}" --input-dir ./build/lib*/"${1}" --output-dir "${FRAMEWORKS_DIR}"
cp -r build/lib*/* "${SITE_PACKAGES_DIR}/${1}"
cp -r sklearn/datasets/data "${SITE_PACKAGES_DIR}/${1}/datasets"
cp -r sklearn/datasets/descr "${SITE_PACKAGES_DIR}/${1}/datasets"
cp -r sklearn/datasets/images "${SITE_PACKAGES_DIR}/${1}/datasets"
