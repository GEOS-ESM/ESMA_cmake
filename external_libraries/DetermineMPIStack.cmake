# This code will try and determine the MPI stack being used and set the MPI_STACK variable

include(CMakePrintHelpers)

set(ALLOWED_MPI_STACKS "intelmpi;mvapich;mpt;mpich;openmpi")

# Define a helper variable to track whether the block was processed
# This let's us avoid weird warnings since MPI_STACK was defined
# in the first run
if (NOT DEFINED MPI_STACK_PROCESSED)
  set(MPI_STACK_PROCESSED OFF CACHE INTERNAL "Flag to track if MPI_STACK block was processed")
endif()

if (NOT MPI_STACK_PROCESSED)
  set(MPI_STACK_PROCESSED ON CACHE INTERNAL "Flag to track if MPI_STACK block was processed")
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
else ()
  message(STATUS "MPI_STACK previously detected.")
  set(MPI_STACK_TYPE "Previously Detected")
endif ()
message(STATUS "Using ${MPI_STACK_TYPE} MPI_STACK: ${MPI_STACK}. Version: ${MPI_STACK_VERSION}")
