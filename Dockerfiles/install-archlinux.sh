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
pacman -Syu --noconfirm --needed \
  base-devel \
  cmake \
  git \
  unzip \
  mlocate \
  python \
  python-numpy \
  wget

pacman -S --noconfirm --needed \
  jdk11-openjdk \
  libarchive \
  protobuf \
  unzip \
  zip
export BAZEL_VERSION=${BAZEL_VERSION:-`cat ./tensorflow_cc/Dockerfiles/BAZEL_VERSION`}
bazel_installer=bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
wget -P /tmp https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/${bazel_installer}
chmod +x /tmp/${bazel_installer}
/tmp/${bazel_installer}
rm /tmp/${bazel_installer}

if $cuda; then
    pacman -S --noconfirm --needed \
      cuda \
      cudnn \
      nccl
    source /etc/profile.d/cuda.sh
fi

# when building TF with Intel MKL support, `locate` database needs to exist
updatedb

# build and install tensorflow_cc
./tensorflow_cc/Dockerfiles/install-common.sh "$@"

# cleanup installed cuda libraries (will be provided by nvidia-docker)
if $cuda; then
    rm -vf /usr/bin/nvidia*
    rm -vf /usr/lib/libnvidia*
    rm -vf /usr/lib/libcuda*
    rm -rvf /opt/cuda/doc/
    rm -rvf /opt/cuda/extras/
    rm -rvf /opt/cuda/*nsight*
    rm -rvf /opt/cuda/*nvvp*
    rm -rvf /opt/cuda/samples/
fi

# cleanup packages
rm -rvf /usr/local/lib/bazel/
rm -vf /usr/local/bin/bazel
pacman --noconfirm -R jdk11-openjdk python python-numpy
pacman --noconfirm -Rns $(pacman -Qtdq)
