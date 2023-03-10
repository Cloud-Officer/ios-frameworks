#!/usr/bin/env bash
set -e

# shellcheck source=/dev/null
. "${SCRIPTS_DIR}/environment.sh"

export LDFLAGS="-L'${FRAMEWORKS_DIR}'"
export DOCKER_DEFAULT_PLATFORM=linux/amd64

docker stop flang || true
docker rm flang  || true
docker run -d --name flang -v "${BASE_DIR}/fortran-ios/share:/root/host" -v /Users:/Users -v /var/folders:/var/folders -it ubuntu

cd "${SOURCES_DIR}/${3}"
git clean -xdf
git reset --hard
git checkout "${2}"
cp -f "${BASE_DIR}/scipy/ni_morphology.c" scipy/ndimage/src/
cp -f "${BASE_DIR}/scipy/site.cfg" .
sed -i '' "s!^library_dirs = .*!library_dirs = $(brew --prefix openblas)/lib!g" site.cfg
sed -i '' "s!^include_dirs = .*!include_dirs = $(brew --prefix openblas)/include!g" site.cfg
sed -i '' "s!^runtime_library_dirs = .*!runtime_library_dirs = $(brew --prefix openblas)/lib!g" site.cfg
git submodule update --init
python3 setup.py bdist --force
cp -f scipy/misc/*.dat build/lib*/scipy/misc
make_frameworks.py "${1}"
cp build/temp*iphoneos*/*.a "${FRAMEWORKS_DIR}"
cp -r build/lib*/* "${SITE_PACKAGES_DIR}/${1}"

docker stop flang
docker rm flang
