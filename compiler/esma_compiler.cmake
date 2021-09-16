# CMake code involving compilers

## Checks for Fortran support
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/checks")
include(check_fortran_support)

## Files with flags for Fortran compilers
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/flags")
include ("${CMAKE_Fortran_COMPILER_ID}_Fortran")
