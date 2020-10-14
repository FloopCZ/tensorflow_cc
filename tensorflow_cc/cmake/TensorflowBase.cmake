cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
include(ExternalProject)

ExternalProject_Add(
  tensorflow_base
  URL https://github.com/tensorflow/tensorflow/archive/${TENSORFLOW_TAG}.tar.gz
  TMP_DIR "/tmp"
  STAMP_DIR "tensorflow-stamp"
  DOWNLOAD_DIR "tensorflow"
  SOURCE_DIR "tensorflow"
  BUILD_IN_SOURCE 1
  UPDATE_COMMAND ""
  CONFIGURE_COMMAND ""
  BUILD_COMMAND "${CMAKE_CURRENT_BINARY_DIR}/build_tensorflow.sh"
  INSTALL_COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/cmake/copy_links.sh" bazel-bin
          # The include folders are sometimes contained under bazel-bin/bin/ and sometimes just bazel-bin.
          # Later, we include both so let's make sure they both exist so that CMake does not complain.
          COMMAND mkdir -p "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/tensorflow/include/src"
          COMMAND mkdir -p "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/bin/tensorflow/include/src"
          COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/tensorflow/include/src/__placeholder__.h"
          COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/bin/tensorflow/include/src/__placeholder__.h"
)
