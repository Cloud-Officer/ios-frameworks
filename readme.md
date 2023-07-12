# ios-frameworks

## Overview

This is a meta-package building Python Apple Support and common AI/ML libraries targeting an iOS platform.

Special thanks to [BeeWare](https://github.com/beeware/Python-Apple-support) and [Emma Cold](https://github.com/ColdGrub1384/Pyto) for the inspiration.

This was tested on macOS 13 on x86_64 and ARM64 platforms.

The frameworks generated are:

* Python
* libFFI
* BZip2
* OpenSSL
* XZ
* numpy
* Cython
* pandas
* pyemd
* PyWavelets
* scikit-image
* scikit-learn
* statsmodels
* scipy

## Build Instructions

Edit `setup.sh` variables to define the versions required as you see fit.

Simply run `setup.sh` to build everything. Dependencies are checked inside the script but homebrew is required initially and xcode as well.

The output is under the `frameworks` and `python3.11` folders. The `versions.txt` summarizes the exact version for each package.
