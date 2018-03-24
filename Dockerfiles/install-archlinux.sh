#!/bin/bash
set -e

# parse command line arguments

shared=false
cuda=false

for key in "$@"; do
    key="$1"
    case $key in
        --shared)
        shared=true
        shift
        ;;
        --cuda)
        cuda=true
        shift
        ;;
    esac
done

# install requirements
pacman -S --noconfirm --needed \
  base-devel \
  cmake \
  git \
  unzip \
  mlocate \
  python \
  python-numpy \
  wget

if $shared; then
    pacman -S --noconfirm --needed \
      gcc6 \
      bazel
fi
if $cuda; then
    pacman -S --noconfirm --needed \
      cuda \
      cudnn
fi

paccache -rfk0

# when building TF with Intel MKL support, `locate` database needs to exist
updatedb

# build and install tensorflow_cc
./tensorflow_cc/Dockerfiles/install-common.sh "$@"
