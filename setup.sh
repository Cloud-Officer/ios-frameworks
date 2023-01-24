#!/usr/bin/env bash
set -ex

# settings

# Python package name, package version tag, package name alias

# shellcheck disable=SC2034
numpy=("numpy" "v1.22.3" "numpy")
# shellcheck disable=SC2034
cython=("Cython" "0.29.33" "Cython")
# shellcheck disable=SC2034
gensim=("gensim" "4.3.0" "gensim")
# shellcheck disable=SC2034
pandas=("pandas" "v1.5.3" "pandas")
# shellcheck disable=SC2034
pyemd=("pyemd" "0.5.1" "pyemd")
# shellcheck disable=SC2034
pywavelets=("pywt" "v1.4.1" "PyWavelets")
# shellcheck disable=SC2034
scikit_image=("skimage" "v0.19.3" "scikit-image")
# shellcheck disable=SC2034
scikit_learn=("sklearn" "1.2.0" "scikit-learn")
# shellcheck disable=SC2034
scipy=("scipy" "v1.10.0" "scipy")
# shellcheck disable=SC2034
statsmodels=("statsmodels" "v0.13.5" "statsmodels")

packages=(
#  numpy[@]
#  cython[@]
#  gensim[@]
#  pandas[@]
#  pyemd[@]
#  pywavelets[@]
#  scikit_image[@]
#  scikit_learn[@]
  scipy[@]
#  statsmodels[@]
)

export BASE_DIR="$(pwd)"
export FRAMEWORKS_DIR="${BASE_DIR}/frameworks"
export PYTHON_DIR="${BASE_DIR}/python3.10"
export SCRIPTS_DIR="${BASE_DIR}/scripts"
export SITE_PACKAGES_DIR="${PYTHON_DIR}/site-packages"
export SOURCES_DIR="${BASE_DIR}/sources"
export FORTRAN_DIR="${BASE_DIR}/fortran-ios"
export VERSION_FILE="${BASE_DIR}/versions.txt"

# build dependencies

if ! brew list miniforge &>/dev/null; then
    brew install miniforge
    echo "Please configure the base conda environment by running 'conda init <SHELL_NAME>' and then 'conda install -y python=3.10.8' to create a base environment."
    exit 1
fi

if ! brew list pip-tools &>/dev/null; then
    brew install pip-tools
fi

if ! brew list openblas &>/dev/null; then
    brew install openblas
fi

# conda environment

CONDA_ENV_DIR="python-ios"

set +x
eval "$(command conda 'shell.bash' 'hook')"
conda activate base
rm -rf "$(conda info | grep 'envs directories' | awk -F ':' '{ print $2 }' | sed -e 's/^[[:space:]]*//')/${CONDA_ENV_DIR}"
conda create -y --name "${CONDA_ENV_DIR}" python==3.10.8
conda activate "${CONDA_ENV_DIR}"
set -x
sed -i '' "s/^${numpy[0]}.*/${numpy[0]}==${numpy[1]/v/}/g" requirements.in
sed -i '' "s/^${scipy[0]}.*/${scipy[0]}==${scipy[1]/v/}/g" requirements.in
pip-compile
pip3 install -r requirements.txt

# python apple support

PYTHON_APPLE_SUPPORT_DIR="${BASE_DIR}/python-apple-support"
PYTHON_APPLE_SUPPORT_VERSION="3.10-b6"

rm -rf "${FRAMEWORKS_DIR}" "${PYTHON_APPLE_SUPPORT_DIR}" "${PYTHON_DIR}" "${VERSION_FILE}"
mkdir "${FRAMEWORKS_DIR}" "${PYTHON_APPLE_SUPPORT_DIR}"
pushd "${PYTHON_APPLE_SUPPORT_DIR}"
curl --silent --location "https://github.com/beeware/Python-Apple-support/releases/download/${PYTHON_APPLE_SUPPORT_VERSION}/Python-3.10-iOS-support.b6.tar.gz" --output python-apple-support.tar.gz
tar -xzf python-apple-support.tar.gz
mv python-stdlib "${PYTHON_DIR}"
mv Python.xcframework "${FRAMEWORKS_DIR}"
mv VERSIONS "${VERSION_FILE}"
echo "---------------------" >> "${VERSION_FILE}"
popd
rm -rf "${PYTHON_APPLE_SUPPORT_DIR}"
mkdir "${PYTHON_DIR}/site-packages"

# pip packages

pushd "${SITE_PACKAGES_DIR}"
python3.10 -m pip install --no-deps -r "${BASE_DIR}/.site-packages/requirements.txt" -t .
rm pip/__init__.py setuptools/_distutils/command/build_ext.py
cp "${BASE_DIR}/.site-packages/__init__.py" pip/__init__.py
cp "${BASE_DIR}/.site-packages/build_ext.py" setuptools/_distutils/command/build_ext.py
find . -type d -name "__pycache__" -prune -exec rm -rf {} \;
popd

# openssl

#pushd "${SOURCES_DIR}/openssl"
#./build-libssl.sh --version=1.1.1q
#rm -f ./*.tar.gz
#cp lib/* "${FRAMEWORKS_DIR}"
#popd

# openblas

LAPACK_VERSION="1.4"

curl --silent --location "https://github.com/ColdGrub1384/lapack-ios/releases/download/v${LAPACK_VERSION}/lapack-ios.zip" --output lapack-ios.zip
unzip -q lapack-ios.zip
mv lapack-ios/openblas.framework "${FRAMEWORKS_DIR}"
mv lapack-ios/lapack.framework "${FRAMEWORKS_DIR}"
mv lapack-ios/ios_flang_runtime.framework "${FRAMEWORKS_DIR}/flang_runtime.framework"
cp "${FRAMEWORKS_DIR}/openblas.framework/openblas" "${FRAMEWORKS_DIR}/libopenblas.dylib"
cp "${FRAMEWORKS_DIR}/flang_runtime.framework/ios_flang_runtime" "${FRAMEWORKS_DIR}/libgfortran.dylib"
rm -rf __MACOSX lapack-ios lapack-ios.zip

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
  printf "\n\n*** Building ${package_name} ***\n"
  ./"build-${package_folder}.sh" "${package_name}" "${package_version}" "${package_folder}"

  if ! ls "${FRAMEWORKS_DIR}" | grep "${package_name}"&>/dev/null; then
      echo "Missing ${package_name} in folder ${FRAMEWORKS_DIR} !"
      exit 1
  fi

  if ! [ -d "${SITE_PACKAGES_DIR}/${package_name}" ]; then
      echo "Missing ${package_name} in folder ${SITE_PACKAGES_DIR} !"
      exit 1
  fi
done

popd
find "${SOURCES_DIR}" -name ''*.egg-info'' -exec cp -rf {} "${SITE_PACKAGES_DIR}" \;
find "${SITE_PACKAGES_DIR}" -name ''*.so'' -delete

# cleaning

set +x
conda activate base
echo "Completed successfully."
