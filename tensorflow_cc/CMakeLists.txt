cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
project(
  "tensorflow_cc"
  VERSION 0.2
)

# Static library with no GPU support is built by default.
# Use the following option to build a shared library with GPU support.
# If enabled, bazel has to be installed.
option(TENSORFLOW_SHARED "Build shared library (required for GPU support)." OFF)
option(TENSORFLOW_STATIC "Build static library." ON)

# -------------
# CMake Options
# -------------

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
include(CMakePackageConfigHelpers)
set(CMAKECFG_INSTALL_DIR lib/cmake/TensorflowCC)

# --------------------------------------------------------
# Include External Projects for Shared / Static Tensorflow
# --------------------------------------------------------

include(TensorflowBase)
if(TENSORFLOW_SHARED)
  include(TensorflowShared)
endif()
if(TENSORFLOW_STATIC)
  include(TensorflowStatic)
  # Add shared lib as dependency to avoid race
  if(TENSORFLOW_SHARED)
    add_dependencies(
      tensorflow_static
      tensorflow_shared
    )
  endif()
endif()

# ----------------------------------
# Define Shared Tensorflow Interface
# ----------------------------------

if(TENSORFLOW_SHARED)
  add_library(tensorflow_cc_shared INTERFACE)
  target_compile_options(
    tensorflow_cc_shared INTERFACE
    "-std=c++17"
  )
  add_dependencies(
    tensorflow_cc_shared
    tensorflow_shared
  )
  target_include_directories(
    tensorflow_cc_shared INTERFACE
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/bazel-genfiles"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/eigen"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/gemmlowp"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/nsync/public"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/protobuf-host/include"
  )
  target_link_libraries(
    tensorflow_cc_shared INTERFACE
    "${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libtensorflow_cc.so"
    "${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libtensorflow_framework.so"
    # static protobuf is used from the contrib/makefile
    "${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libprotobuf.a"
    dl pthread
  )
endif()

# ----------------------------------
# Define Static Tensorflow Interface
# ----------------------------------

if(TENSORFLOW_STATIC)
  add_library(tensorflow_cc_static INTERFACE)
  target_compile_options(
    tensorflow_cc_static INTERFACE
    "-std=c++1z"
  )
  add_dependencies(
    tensorflow_cc_static
    tensorflow_static
  )
  target_include_directories(
    tensorflow_cc_static INTERFACE
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/host_obj"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/eigen"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/gemmlowp"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/nsync/public"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/protobuf-host/include"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/proto"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/proto_text"
  )
  target_link_libraries(
    tensorflow_cc_static INTERFACE
    "-Wl,--allow-multiple-definition"
    "-Wl,--whole-archive ${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libtensorflow-core.a"
    "-Wl,--no-whole-archive"
    "${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libprotobuf.a"
    "${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/nsync.a"
    dl pthread
  )
endif()

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
          "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/tensorflow/libtensorflow_framework.so"
    DESTINATION lib/tensorflow_cc
  )
endif()
# static library specific
if(TENSORFLOW_STATIC)
  install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/tensorflow/contrib/makefile/gen/lib/libtensorflow-core.a"
          "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/tensorflow/contrib/makefile/downloads/nsync/builds/default.linux.c++11/nsync.a"
    DESTINATION lib/tensorflow_cc
  )
endif()

# --------------------------
# Install CMake targets file
# --------------------------

if(TENSORFLOW_SHARED)
  set_target_properties(
    tensorflow_cc_shared PROPERTIES EXPORT_NAME Shared
  )
  install(
    TARGETS tensorflow_cc_shared
    EXPORT TensorflowCCSharedTargets
  )
  install(
    EXPORT TensorflowCCSharedTargets
    FILE TensorflowCCSharedTargets.cmake
    NAMESPACE TensorflowCC::
    DESTINATION "${CMAKECFG_INSTALL_DIR}"
  )
endif()
if(TENSORFLOW_STATIC)
  set_target_properties(
    tensorflow_cc_static PROPERTIES EXPORT_NAME Static
  )
  install(
    TARGETS tensorflow_cc_static
    EXPORT TensorflowCCStaticTargets
  )
  install(
    EXPORT TensorflowCCStaticTargets
    FILE TensorflowCCStaticTargets.cmake
    NAMESPACE TensorflowCC::
    DESTINATION "${CMAKECFG_INSTALL_DIR}"
  )
endif()

# install config and version files
install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/TensorflowCCConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/TensorflowCCConfigVersion.cmake"
  DESTINATION "${CMAKECFG_INSTALL_DIR}"
)
