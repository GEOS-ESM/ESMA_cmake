# CMake code involving compilers

## Checks for support of flags
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/checks")
include(check_fortran_support)

## Files with options for compilers
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/options")
include ("${CMAKE_Fortran_COMPILER_ID}")
