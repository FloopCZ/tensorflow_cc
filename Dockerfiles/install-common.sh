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

### prepare an unprivileged user

groupadd -r tensorflow_cc
useradd --no-log-init -r -m -g tensorflow_cc tensorflow_cc
chmod -R go+rX /tensorflow_cc
function unpriv-run() {
    sudo --preserve-env=LD_LIBRARY_PATH -H -u tensorflow_cc "$@"
}

### build and install tensorflow_cc ###

mkdir tensorflow_cc/tensorflow_cc/build
chown -R tensorflow_cc:tensorflow_cc tensorflow_cc/tensorflow_cc/build
chmod go+rX tensorflow_cc/tensorflow_cc/build
cd tensorflow_cc/tensorflow_cc/build

# configure only shared or only static library
if $shared; then
    cmake -DTENSORFLOW_STATIC=OFF -DTENSORFLOW_SHARED=ON ..;
else
    cmake ..;
fi

# build and install
make
rm -rf /home/tensorflow_cc/.cache
make install
cd "$cwd"
rm -rf tensorflow_cc/tensorflow_cc/build

### build and run example ###

mkdir tensorflow_cc/example/build
chown -R tensorflow_cc:tensorflow_cc tensorflow_cc/example/build
chmod go+rX tensorflow_cc/example/build
cd tensorflow_cc/example/build
cmake ..
make
./example

### delete the unprivileged user
chown -R root:root /tensorflow_cc
userdel -r tensorflow_cc
