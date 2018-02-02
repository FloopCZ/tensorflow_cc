#!/bin/bash
set -e

# configure environmental variables
export CC_OPT_FLAGS="-march=native"
export TF_NEED_GCP=0
export TF_NEED_HDFS=0
export TF_NEED_OPENCL=0
export TF_NEED_JEMALLOC=1
export TF_NEED_VERBS=0
export TF_NEED_MKL=1
export TF_DOWNLOAD_MKL=1
export TF_NEED_MPI=0
export TF_ENABLE_XLA=1
export TF_NEED_S3=0
export TF_NEED_GDR=0
export TF_CUDA_CLANG=0
export TF_SET_ANDROID_WORKSPACE=0
export PYTHON_BIN_PATH="$(which python3)"
export PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'import site; print(site.getsitepackages()[0])')"

# configure cuda environmental variables

if [ -e /opt/cuda ]; then
    echo "Using CUDA from /opt/cuda"
    export CUDA_TOOLKIT_PATH=/opt/cuda
elif [ -e /usr/local/cuda ]; then
    echo "Using CUDA from /usr/local/cuda"
    export CUDA_TOOLKIT_PATH=/usr/local/cuda
fi

if [ -e /opt/cuda/include/cudnn.h ]; then
    echo "Using CUDNN from /opt/cuda"
    export CUDNN_INSTALL_PATH=/opt/cuda
elif [ -e /usr/local/cuda/cudnn.h ]; then
    echo "Using CUDNN from /usr/local/cuda"
    export CUDNN_INSTALL_PATH=/usr/local/cuda
elif [ -e /usr/include/cudnn.h ]; then
    echo "Using CUDNN from /usr"
    export CUDNN_INSTALL_PATH=/usr
fi

if [ -n "${CUDA_TOOLKIT_PATH}" ]; then
    if [[ -z "${CUDNN_INSTALL_PATH}" ]]; then
        echo "CUDA found but no cudnn.h found. Please install cuDNN."
        exit 1
    fi
    echo "CUDA support enabled"
    cuda_config_opts="--config=cuda"
    export TF_NEED_CUDA=1
    export TF_CUDA_COMPUTE_CAPABILITIES="3.5,5.2,6.1,6.2"
    export TF_CUDA_VERSION="$($CUDA_TOOLKIT_PATH/bin/nvcc --version | sed -n 's/^.*release \(.*\),.*/\1/p')"
    export TF_CUDNN_VERSION="$(sed -n 's/^#define CUDNN_MAJOR\s*\(.*\).*/\1/p' $CUDNN_INSTALL_PATH/include/cudnn.h)"
    # use gcc-6 for now, clang in the future
    export GCC_HOST_COMPILER_PATH=/usr/bin/gcc-6
    export CLANG_CUDA_COMPILER_PATH=/usr/bin/clang
    export TF_CUDA_CLANG=0
else
    echo "CUDA support disabled"
    cuda_config_opts=""
    export TF_NEED_CUDA=0
fi

# configure and build
./configure
bazel build -c opt \
            $cuda_config_opts \
            --incompatible_load_argument_is_label=false \
            --copt=${CC_OPT_FLAGS} tensorflow:libtensorflow_cc.so
bazel shutdown
