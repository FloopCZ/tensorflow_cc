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
./tensorflow_cc/ubuntu-requirements.sh

if $cuda; then
    # install libcupti
    apt-get -y install cuda-command-line-tools-10-1
fi

apt-get -y clean

# build and install tensorflow_cc
./tensorflow_cc/Dockerfiles/install-common.sh "$@"
