include(ExternalProject)

ExternalProject_Add(
  tensorflow_static
  DEPENDS tensorflow_base
  TMP_DIR "/tmp"
  STAMP_DIR "tensorflow-stamp"
  SOURCE_DIR "tensorflow"
  BUILD_IN_SOURCE 1
  DOWNLOAD_COMMAND ""
  UPDATE_COMMAND ""
  CONFIGURE_COMMAND tensorflow/contrib/makefile/build_all_linux.sh
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)
