# Find the proper protobuf archive url.
file(DOWNLOAD
  "https://raw.githubusercontent.com/tensorflow/tensorflow/${TENSORFLOW_TAG}/tensorflow/workspace2.bzl"
  "${CMAKE_CURRENT_BINARY_DIR}/tmp/workspace2.bzl"
)
file(READ
  "${CMAKE_CURRENT_BINARY_DIR}/tmp/workspace2.bzl"
  workspace2_str
)
string(REGEX MATCH
  "https://github.com/protocolbuffers/protobuf/archive/v[.0-9]+.zip"
  PROTOBUF_ARCHIVE
  "${workspace2_str}"
)
message("Will build Protobuf from '${PROTOBUF_ARCHIVE}'.")

ExternalProject_Add(
  protobuf-external
  PREFIX protobuf
  URL "${PROTOBUF_ARCHIVE}"
  CMAKE_CACHE_ARGS
    "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}"
    "-Dprotobuf_BUILD_TESTS:BOOL=OFF"
    "-Dprotobuf_BUILD_EXAMPLES:BOOL=OFF"
    "-DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}"
  SOURCE_SUBDIR cmake
  INSTALL_COMMAND ""
)

install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/protobuf/src/protobuf-external-build/cmake_install.cmake")

