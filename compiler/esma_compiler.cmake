# CMake code involving compilers

## Print out the processor description
cmake_host_system_information(RESULT proc_description QUERY PROCESSOR_DESCRIPTION)
message(STATUS "Processor description: ${proc_description}")
set(proc_description "${proc_description}" CACHE INTERNAL "Processor description")

## Checks for Fortran support
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/checks")
include(check_fortran_support)

## We only allow for three CMake Build Types
set(ALLOWED_BUILD_TYPES "Debug" "Release" "Aggressive" "VectTrap")
if(NOT CMAKE_BUILD_TYPE IN_LIST ALLOWED_BUILD_TYPES)
  string(REPLACE ";" ", " ALLOWED_BUILD_TYPES_STRING "${ALLOWED_BUILD_TYPES}")
  message(FATAL_ERROR "The only allowed CMAKE_BUILD_TYPE are: ${ALLOWED_BUILD_TYPES_STRING}")
endif()

## Files with flags for Fortran compilers
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/flags")
include ("${CMAKE_Fortran_COMPILER_ID}_Fortran")

## We need to append some extra flags if using icx (aka CMAKE_C_COMPILER_ID=IntelLLVM)
if (CMAKE_C_COMPILER_ID STREQUAL "IntelLLVM")
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-implicit-int")
endif ()
