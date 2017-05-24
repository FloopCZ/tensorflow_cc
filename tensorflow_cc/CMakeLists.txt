cmake_minimum_required(VERSION 3.3 FATAL_ERROR)

# Static library with no GPU support is built by default.
# Use the following option to build a shared library with GPU support.
# If enabled, bazel has to be installed.
option(TENSORFLOW_SHARED "Build shared library (required for GPU support)." OFF)

# -------------
# CMake Options
# -------------

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
include(CMakePackageConfigHelpers)
set(CMAKECFG_INSTALL_DIR lib/cmake/TensorflowCC)

# ---------------------------------
# Build static / dynamic tensorflow
# ---------------------------------

if (TENSORFLOW_SHARED)
  include(TensorflowShared)
else()
  include(TensorflowStatic)
endif()

# ---------------------
# Add interface library
# ---------------------

add_library(tensorflow_cc INTERFACE)
set_target_properties(
  tensorflow_cc PROPERTIES EXPORT_NAME TensorflowCC
)
target_compile_options(
  tensorflow_cc INTERFACE
  "-std=c++1z"
)

# -----------------------
# Build shared tensorflow
# -----------------------

if(TENSORFLOW_SHARED)
  add_dependencies(
    tensorflow_cc
    tensorflow_shared
  )
  target_include_directories(
    tensorflow_cc INTERFACE
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow/bazel-genfiles
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/eigen
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/gemmlowp
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/protobuf-host/include
  )
  target_link_libraries(
    tensorflow_cc INTERFACE
    "${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libtensorflow_cc.so"
    # static protobuf is used from the contrib/makefile
    "${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libprotobuf.a"
    dl pthread
  )

# -----------------------
# Build static tensorflow
# -----------------------

else()
  add_dependencies(
    tensorflow_cc
    tensorflow_static
  )
  target_include_directories(
    tensorflow_cc INTERFACE
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/host_obj
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/eigen
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/gemmlowp
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/protobuf-host/include
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/proto
    ${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/proto_text
  )
  target_link_libraries(
    tensorflow_cc INTERFACE
    "-Wl,--allow-multiple-definition"
    "-Wl,--whole-archive ${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libtensorflow-core.a"
    "-Wl,--no-whole-archive"
    "${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libprotobuf.a"
    dl pthread
  )
endif()

# -------
# Install
# -------

# install all header files
install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/"
  DESTINATION include/tensorflow
  FILES_MATCHING PATTERN "*.h"
)
# install all files downloaded by contrib/makefile as dependencies
install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/tensorflow/contrib/makefile/downloads/"
  DESTINATION include/tensorflow/tensorflow/contrib/makefile/downloads
)
# install all files from third_party folder (e.g., Eigen/Tensor)
install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/third_party/"
  DESTINATION include/tensorflow/third_party
)
# install static libprotobuf from contrib/makefile
install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/tensorflow/contrib/makefile/gen/protobuf-host/lib/libprotobuf.a"
  DESTINATION lib/tensorflow_cc
)
# shared library specific
if(TENSORFLOW_SHARED)
  install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/tensorflow/libtensorflow_cc.so"
    DESTINATION lib/tensorflow_cc
  )
# static library specific
else()
  install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/tensorflow/contrib/makefile/gen/lib/libtensorflow-core.a"
    DESTINATION lib/tensorflow_cc
  )
endif()

# --------------------------
# Install CMake targets file
# --------------------------

install(
  TARGETS tensorflow_cc
  EXPORT TensorflowCCTargets
)

install(
  EXPORT TensorflowCCTargets
  FILE TensorflowCCConfig.cmake
  DESTINATION "${CMAKECFG_INSTALL_DIR}"
)
