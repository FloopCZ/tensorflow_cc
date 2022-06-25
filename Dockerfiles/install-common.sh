#!/bin/bash
set -e
cwd="`pwd`"

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

# build and install
cmake -DLOCAL_RAM_RESOURCES=1024 -DLOCAL_CPU_RESOURCES=2 -DINSTALL_PROTOBUF=ON ..
make
rm -rf /home/tensorflow_cc/.cache
rm -rf /root/.cache
make install
ldconfig
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
