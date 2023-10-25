# CMake code involving compilers

## Print out the processor description
cmake_host_system_information(RESULT proc_description QUERY PROCESSOR_DESCRIPTION)
message(STATUS "Processor description: ${proc_description}")

## Checks for Fortran support
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/checks")
include(check_fortran_support)

## Files with flags for Fortran compilers
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/flags")
include ("${CMAKE_Fortran_COMPILER_ID}_Fortran")

message(STATUS "CMAKE_C_COMPILER_ID: ${CMAKE_C_COMPILER_ID}")

## We need to append some extra flags if using icx (aka CMAKE_C_COMPILER_ID=IntelLLVM)
if (CMAKE_C_COMPILER_ID STREQUAL "IntelLLVM")
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-implicit-int")
endif ()
