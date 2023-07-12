#!/usr/bin/env bash

alias python3=python3.11

SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
XCRUN="iosxcrun"
NUMPY1="${SOURCES_DIR}/numpy/numpy/core/include"
NUMPY2="${SOURCES_DIR}/numpy/build/src.iphoneos-arm64-3.11/numpy/core/include/numpy"

export PATH="${BASE_DIR}/bin:${PATH}"
export _PYTHON_HOST_PLATFORM=iphoneos-arm64
export IPHONEOS_DEPLOYMENT_TARGET=12.0
export LD="${XCRUN}"
export CC="${XCRUN} --sdk iphoneos clang -arch arm64 -mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
export CXX="${XCRUN} --sdk iphoneos clang -arch arm64 -lstdc++ -mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
export LDFLAGS="-arch arm64 -mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET} -isysroot ${SDK}"
export CPPFLAGS="-arch arm64 -isysroot ${SDK} -UHAVE_FEATURES_H -I'${NUMPY1}' -I'${NUMPY2}' -Wno-unknown-attributes -Wno-unused-function -Wno-unused-variable -Wno-unknown-warning-option -Wno-unused-but-set-variable -Wno-unreachable-code-fallthrough -Wno-undefined-internal -Wno-implicit-function-declaration -Wno-unreachable-code -Wno-sometimes-uninitialized -Wno-sign-compare -Wno-incompatible-pointer-types"
export CFLAGS="-arch arm64 -isysroot ${SDK} -UHAVE_FEATURES_H -I'${NUMPY1}' -I'${NUMPY2}' -Wno-unknown-attributes -Wno-unused-function -Wno-unused-variable -Wno-unknown-warning-option -Wno-unused-but-set-variable -Wno-unreachable-code-fallthrough -Wno-undefined-internal -Wno-implicit-function-declaration -Wno-unreachable-code -Wno-sometimes-uninitialized -Wno-sign-compare -Wno-incompatible-pointer-types"
export ARCHFLAGS="-arch arm64"
