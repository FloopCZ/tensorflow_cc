cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
include(ExternalProject)

# TODO This is a patch for 1.12.0.
set(OLD_PROTOBUF "https://mirror.bazel.build/github.com/google/protobuf/archive/396336eb961b75f03b25824fe86cf6490fb75e3a.tar.gz")
set(FIXED_PROTOBUF "https://github.com/protocolbuffers/protobuf/releases/download/v3.6.0/protobuf-all-3.6.0.tar.gz")

ExternalProject_Add(
  tensorflow_base
  GIT_REPOSITORY https://github.com/tensorflow/tensorflow.git
  GIT_TAG "${TENSORFLOW_TAG}"
  TMP_DIR "/tmp"
  STAMP_DIR "tensorflow-stamp"
  DOWNLOAD_DIR "tensorflow"
  SOURCE_DIR "tensorflow"
  BUILD_IN_SOURCE 1
  UPDATE_COMMAND ""
  CONFIGURE_COMMAND make -f tensorflow/contrib/makefile/Makefile clean

            # TODO This is a patch for 1.12.0.
            COMMAND git checkout master -- tensorflow/tf_version_script.lds
            COMMAND sed -i "s#${OLD_PROTOBUF}#${FIXED_PROTOBUF}#g" tensorflow/contrib/makefile/download_dependencies.sh

            COMMAND tensorflow/contrib/makefile/download_dependencies.sh
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)
