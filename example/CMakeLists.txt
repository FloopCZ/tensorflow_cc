cmake_minimum_required(VERSION 3.3 FATAL_ERROR)

find_package(TensorflowCC REQUIRED)
add_executable(example example.cpp)
target_link_libraries(
  example
  PRIVATE TensorflowCC
)
