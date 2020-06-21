cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/PROJECT_VERSION" version)
project(
  "tensorflow_cc"
  VERSION "${version}"
)

# If enabled, bazel has to be installed.
option(ALLOW_CUDA "Try to find and use CUDA." ON)
option(REQUIRE_CUDA "Make sure to find and use CUDA (implies ALLOW_CUDA)." OFF)
set(TENSORFLOW_TAG "v${version}" CACHE STRING "The tensorflow release tag to be checked out (default v${version}).")
set(TARGET_CXX_STANDARD "cxx_std_11" CACHE STRING "C++ standard to be enforced when linking to TensorflowCC targets (e.g., cxx_std_11).")

# -------------
# CMake Options
# -------------

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
include(CMakePackageConfigHelpers)
set(CMAKECFG_INSTALL_DIR lib/cmake/TensorflowCC)

set_property(CACHE TARGET_CXX_STANDARD PROPERTY STRINGS
    "cxx_std_11" "cxx_std_14" "cxx_std_17" "cxx_std_20")

# Configure the build_tensorflow script.
configure_file("cmake/build_tensorflow.sh.in" "build_tensorflow.sh" @ONLY)

# ----------------------------------------------
# Include External Projects for Tensorflow Build
# ----------------------------------------------

include(TensorflowBase)

# ------------------------------
# Define Tensorflow_CC Interface
# ------------------------------

add_library(tensorflow_cc INTERFACE)
target_compile_features(tensorflow_cc INTERFACE ${TARGET_CXX_STANDARD})

target_include_directories(
  tensorflow_cc INTERFACE
  "${CMAKE_INSTALL_PREFIX}/include/tensorflow/bazel-bin/tensorflow/include"
  "${CMAKE_INSTALL_PREFIX}/include/tensorflow/bazel-bin/tensorflow/include/src"
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
  FILES "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/tensorflow/libtensorflow_cc.so"
  DESTINATION lib
  RENAME libtensorflow_cc.so.${PROJECT_VERSION_MAJOR}
  OPTIONAL
)
install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/bin/tensorflow/libtensorflow_cc.so"
  DESTINATION lib
  RENAME libtensorflow_cc.so.${PROJECT_VERSION_MAJOR}
  OPTIONAL
)
# Make versioned symlinks to the library
install(CODE "execute_process(                          \
  COMMAND ${CMAKE_COMMAND} -E create_symlink            \
    libtensorflow_cc.so.${PROJECT_VERSION_MAJOR}        \
    ${CMAKE_INSTALL_PREFIX}/lib/libtensorflow_cc.so     \
  )"
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
