#!/usr/bin/env bash
set -ex

source "${SCRIPTS_DIR}/environment.sh"

export NPY_BLAS_ORDER=""
export NPY_LAPACK_ORDER=""

cd "${SOURCES_DIR}/${3}"
git clean -xdf
git reset --hard
git checkout "${2}"
cp -f "${BASE_DIR}/.numpy/npy_config.h" numpy/core/src/common/
cp -f "${BASE_DIR}/.numpy/npy_common.h" numpy/core/include/numpy/
cp -f "${BASE_DIR}/.numpy/site.cfg" .
sed -i '' "s!^library_dirs = .*!library_dirs = $(brew --prefix openblas)/lib!g" site.cfg
sed -i '' "s!^include_dirs = .*!include_dirs = $(brew --prefix openblas)/include!g" site.cfg
sed -i '' "s!^runtime_library_dirs = .*!runtime_library_dirs = $(brew --prefix openblas)/lib!g" site.cfg
python3 setup.py bdist --force
make_frameworks.py "${1}"
cp build/temp*iphoneos*/*.a "${FRAMEWORKS_DIR}"
cp -r build/lib*iphoneos*/* "${SITE_PACKAGES_DIR}/${1}"
