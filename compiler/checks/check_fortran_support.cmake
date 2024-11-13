include (try_fortran_compile)

try_fortran_compile(
  ${CMAKE_CURRENT_LIST_DIR}/assumed_type.F90
  FORTRAN_COMPILER_SUPPORTS_ASSUMED_TYPE
  )
try_fortran_compile(
  ${CMAKE_CURRENT_LIST_DIR}/findloc.F90
  FORTRAN_COMPILER_SUPPORTS_FINDLOC
  )

# We also need to do something if we are using Intel Fortran Classic
# Namely, we need to know if when we run just plain 'ifort' if
# anything is output to stderr. If so, we need to set a CMake variable
# that will allow us to do something different later in the
# CMake process.

if (CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
  if (NOT CMAKE_REQUIRED_QUIET)
    message (STATUS "Checking if Intel Fortran Classic compiler has deprecation warning")
  endif ()
  execute_process(
    COMMAND ${CMAKE_Fortran_COMPILER} --version
    OUTPUT_QUIET
    RESULT_VARIABLE IFORT_RESULT
    ERROR_VARIABLE IFORT_STDERR
    )
  if (IFORT_STDERR)
    message (STATUS "Checking if Intel Fortran Classic compiler has deprecation warning: FOUND")
    message (STATUS "Setting IFORT_HAS_DEPRECATION_WARNING to TRUE")
    set (IFORT_HAS_DEPRECATION_WARNING TRUE)
  else ()
    message (STATUS "Checking if Intel Fortran Classic compiler has deprecation warning: NOT FOUND")
  endif ()
endif ()
