cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
cmake_policy(SET CMP0048 NEW)  # Enable version parameter in project().
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/PROJECT_VERSION" version)
project(
  "tensorflow_cc"
  VERSION ${version}
)

option(ALLOW_CUDA "Try to find and use CUDA." ON)
option(REQUIRE_CUDA "Make sure to find and use CUDA (implies ALLOW_CUDA)." OFF)
set(LOCAL_RAM_RESOURCES 4096 CACHE STRING "The amount of local RAM resources passed to bazel scheduler (e.g., 4096).")
set(LOCAL_CPU_RESOURCES HOST_CPUS CACHE STRING "The amount of local CPU cores passed to bazel scheduler (e.g., 2).")
set(TENSORFLOW_TAG "v${version}" CACHE STRING "The tensorflow release tag to be checked out (default v${version}).")
option(INSTALL_PROTOBUF "Install protobuf compatible with tensorflow version." OFF)
set(CMAKE_CXX_STANDARD 14 CACHE STRING "The C++ standard for building and linking the library (e.g., 14).")

# -------------
# CMake Options
# -------------

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
include(CMakePackageConfigHelpers)
set(CMAKECFG_INSTALL_DIR lib/cmake/TensorflowCC)

# Configure the build_tensorflow script.
configure_file("cmake/build_tensorflow.sh.in" "build_tensorflow.sh" @ONLY)

# ----------------------------------------------
# Include External Projects for Tensorflow Build
# ----------------------------------------------

include(TensorflowBase)
if(INSTALL_PROTOBUF)
  include(ProtobufExternal)
endif()

# ------------------------------
# Define Tensorflow_CC Interface
# ------------------------------

add_library(tensorflow_cc INTERFACE)
target_compile_features(tensorflow_cc INTERFACE "cxx_std_${CMAKE_CXX_STANDARD}")

if(INSTALL_PROTOBUF)
    add_dependencies(tensorflow_cc protobuf-external)
endif()

# The include folders are sometimes contained under bazel-bin/bin/ and sometimes just bazel-bin.
target_include_directories(
  tensorflow_cc INTERFACE
  $<INSTALL_INTERFACE:include/tensorflow/bazel-bin/tensorflow/include>
  $<INSTALL_INTERFACE:include/tensorflow/bazel-bin/tensorflow/include/src>
  $<INSTALL_INTERFACE:include/tensorflow/bazel-bin/bin/tensorflow/include>
  $<INSTALL_INTERFACE:include/tensorflow/bazel-bin/bin/tensorflow/include/src>
)
target_link_libraries(
  tensorflow_cc INTERFACE
  "${CMAKE_INSTALL_PREFIX}/lib/libtensorflow_cc.so.${PROJECT_VERSION_MAJOR}"
  dl pthread
)

# ----------------------------------------
# Configure CMake Config and Version Files
# ----------------------------------------

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/TensorflowCCConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)
configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/TensorflowCCConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/TensorflowCCConfig.cmake"
  INSTALL_DESTINATION "${CMAKECFG_INSTALL_DIR}"
  NO_SET_AND_CHECK_MACRO # TensorflowCC only uses interface libraries
  NO_CHECK_REQUIRED_COMPONENTS_MACRO # TensorflowCC does not have components
)

# -------
# Install
# -------

# install all header files
install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/"
  DESTINATION include/tensorflow/bazel-bin
  FILES_MATCHING PATTERN "*.h"
                 PATTERN "*.inc"
                 REGEX ".*Eigen.*"
)
install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/tensorflow/"
  DESTINATION lib
  FILES_MATCHING PATTERN "libtensorflow_cc.so*"
)
install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/bin/tensorflow/"
  DESTINATION lib
  FILES_MATCHING PATTERN "libtensorflow_cc.so*"
)

# --------------------------
# Install CMake targets file
# --------------------------

set_target_properties(
  tensorflow_cc PROPERTIES EXPORT_NAME TensorflowCC
)
install(
  TARGETS tensorflow_cc
  EXPORT TensorflowCCTargets
)
install(
  EXPORT TensorflowCCTargets
  FILE TensorflowCCTargets.cmake
  NAMESPACE TensorflowCC::
  DESTINATION "${CMAKECFG_INSTALL_DIR}"
)

# install config and version files
install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/TensorflowCCConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/TensorflowCCConfigVersion.cmake"
  DESTINATION "${CMAKECFG_INSTALL_DIR}"
)
