# tensorflow_cc
[![Build Status](http://ash.floop.cz:8080/buildStatus/icon?job=tensorflow_cc)](http://ash.floop.cz:8080/job/tensorflow_cc/)
[![TF version](https://img.shields.io/badge/TF%20version-1.7.0-brightgreen.svg)]()

This repository makes possible the usage of the [TensorFlow C++](https://www.tensorflow.org/api_docs/cc/) API from the outside of the TensorFlow source code folders and without the use of the [Bazel](https://bazel.build/) build system.

This repository contains two CMake projects. The [tensorflow_cc](tensorflow_cc) project downloads, builds and installs the TensorFlow C++ API into the operating system and the [example](example) project demonstrates its simple usage.

## Docker

If you wish to start using this project right away, fetch a prebuilt image on [Docker Hub](https://hub.docker.com/r/floopcz/tensorflow_cc/)!

Running the image on CPU:
```bash
docker run -it floopcz/tensorflow_cc:ubuntu-shared /bin/bash
```

If you also want to utilize your NVIDIA GPU, install [NVIDIA Docker](https://github.com/NVIDIA/nvidia-docker) and run:
```bash
docker run --runtime=nvidia -it floopcz/tensorflow_cc:ubuntu-shared-cuda /bin/bash
```

The list of available images:

| Image name                                    | Description                                                |
| ---                                           | ---                                                        |
| `floopcz/tensorflow_cc:ubuntu-static`         | Ubuntu + static build of `tensorflow_cc`                   |
| `floopcz/tensorflow_cc:ubuntu-shared`         | Ubuntu + shared build of `tensorflow_cc`                   |
| `floopcz/tensorflow_cc:ubuntu-shared-cuda`    | Ubuntu + shared build of `tensorflow_cc` + NVIDIA CUDA     |
| `floopcz/tensorflow_cc:archlinux-shared`      | Arch Linux + shared build of `tensorflow_cc`               |
| `floopcz/tensorflow_cc:archlinux-shared-cuda` | Arch Linux + shared build of `tensorflow_cc` + NVIDIA CUDA |

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

If you require GPU support on Ubuntu, please also install [Bazel](https://bazel.build/), NVIDIA CUDA Toolkit, NVIDIA drivers, cuDNN, and `cuda-command-line-tools` package. The tensorflow build script will automatically detect CUDA if it is installed in `/opt/cuda` or `/usr/local/cuda` directories.

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

# Link the static Tensorflow library.
target_link_libraries(example TensorflowCC::Static)

# Altenatively, link the shared Tensorflow library.
# target_link_libraries(example TensorflowCC::Shared)

# For shared library setting, you may also link cuda if it is available.
# find_package(CUDA)
# if(CUDA_FOUND)
#   target_link_libraries(example ${CUDA_LIBRARIES})
# endif()
```

#### 3) Build and run your program
```
mkdir build && cd build
cmake .. && make
./example 
```

If you are still unsure, consult the Dockerfiles for
[Ubuntu](Dockerfiles/ubuntu-shared) and [Arch Linux](Dockerfiles/archlinux-shared).
