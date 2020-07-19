#!/bin/bash
set -e

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # install requirements
    export DEBIAN_FRONTEND=noninteractive
    apt-get -y update
    apt-get -y install \
    cmake \
    g++-7 \
    git \
    python3-dev \
    python3-numpy \
    sudo \
    wget

    # install bazel
    export BAZEL_VERSION=${BAZEL_VERSION:-`cat ./Dockerfiles/BAZEL_VERSION`}
    apt-get -y install pkg-config zip g++ zlib1g-dev unzip python
    bazel_installer=bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
    wget -P /tmp https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/${bazel_installer}
    chmod +x /tmp/${bazel_installer}
    /tmp/${bazel_installer}
    rm /tmp/${bazel_installer}

    if [[ ${BUILD_WITH_CUDA:-"OFF"} == "ON" ]]; then
        # install libcupti
        apt-get -y install cuda-command-line-tools-10-1
    fi

else
    echo "This script supports only Debian-based operating systems (like Ubuntu)." \
         "Please consult README file for manual installation on your '$OSTYPE' OS."
    exit 1
fi