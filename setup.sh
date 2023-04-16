#!/usr/bin/env bash
set -e

# settings

# Python package name, package version tag, package name alias

# shellcheck disable=SC2034
numpy=("numpy" "v1.24.2" "numpy")
# shellcheck disable=SC2034
cython=("Cython" "0.29.33" "Cython")
# shellcheck disable=SC2034
pandas=("pandas" "v1.5.3" "pandas")
# shellcheck disable=SC2034
pyemd=("pyemd" "1.0.0" "pyemd")
# shellcheck disable=SC2034
pywavelets=("pywt" "v1.4.1" "PyWavelets")
# shellcheck disable=SC2034
scikit_image=("skimage" "v0.19.3" "scikit-image")
# shellcheck disable=SC2034
scikit_learn=("sklearn" "1.2.2" "scikit-learn")
# shellcheck disable=SC2034
scipy=("scipy" "v1.10.1" "scipy")
# shellcheck disable=SC2034
statsmodels=("statsmodels" "v0.13.5" "statsmodels")

packages=(
  numpy[@]
  scikit_learn[@]
  scipy[@]
)

PYTHON_APPLE_SUPPORT_VERSION="3.10"
PYTHON_APPLE_SUPPORT_BUILD="b6"
BASE_DIR="$(pwd)"
export BASE_DIR
export FRAMEWORKS_DIR="${BASE_DIR}/frameworks"
export PYTHON_DIR="${BASE_DIR}/python${PYTHON_APPLE_SUPPORT_VERSION}"
export SCRIPTS_DIR="${BASE_DIR}/scripts"
export SITE_PACKAGES_DIR="${PYTHON_DIR}/site-packages"
export SOURCES_DIR="${BASE_DIR}/sources"
export VERSION_FILE="${BASE_DIR}/versions.txt"
PATH="${BASE_DIR}/bin:${PATH}"

# build dependencies

if ! brew list miniconda &>/dev/null; then
    brew install miniconda
    echo "Please configure the base conda environment by running 'conda init <SHELL_NAME>' and then 'conda install -y python=${PYTHON_APPLE_SUPPORT_VERSION}' to create a base environment."
    exit 1
fi

if ! brew list docker &>/dev/null; then
    brew install docker
fi

if ! brew list llvm &>/dev/null; then
    brew install llvm
fi

if ! which llc &>/dev/null; then
    echo "Please add homebrew llvm to your path (see brew info llvm)."
    exit 1
fi

if ! brew list pip-tools &>/dev/null; then
    brew install pip-tools
fi

if ! brew list openblas &>/dev/null; then
    brew install openblas
fi

if ! brew list xxhash &>/dev/null; then
    brew install xxhash
fi

# conda environment

CONDA_ENV_DIR="python-ios"

eval "$(command conda 'shell.bash' 'hook')"
conda activate base
rm -rf "$(conda info | grep 'envs directories' | awk -F ':' '{ print $2 }' | sed -e 's/^[[:space:]]*//')/${CONDA_ENV_DIR:?}"
conda create -y --name "${CONDA_ENV_DIR}" "python==${PYTHON_APPLE_SUPPORT_VERSION}"
conda activate "${CONDA_ENV_DIR}"
sed -i '' "s/^${numpy[0]}.*/${numpy[0]}==${numpy[1]/v/}/g" requirements.in
sed -i '' "s/^${scipy[0]}.*/${scipy[0]}==${scipy[1]/v/}/g" requirements.in
pip-compile  --resolver=backtracking
pip3 install -r requirements.txt

# python apple support

PYTHON_APPLE_SUPPORT_DIR="${BASE_DIR}/python-apple-support"

