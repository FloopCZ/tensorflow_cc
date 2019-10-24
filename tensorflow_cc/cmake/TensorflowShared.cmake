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
            # The grpc integrated in v1.15.0 needs patching, see https://github.com/clearlinux/distribution/issues/1151.
  CONFIGURE_COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/patches/rename-gettid-functions.patch" third_party/
            COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/patches/workspace.bzl.patch" .
            COMMAND git apply workspace.bzl.patch
            COMMAND tensorflow/contrib/makefile/compile_linux_protobuf.sh
            # Do not fail on warnings when building nsync
            COMMAND sed -i "s/ -Werror//g" tensorflow/contrib/makefile/compile_nsync.sh
            COMMAND tensorflow/contrib/makefile/compile_nsync.sh
            COMMAND "${CMAKE_CURRENT_BINARY_DIR}/build_tensorflow.sh"
            COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/cmake/copy_links.sh" .
            # For some reason, Bazel sometimes puts the headers into
            # `bazel-genfiles/genfiles` and sometimes just to `bazel-genfiles`.
            # So we just create and include both the directories.
            COMMAND mkdir -p bazel-genfiles/genfiles
            COMMAND touch bazel-genfiles/_placeholder.h
            COMMAND touch bazel-genfiles/genfiles/_placeholder.h
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)
