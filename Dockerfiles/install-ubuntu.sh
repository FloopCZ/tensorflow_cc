#!/bin/bash
set -e

# parse command line arguments
cuda=false

for key in "$@"; do
    case $key in
        --cuda)
        cuda=true
        ;;
    esac
done

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
export BAZEL_VERSION=${BAZEL_VERSION:-`cat ./tensorflow_cc/Dockerfiles/BAZEL_VERSION`}
apt-get -y install pkg-config zip g++ zlib1g-dev unzip python
bazel_installer=bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
wget -P /tmp https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/${bazel_installer}
chmod +x /tmp/${bazel_installer}
/tmp/${bazel_installer}
rm /tmp/${bazel_installer}

if $cuda; then
    # install libcupti
    apt-get -y install cuda-command-line-tools-10-1
fi

apt-get -y clean

# build and install tensorflow_cc
./tensorflow_cc/Dockerfiles/install-common.sh "$@"
