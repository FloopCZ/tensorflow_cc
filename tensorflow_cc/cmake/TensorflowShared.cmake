cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
include(ExternalProject)

ExternalProject_Add(
  tensorflow_shared
  DEPENDS tensorflow_base
  TMP_DIR "/tmp"
  STAMP_DIR "tensorflow-stamp"
  SOURCE_DIR "tensorflow"
  BUILD_IN_SOURCE 1
  DOWNLOAD_COMMAND ""
  UPDATE_COMMAND ""
  CONFIGURE_COMMAND tensorflow/contrib/makefile/compile_linux_protobuf.sh
            COMMAND tensorflow/contrib/makefile/compile_nsync.sh
            COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/cmake/build_tensorflow.sh" .
            COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/cmake/copy_links.sh" .
            COMMAND ./build_tensorflow.sh
            COMMAND ./copy_links.sh .
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)
