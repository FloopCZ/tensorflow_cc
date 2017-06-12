# tensorflow_cc
[![Build Status](http://plum.floop.cz:8080/buildStatus/icon?job=tensorflow_cc)](http://plum.floop.cz:8080/job/tensorflow_cc/)

This repository makes possible the usage of the [TensorFlow C++](https://www.tensorflow.org/api_docs/cc/) library from the outside of the TensorFlow source code folders and without the use of the [Bazel](https://bazel.build/) build system.

This repository contains two CMake projects. The [tensorflow_cc](tensorflow_cc) project downloads, builds and installs the TensorFlow C++ library into the operating system and the [example](example) project demonstrates its simple usage.

## Installation

#### 1) Install requirements

##### Ubuntu 16.04+:
```
sudo apt-get install build-essential curl git cmake unzip autoconf autogen libtool mlocate \
                     python python3-numpy python3-dev python3-pip python3-wheel
sudo updatedb
```

If you require GPU support on Ubuntu, please also install [Bazel](https://bazel.build/), NVIDIA CUDA Toolkit, NVIDIA drivers, cuDNN, and `libcupti-dev` package. The tensorflow build script will automatically detect CUDA if it is installed in `/opt/cuda` directory.

##### Arch Linux:
```
sudo pacman -S base-devel cmake git unzip mlocate python python-numpy
sudo updatedb
```

For GPU support on Arch, also install the following:

```
sudo pacman -S gcc5 bazel cuda cudnn nvidia
```

#### 2) Clone this repository
```
git clone https://github.com/FloopCZ/tensorflow_cc.git
cd tensorflow_cc
```

#### 3) Install the library

```
cd tensorflow_cc
mkdir build && cd build
cmake ..
# alternatively, use the following for GPU support
# cmake -DTENSORFLOW_SHARED=ON ..
make && sudo make install
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
target_link_libraries(example TensorflowCC::Static)
# alternatively, use the following for GPU support
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
