# tensorflow_cc
[![Build Status](http://plum.floop.cz:8080/buildStatus/icon?job=tensorflow_cc)](http://plum.floop.cz:8080/job/tensorflow_cc/)

This repository makes possible the usage of the [TensorFlow C++](https://www.tensorflow.org/api_docs/cc/) library from the outside of the TensorFlow source code folders and without the use of the [Bazel](https://bazel.build/) build system.

This repository contains two CMake projects. The [tensorflow_cc](tensorflow_cc) project downloads, builds and installs the TensorFlow C++ library into the operating system and the [example](example) project demonstrates its simple usage.

## Installation

#### 1) Install requirements

##### Ubuntu 16.04+:
```
# On Ubuntu 16.04, add ubuntu-toolchain-r PPA (for g++-6)
# sudo apt-get install software-properties-common
# sudo add-apt-repository ppa:ubuntu-toolchain-r/test
# sudo apt-get update

sudo apt-get install build-essential curl git cmake unzip autoconf autogen libtool mlocate zlib1g-dev \
                     g++-6 python python3-numpy python3-dev python3-pip python3-wheel wget
sudo updatedb
```

If you require GPU support on Ubuntu, please also install [Bazel](https://bazel.build/), NVIDIA CUDA Toolkit, NVIDIA drivers, cuDNN, and `libcupti-dev` package. The tensorflow build script will automatically detect CUDA if it is installed in `/opt/cuda` or `/usr/local/cuda`directories.

##### Arch Linux:
```
sudo pacman -S base-devel cmake git unzip mlocate python python-numpy wget
sudo updatedb
```

For GPU support on Arch, also install the following:

```
sudo pacman -S gcc6 bazel cuda cudnn nvidia
```

#### 2) Clone this repository
```
git clone https://github.com/FloopCZ/tensorflow_cc.git
cd tensorflow_cc
```

#### 3) Build and install the library

There are two possible ways to build the TensorFlow C++ library:
1. As a __static library__ (default):
    - Faster to build.
    - Provides only basic functionality, just enough for inferring using an existing network
      (see [contrib/makefile](https://github.com/tensorflow/tensorflow/tree/master/tensorflow/contrib/makefile)).
    - No GPU support.
2. As a __shared library__:
    - Requires [Bazel](https://bazel.build/).
    - Slower to build.
    - Provides the full TensorFlow C++ API.
    - GPU support.

```
cd tensorflow_cc
mkdir build && cd build
# for static library only:
cmake ..
# for shared library only (requires Bazel):
# cmake -DTENSORFLOW_STATIC=OFF -DTENSORFLOW_SHARED=ON ..
make && sudo make install
```

#### 4) (Optional) Free disk space

```
# cleanup bazel build directory
rm -rf ~/.cache
# remove the build folder
cd .. && rm -rf build
```

## Usage

#### 1) Write your C++ code:
```C++
// example.cpp

#include <tensorflow/core/platform/env.h>
#include <tensorflow/core/public/session.h>
#include <iostream>
using namespace std;
using namespace tensorflow;

int main()
{
    Session* session;
    Status status = NewSession(SessionOptions(), &session);
    if (!status.ok()) {
        cout << status.ToString() << "\n";
        return 1;
    }
    cout << "Session successfully created.\n";
}
```

#### 2) Link TensorflowCC to your program using CMake
```CMake
# CMakeLists.txt

find_package(TensorflowCC REQUIRED)
add_executable(example example.cpp)
# link the static Tensorflow library
target_link_libraries(example TensorflowCC::Static)
# link the shared Tensorflow library
# target_link_libraries(example TensorflowCC::Shared)
```

#### 3) Build and run your program
```
mkdir build && cd build
cmake .. && make
./example 
```

If you are still unsure, consult the Dockerfiles for
[Ubuntu](Dockerfiles/ubuntu) and [Arch Linux](Dockerfiles/archlinux).
