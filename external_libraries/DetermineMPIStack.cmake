# This code will try and determine the MPI stack being used and set the MPI_STACK variable

include(CMakePrintHelpers)

set(ALLOWED_MPI_STACKS "intelmpi;mvapich;mpt;mpich;openmpi")

if (MPI_STACK)
  if (NOT MPI_STACK IN_LIST ALLOWED_MPI_STACKS)
    message(FATAL_ERROR "MPI_STACK must be one of the following: ${ALLOWED_MPI_STACKS}")
  else()
    set(MPI_STACK_TYPE "User Specified")
    message(WARNING "MPI_STACK is user specified. Please ensure that the specified MPI stack is compatible with the build. NOTE: MPI_STACK_VERSION is not being set.")
  endif()
else ()
  message(STATUS "MPI_STACK not specified. Attempting to autodetect MPI stack...")
  message(DEBUG "MPI_Fortran_LIBRARY_VERSION_STRING: ${MPI_Fortran_LIBRARY_VERSION_STRING}")

  string(REPLACE " " ";" MPI_Fortran_LIBRARY_VERSION_LIST ${MPI_Fortran_LIBRARY_VERSION_STRING})
  message(DEBUG "MPI_Fortran_LIBRARY_VERSION_LIST: ${MPI_Fortran_LIBRARY_VERSION_LIST}")
  list(GET MPI_Fortran_LIBRARY_VERSION_LIST 0 MPI_Fortran_LIBRARY_VERSION_FIRSTWORD)
  message(DEBUG "MPI_Fortran_LIBRARY_VERSION_FIRSTWORD: ${MPI_Fortran_LIBRARY_VERSION_FIRSTWORD}")

  if(MPI_Fortran_LIBRARY_VERSION_STRING MATCHES "Intel")
    set(MPI_STACK intelmpi)
    list(GET MPI_Fortran_LIBRARY_VERSION_LIST 3 MPI_STACK_VERSION)
  elseif(MPI_Fortran_LIBRARY_VERSION_STRING MATCHES "MVAPICH")
    set(MPI_STACK mvapich)
    # MVAPICH output for MPI_Fortran_LIBRARY_VERSION_STRING is complex and multi-line. 
    # So we need to extract the first line from that multi-line string.
    string(REGEX REPLACE "\n.*" "" MPI_Fortran_LIBRARY_VERSION_STRING_FIRST_LINE ${MPI_Fortran_LIBRARY_VERSION_STRING})
    # Now we need to grab the last word from the first line of the string
    string(REGEX MATCH "[^ ]+$" MPI_STACK_VERSION ${MPI_Fortran_LIBRARY_VERSION_STRING_FIRST_LINE})
    # Now we need to remove any colons, spaces, tabs, etc., but keep dots and letters.
    string(REGEX REPLACE "[^a-zA-Z0-9.]" "" MPI_STACK_VERSION ${MPI_STACK_VERSION})
  elseif(MPI_Fortran_LIBRARY_VERSION_STRING MATCHES "MPT")
    set(MPI_STACK mpt)
    list(GET MPI_Fortran_LIBRARY_VERSION_LIST 2 MPI_STACK_VERSION)
  elseif(MPI_Fortran_LIBRARY_VERSION_STRING MATCHES "MPICH")
    set(MPI_STACK mpich)
    # MPICH output for MPI_Fortran_LIBRARY_VERSION_STRING is complex and multi-line. 
    # So we need to extract the first line from that multi-line string.
    string(REGEX REPLACE "\n.*" "" MPI_Fortran_LIBRARY_VERSION_STRING_FIRST_LINE ${MPI_Fortran_LIBRARY_VERSION_STRING})
    # Now we need to grab the last word from the first line of the string
    string(REGEX MATCH "[^ ]+$" MPI_STACK_VERSION ${MPI_Fortran_LIBRARY_VERSION_STRING_FIRST_LINE})
    # Now we need to remove any colons, spaces, tabs, etc., but keep dots and letters.
    string(REGEX REPLACE "[^a-zA-Z0-9.]" "" MPI_STACK_VERSION ${MPI_STACK_VERSION})
  elseif(MPI_Fortran_LIBRARY_VERSION_STRING MATCHES "Open MPI")
    set(MPI_STACK openmpi)
    list(GET MPI_Fortran_LIBRARY_VERSION_LIST 2 DETECTED_MPI_STACK_VERSION_STRING_WITH_COMMA)
    string(REPLACE "," "" DETECTED_MPI_STACK_VERSION_STRING_WITH_V ${DETECTED_MPI_STACK_VERSION_STRING_WITH_COMMA})
    string(REPLACE "v" "" MPI_STACK_VERSION        ${DETECTED_MPI_STACK_VERSION_STRING_WITH_V})
  else()
    message (FATAL_ERROR "ERROR: MPI_STACK autodetection failed. Must specify a value for MPI_STACK with cmake ... -DMPI_STACK=<mpistack>. The acceptable values are: intelmpi, mvapich, mpt, mpich, openmpi")
  endif()
  set(MPI_STACK_TYPE "Autodetected")
endif()

set(MPI_STACK "${MPI_STACK}" CACHE STRING "MPI_STACK Value")
set(MPI_STACK_VERSION "${MPI_STACK_VERSION}" CACHE STRING "MPI_STACK_VERSION Value")
message(STATUS "Using ${MPI_STACK_TYPE} MPI_STACK: ${MPI_STACK}. Version: ${MPI_STACK_VERSION}")

# Testing has show that Open MPI 5.0.0 and later along with GCC 13.2 and later
# cannot use the -ffpe-trap=zero flag and we sometimes pass in -ffpe-trap=zero,overflow
# So if we are using Open MPI 5 + GCC 13.2 or later, we need to remove the 'zero,' from the flags
# We also have to do it with each of the RELEASE, DEBUG, and AGGRESSIVE flags

string(TOUPPER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_UPPER)
message(STATUS "CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE_UPPER} before: ${CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}")

if (MPI_STACK STREQUAL "openmpi")
  if (CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    if (CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL "13.2")
      if (MPI_STACK_VERSION VERSION_GREATER_EQUAL "5.0.0")
        message(WARNING "Open MPI 5.0.0 and later along with GCC 13.2 and later cannot use the -ffpe-trap=zero flag. This will be removed from the flags.")
        string(REPLACE "${TRAP_ZERO}" "" CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE_UPPER} ${CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE_UPPER}})
      endif()
    endif()
  endif()
endif()

message(STATUS "CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE_UPPER} after: ${CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}")
