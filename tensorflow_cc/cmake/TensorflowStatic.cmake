include(ExternalProject)

ExternalProject_Add(
  tensorflow_static
  GIT_REPOSITORY http://github.com/tensorflow/tensorflow.git
  GIT_TAG v1.2.0-rc2
  TMP_DIR "/tmp"
  STAMP_DIR "tensorflow-stamp"
  DOWNLOAD_DIR "tensorflow"
  SOURCE_DIR "tensorflow"
  BUILD_IN_SOURCE 1
  UPDATE_COMMAND ""
  CONFIGURE_COMMAND make -f tensorflow/contrib/makefile/Makefile clean
            COMMAND tensorflow/contrib/makefile/download_dependencies.sh
            COMMAND tensorflow/contrib/makefile/build_all_linux.sh
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)
