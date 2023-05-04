#!/usr/bin/env bash
set -e

# shellcheck source=/dev/null
. "${SCRIPTS_DIR}/environment.sh"

export LDFLAGS="-L'${FRAMEWORKS_DIR}'"

cd "${SOURCES_DIR}/${3}"

if ! [ -d "build" ]; then
  git clean -xdf
  git reset --hard
  git checkout "${2}"
  python3 setup.py bdist

  src_dir="build/temp.iphoneos-arm64-3.8"
  dst_dir="build/lib.iphoneos-arm64-3.8"

  find "${src_dir}" -type f -name "*.o" | while read -r file; do
    rel_path="${file#"${src_dir}"/statsmodels/}"
    out_path="${dst_dir}/statsmodels/${rel_path/.o/.cpython-38-darwin.so}"
    "${CC}" "${LDFLAGS}" -undefined dynamic_lookup -bundle "${file}" -o "${out_path}"
  done
fi

find ./build/lib*/"${1}" -name '*-darwin.so' -exec sh -c 'mv "$0" "${0/darwin.so/iphoneos.dylib}"' {} \;
make-frameworks.sh --bundle-identifier "org" --bundle-name "${1}" --bundle-version "${2}" --input-dir ./build/lib*/"${1}" --output-dir "${FRAMEWORKS_DIR}"
cp -r build/lib*/* "${SITE_PACKAGES_DIR}/${1}"
