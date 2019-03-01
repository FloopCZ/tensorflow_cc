cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
project(
  "tensorflow_cc"
  VERSION 1.13.1
)

# Static library with no GPU support is built by default.
# Use the following option to build a shared library with GPU support.
# If enabled, bazel has to be installed.
option(TENSORFLOW_SHARED "Build shared library (required for GPU support)." OFF)
option(ALLOW_CUDA "When building the shared library, try to find and use CUDA." ON)
option(TENSORFLOW_STATIC "Build static library." ON)
set(TENSORFLOW_TAG "v1.13.1" CACHE STRING "The tensorflow release tag to be checked out (default v1.13.1).")
option(SYSTEM_PROTOBUF "Use system protobuf instead of static protobuf from contrib/makefile." OFF)

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
if(SYSTEM_PROTOBUF)
  find_package(Protobuf REQUIRED)
endif()

# ----------------------------------
# Define Shared Tensorflow Interface
# ----------------------------------

if(TENSORFLOW_SHARED)
  add_library(tensorflow_cc_shared INTERFACE)
  target_compile_options(
    tensorflow_cc_shared INTERFACE
    "$<$<COMPILE_LANGUAGE:CXX>:-std=c++11>"
  )
  add_dependencies(
    tensorflow_cc_shared
    tensorflow_shared
  )
  target_include_directories(
    tensorflow_cc_shared INTERFACE
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/bazel-genfiles"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/bazel-genfiles/genfiles"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/absl"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/eigen"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/gemmlowp"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/nsync/public"
  )
  target_link_libraries(
    tensorflow_cc_shared INTERFACE
    "${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libtensorflow_cc.so"
    dl pthread
  )
  if(SYSTEM_PROTOBUF)
    target_include_directories(
      tensorflow_cc_shared INTERFACE
      "${Protobuf_INCLUDE_DIRS}"
    )
    target_link_libraries(
      tensorflow_cc_shared INTERFACE
      "${Protobuf_LIBRARIES}"
    )
  else()
    target_include_directories(
      tensorflow_cc_shared INTERFACE
      "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/protobuf-host/include"
    )
    target_link_libraries(
      tensorflow_cc_shared INTERFACE
      "${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libprotobuf.a"
    )
  endif()
endif()

# ----------------------------------
# Define Static Tensorflow Interface
# ----------------------------------

if(TENSORFLOW_STATIC)
  add_library(tensorflow_cc_static INTERFACE)
  target_compile_options(
    tensorflow_cc_static INTERFACE
    "$<$<COMPILE_LANGUAGE:CXX>:-std=c++11>"
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
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/absl"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/eigen"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/gemmlowp"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/nsync/public"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/proto"
    "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/proto_text"
  )
  target_link_libraries(
    tensorflow_cc_static INTERFACE
    "-Wl,--allow-multiple-definition"
    "-Wl,--whole-archive ${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libtensorflow-core.a"
    "-Wl,--no-whole-archive"
    "${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/nsync.a"
    dl pthread
  )
  if(SYSTEM_PROTOBUF)
    target_include_directories(
      tensorflow_cc_static INTERFACE
      "${Protobuf_INCLUDE_DIRS}"
    )
    target_link_libraries(
      tensorflow_cc_static INTERFACE
      "${Protobuf_LIBRARIES}"
    )
  else()
    target_include_directories(
      tensorflow_cc_static INTERFACE
      "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/gen/protobuf-host/include"
    )
    target_link_libraries(
      tensorflow_cc_static INTERFACE
      "${CMAKE_INSTALL_PREFIX}/lib/tensorflow_cc/libprotobuf.a"
    )
  endif()
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
# install all header files downloaded by contrib/makefile
# (Note that we cannot simply include all *.h or *.hpp files, since e.g., eigen
# does not use file extensions for header files.)
install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/tensorflow/contrib/makefile/downloads/"
  DESTINATION include/tensorflow/tensorflow/contrib/makefile/downloads
  FILES_MATCHING PATTERN "*"
                 PATTERN "Makefile*"  EXCLUDE
                 PATTERN "*unittest*" EXCLUDE
                 PATTERN "*.o"        EXCLUDE
                 PATTERN "*.so"       EXCLUDE
                 PATTERN "*.so.*"     EXCLUDE
                 PATTERN "*.a"        EXCLUDE
                 PATTERN "*.tbz"      EXCLUDE
                 PATTERN "*.tgz"      EXCLUDE
                 PATTERN "*.tar"      EXCLUDE
                 PATTERN "*.tar.*"    EXCLUDE
                 PATTERN "*.zip"      EXCLUDE
)
# install all files from third_party folder (e.g., Eigen/Tensor)
install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/third_party/"
  DESTINATION include/tensorflow/third_party
)
# install static libprotobuf from contrib/makefile
if (NOT SYSTEM_PROTOBUF)
  install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/tensorflow/contrib/makefile/gen/protobuf-host/lib/libprotobuf.a"
    DESTINATION lib/tensorflow_cc
  )
endif()
# shared library specific
if(TENSORFLOW_SHARED)
  install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/tensorflow/libtensorflow_cc.so"
    DESTINATION lib/tensorflow_cc
    OPTIONAL
  )
  install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/tensorflow/bazel-bin/bin/tensorflow/libtensorflow_cc.so"
    DESTINATION lib/tensorflow_cc
    OPTIONAL
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
