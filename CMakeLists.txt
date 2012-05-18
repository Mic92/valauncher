cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.8)

set (CMAKE_BUILD_TYPE Release)
set (CMAKE_C_FLAGS_RELEASE "-O3")
project (VaLauncher)
list (APPEND CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/cmake)
add_subdirectory (src)
