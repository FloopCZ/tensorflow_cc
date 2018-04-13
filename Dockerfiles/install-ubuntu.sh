#!/bin/bash
set -e

# parse command line arguments

shared=false
cuda=false

for key in "$@"; do
    case $key in
        --shared)
        shared=true
        ;;
        --cuda)
        cuda=true
        ;;
    esac
done

# add repository with recent versions of compilers
apt-get -y update
apt-get -y install software-properties-common
add-apt-repository -y ppa:ubuntu-toolchain-r/test
apt-get -y clean

# install requirements
apt-get -y update
apt-get -y install \
  build-essential \
  curl \
  git \
  cmake \
  unzip \
  autoconf \
  autogen \
  libtool \
  mlocate \
  zlib1g-dev \
  g++-6 \
  python \
  python3-numpy \
  python3-dev \
  python3-pip \
  python3-wheel \
  wget

if $shared; then
    # install bazel for the shared library version
    echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
    curl https://bazel.build/bazel-release.pub.gpg | apt-key add -
    apt-get -y update
    apt-get -y install openjdk-8-jdk bazel
fi
if $cuda; then
    # install libcupti
    apt-get -y install cuda-command-line-tools-9-1
fi

apt-get -y clean

# when building TF with Intel MKL support, `locate` database needs to exist
updatedb

# build and install tensorflow_cc
./tensorflow_cc/Dockerfiles/install-common.sh "$@"
