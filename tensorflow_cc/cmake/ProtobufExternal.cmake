set(PROTOBUF_ARCHIVE https://github.com/protocolbuffers/protobuf/archive/v3.9.2.zip)

ExternalProject_Add(
  protobuf-external
  PREFIX protobuf
  URL "${PROTOBUF_ARCHIVE}"
  BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf"
  CMAKE_CACHE_ARGS
    "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}"
    "-Dprotobuf_BUILD_TESTS:BOOL=OFF"
    "-Dprotobuf_BUILD_EXAMPLES:BOOL=OFF"
    "-DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}"
  SOURCE_SUBDIR cmake
  BUILD_ALWAYS 1
  STEP_TARGETS build
  INSTALL_COMMAND ""
)

install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/protobuf/cmake_install.cmake")