rm -rf "${FRAMEWORKS_DIR}" "${PYTHON_APPLE_SUPPORT_DIR}" "${PYTHON_DIR}" "${VERSION_FILE}" Python-*.zip
mkdir "${FRAMEWORKS_DIR}" "${PYTHON_APPLE_SUPPORT_DIR}"
pushd "${PYTHON_APPLE_SUPPORT_DIR}"
curl --silent --location "https://github.com/beeware/Python-Apple-support/releases/download/${PYTHON_APPLE_SUPPORT_VERSION}-${PYTHON_APPLE_SUPPORT_BUILD}/Python-${PYTHON_APPLE_SUPPORT_VERSION}-iOS-support.${PYTHON_APPLE_SUPPORT_BUILD}.tar.gz" --output python-apple-support.tar.gz
tar -xzf python-apple-support.tar.gz
mv python-stdlib "${PYTHON_DIR}"
mv Python.xcframework "${FRAMEWORKS_DIR}/python.xcframework"
mkdir -p "${FRAMEWORKS_DIR}/Python.xcframework/ios-arm64/Modules" "${FRAMEWORKS_DIR}/Python.xcframework/ios-arm64_x86_64-simulator/Modules"
cp "${BASE_DIR}/module.modulemap" "${FRAMEWORKS_DIR}/Python.xcframework/ios-arm64/Modules"
cp "${BASE_DIR}/module.modulemap" "${FRAMEWORKS_DIR}/Python.xcframework/ios-arm64_x86_64-simulator/Modules"
mv VERSIONS "${VERSION_FILE}"
echo "---------------------" >> "${VERSION_FILE}"
popd
mkdir -p "${PYTHON_DIR}/site-packages"
rm -rf "${PYTHON_APPLE_SUPPORT_DIR}" "${PYTHON_DIR}/lib-dynload"/*-iphonesimulator.so
make-frameworks.sh --bundle-identifier "org" --bundle-name "python" --bundle-version "${PYTHON_APPLE_SUPPORT_VERSION}" --input-dir "${PYTHON_DIR}/lib-dynload" --output-dir "${FRAMEWORKS_DIR}"
rm -rf "${PYTHON_DIR}/lib-dynload"

# pip packages

pushd "${BASE_DIR}/site-packages"
pip-compile  --resolver=backtracking
sed -i '' "s/^# pip/pip/g" requirements.txt
sed -i '' "s/^# setuptools/setuptools/g" requirements.txt
popd

pushd "${SITE_PACKAGES_DIR}"
python3 -m pip install --no-deps -r "${BASE_DIR}/site-packages/requirements.txt" -t .
rm pip/__init__.py setuptools/_distutils/command/build_ext.py
cp "${BASE_DIR}/site-packages/__init__.py" pip/__init__.py
cp "${BASE_DIR}/site-packages/build_ext.py" setuptools/_distutils/command/build_ext.py
find . -type d -name "__pycache__" -prune -exec rm -rf {} \;
popd

# openblas

LAPACK_VERSION="1.4"

curl --silent --location "https://github.com/ColdGrub1384/lapack-ios/releases/download/v${LAPACK_VERSION}/lapack-ios.zip" --output lapack-ios.zip
unzip -q lapack-ios.zip
mv lapack-ios/openblas.framework "${FRAMEWORKS_DIR}"
mv lapack-ios/lapack.framework "${FRAMEWORKS_DIR}/scipy-deps.framework"
mv lapack-ios/ios_flang_runtime.framework "${FRAMEWORKS_DIR}"
cp "${FRAMEWORKS_DIR}/openblas.framework/openblas" "${FRAMEWORKS_DIR}/libopenblas.dylib"
cp "${FRAMEWORKS_DIR}/ios_flang_runtime.framework/ios_flang_runtime" "${FRAMEWORKS_DIR}/libgfortran.dylib"
rm -rf __MACOSX lapack-ios lapack-ios.zip

# setup docker for fortran/flang

if ! docker info &>/dev/null; then
  echo "Docker daemon not running!"
  exit 1
fi

export DOCKER_DEFAULT_PLATFORM=linux/amd64
# shellcheck disable=SC2048,SC2086
DOCKER_BUILDKIT=1 docker build -t flang --compress . $*
docker stop flang &>/dev/null || true
docker rm flang &>/dev/null || true
docker run -d --name flang -v "${BASE_DIR}/share:/root/host" -v /Users:/Users -v /var/folders:/var/folders -it flang

# build packages

pushd "${SCRIPTS_DIR}"

count=${#packages[@]}

for ((i = 0; i < count; i++)); do
  package_name="${!packages[i]:0:1}"
  package_version="${!packages[i]:1:1}"
  package_alias="${!packages[i]:2:1}"
  package_folder=$(echo "${package_name}" | tr '[:upper:]' '[:lower:]')
  sed -i '' "s/^${package_alias}.*/${package_alias}==${package_version/v/}/g" "${SOURCES_DIR}/requirements.txt"
  echo "${package_alias}: ${package_version/v/}" >> "${VERSION_FILE}"
  printf "\n\n*** Building %s ***\n" "${package_name}"
  ./"build-${package_folder}.sh" "${package_name}" "${package_version}" "${package_folder}"

  if ! ls "${FRAMEWORKS_DIR}"/*"${package_name}"* &>/dev/null; then
      echo "Missing ${package_name} in folder ${FRAMEWORKS_DIR} !"
      exit 1
  fi

  if ! [ -d "${SITE_PACKAGES_DIR}/${package_name}" ]; then
      echo "Missing ${package_name} in folder ${SITE_PACKAGES_DIR} !"
      exit 1
  fi
done

popd

find "${SOURCES_DIR}" -name '*.egg-info' -exec cp -rf {} "${SITE_PACKAGES_DIR}" \;
find "${SITE_PACKAGES_DIR}" -name '*.so' -delete

# compress output

zip --quiet --recurse-paths "Python-$(grep Python versions.txt | awk -F':' '{ print $2 }' | sed 's/ //g')-iOS-Libraries-$(xxhsum versions.txt | awk '{ print $1 }').zip" LICENSE versions.txt frameworks "python${PYTHON_APPLE_SUPPORT_VERSION}"

# cleaning

conda activate base
echo "${0##*/} completed successfully."
