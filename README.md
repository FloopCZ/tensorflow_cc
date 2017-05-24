# tensorflow_cc
[![Build Status](http://plum.floop.cz:8080/buildStatus/icon?job=tensorflow_cc)](http://plum.floop.cz:8080/job/tensorflow_cc/)

This repository contains two CMake projects. The [tensorflow_cc](tensorflow_cc) project downloads, builds and installs the [TensorFlow C++](https://www.tensorflow.org/api_docs/cc/) library into the operatring system and the [example](example) project demonstrates its simple usage.

This repository allows to use the TensorFlow C++ library from the outside of the TensorFlow folder hierarchy and without the use of the [Bazel](https://bazel.build/) build system.

### Install Requirements (Ubuntu 16.04+)
```
sudo apt-get -y install build-essential curl git cmake unzip autoconf autogen libtool \
                python python3-numpy python3-dev python3-pip python3-wheel
```

If you require GPU support, please also install [Bazel](https://bazel.build/), NVIDIA CUDA Toolkit, NVIDIA drivers, cuDNN, and `libcupti-dev` package. The tensorflow build script will automatically detect CUDA if it is installed in `/opt/cuda` directory.

### Clone the Repository
```
git clone https://github.com/FloopCZ/tensorflow_cc.git
cd tensorflow_cc
```

### Install the TensorFlow C++ Library
```
cd tensorflow_cc
mkdir build && cd build
cmake ..
# alternatively, use the following for GPU support (requires Bazel)
# cmake -DTENSORFLOW_SHARED=ON ..
make && sudo make install
```

### Build and Run the Example
```
cd ../../example
mkdir build && cd build
cmake .. && make
./example 
```
