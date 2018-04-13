#!/bin/bash
set -e
cwd="`pwd`"

### parse command line arguments ###

shared=false

for key in "$@"; do
    case $key in
        --shared)
        shared=true
        ;;
    esac
done

### build and install tensorflow_cc ###

mkdir tensorflow_cc/tensorflow_cc/build
cd tensorflow_cc/tensorflow_cc/build
# configure only shared or only static library
if $shared; then
    cmake -DTENSORFLOW_STATIC=OFF -DTENSORFLOW_SHARED=ON ..;
else
    cmake ..;
fi
make && make install
cd "$cwd"
rm -rf tensorflow_cc/tensorflow_cc/build

### build and run example ###

mkdir tensorflow_cc/example/build
cd tensorflow_cc/example/build
cmake .. && make && ./example

### cleanup ###

cd "$cwd"
rm -rf ~/.cache
