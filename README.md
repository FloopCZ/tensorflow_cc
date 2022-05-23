# tensorflow_cc
[![Build Status](http://oak.floop.cz:8080/buildStatus/icon?job=tensorflow_cc)](http://oak.floop.cz:8080/job/tensorflow_cc/)
[![TF version](https://img.shields.io/badge/TF%20version-2.9.0-brightgreen.svg)]()

This repository makes possible the usage of the [TensorFlow C++](https://www.tensorflow.org/api_docs/cc/) API from the outside of the TensorFlow source code folders and without the use of the [Bazel](https://bazel.build/) build system.

This repository contains two CMake projects. The [tensorflow_cc](tensorflow_cc) project downloads, builds and installs the TensorFlow C++ API into the operating system and the [example](example) project demonstrates its simple usage.

## Docker

If you wish to start using this project right away, fetch a prebuilt image on [Docker Hub](https://hub.docker.com/r/floopcz/tensorflow_cc/)!

Running the image on CPU:
```bash
docker run -it floopcz/tensorflow_cc:ubuntu /bin/bash
```

If you also want to utilize your NVIDIA GPU, install [NVIDIA Docker](https://github.com/NVIDIA/nvidia-docker) and run:
```bash
docker run --gpus all -it floopcz/tensorflow_cc:ubuntu-cuda /bin/bash
```

The list of available images:

| Image name                                    | Description                                         |
| ---                                           | ---                                                 |
| `floopcz/tensorflow_cc:ubuntu`                | Ubuntu build of `tensorflow_cc`                     |
| `floopcz/tensorflow_cc:ubuntu-cuda`           | Ubuntu build of `tensorflow_cc` + NVIDIA CUDA       |
| `floopcz/tensorflow_cc:archlinux`             | Arch Linux build of `tensorflow_cc`                 |
| `floopcz/tensorflow_cc:archlinux-cuda`        | Arch Linux build of `tensorflow_cc` + NVIDIA CUDA   |

To build one of the images yourself, e.g. `ubuntu`, run:
```bash
docker build -t floopcz/tensorflow_cc:ubuntu -f Dockerfiles/ubuntu .
```

## Installation

#### 1) Install requirements

##### Ubuntu 18.04:
Install repository requirements:
```
sudo apt-get install cmake curl g++-7 git python3-dev python3-numpy sudo wget
```

Set up Python 3 to be the default Python:
```
update-alternatives --install /usr/bin/python python /usr/bin/python3 1
```

In order to build the TensorFlow itself, the build procedure also requires [Bazel](https://bazel.build/):
```
curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
sudo apt-get update && sudo apt-get install bazel
```

If you require GPU support on Ubuntu, please also install NVIDIA CUDA Toolkit (>=11.1), NVIDIA drivers, cuDNN, and `cuda-command-line-tools` package.
The build procedure will automatically detect CUDA if it is installed in `/opt/cuda` or `/usr/local/cuda` directories.

##### Arch Linux:
```
sudo pacman -S base-devel bazel cmake git python python-numpy wget
```

For GPU support on Arch, also install the following:

```
sudo pacman -S cuda cudnn nvidia
```

**Warning:** Newer versions of TensorFlow sometimes fail to build with the latest version of Bazel. You may wish
to install an older version of Bazel (e.g., 5.1.1).

**Warning:** If your program uses Protobuf and you encounter linkage or other problems, you can
try `-DINSTALL_PROTOBUF=ON` option to install a Protobuf version matching the version bundled with TensorFlow.
Our Dockerfiles are already built with the right version of Protobuf, so you may want to try
your program in the Dockerfile first.

#### 2) Clone this repository
```
git clone https://github.com/FloopCZ/tensorflow_cc.git
cd tensorflow_cc
```

#### 3) Build and install the library

```
cd tensorflow_cc
mkdir build && cd build
cmake ..
make
sudo make install
sudo ldconfig
```

**Warning:** Optimizations for Intel CPU generation `>=haswell` are enabled by default. If you have a
processor that is older than `haswell` generation, you may wish to run `export CC_OPT_FLAGS="-march=native"`
before the build. This command provides the best possible optimizations for your current CPU generation, but
it may cause the built library to be incompatible with older generations.

**Warning:** In low-memory or many-cpu environments, the bazel scheduler can miss the resource consumption
estimates and the build may be terminated by the out-of-memory killer.
If that is your case, consider adding resource limit parameters to CMake, e.g.,
`cmake -DLOCAL_RAM_RESOURCES=2048 -DLOCAL_CPU_RESOURCES=4 ..`

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

# Link the Tensorflow library.
target_link_libraries(example TensorflowCC::TensorflowCC)

# You may also link cuda if it is available.
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
[Ubuntu](Dockerfiles/ubuntu) and [Arch Linux](Dockerfiles/archlinux).
