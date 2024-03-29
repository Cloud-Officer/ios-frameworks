#!/usr/bin/env bash
set -e

# shellcheck source=/dev/null
. "${SCRIPTS_DIR}/environment.sh"

cd "${SOURCES_DIR}/${3}"

if ! [ -d "build" ]; then
  git clean -xdf
  git reset --hard
  git checkout "${2}"
  python3 setup.py bdist_wheel
  find ./build/lib*/"${1}" -name '*-darwin.so' -exec sh -c 'mv "$0" "${0/darwin.so/iphoneos.dylib}"' {} \;
fi

make-frameworks.sh --bundle-identifier "org" --bundle-name "${1}" --bundle-version "${2}" --input-dir ./build/lib*/"${1}" --output-dir "${FRAMEWORKS_DIR}"
cp -r build/lib*/Cython "${SITE_PACKAGES_DIR}/${1}"
cp -r build/lib*/cython.py "${SITE_PACKAGES_DIR}/cython.py"
cp -r build/lib*/pyximport "${SITE_PACKAGES_DIR}/pyximport"
