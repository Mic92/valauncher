cmake_minimum_required (VERSION 3.0)
cmake_policy (VERSION 3.0)

set (CMAKE_BUILD_TYPE Release)
set (CMAKE_C_FLAGS_RELEASE "-O3")
project (VaLauncher)
list (APPEND CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/cmake)
add_subdirectory (src)
