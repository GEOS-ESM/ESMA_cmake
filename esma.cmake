# Most users of this software do not (should not?) have permissions to
# install in the cmake default of /usr/local (or equiv on other os's).
# So, below, we require the user to pass in a CMAKE_INSTALL_PREFIX
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    message(STATUS "*** ERROR ***")
    message(STATUS "You have not specified an install path for this project.")
    message(STATUS "*** Please re-run CMake with -DCMAKE_INSTALL_PREFIX=<path>.")
    message(FATAL_ERROR "Configuration stopped.")
endif()

# Bring in ecbuild
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/@ecbuild/cmake")
set (BUILD_SHARED_LIBS OFF)
set (ECBUILD_2_COMPAT_VALUE OFF)
include (ecbuild_system NO_POLICY_SCOPE)


list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/check_compiler_support")
include ("${CMAKE_Fortran_COMPILER_ID}")
include (check_fortran_support)
include (esma_check_if_debug)
include (esma_set_this)
include (esma_add_subdirectories)
include (esma_add_library)
include (esma_generate_automatic_code)
include (esma_create_stub_component)
include (esma_fortran_generator_list)

include (UseProTeX)
set (protex_flags -g -b -f)

set (LATEX_COMPILER pdflatex)
include (UseLatex)

if (APPLE)
  include(osx_extras)
endif ()

# OpenMP support
find_package (OpenMP)

# Threading support
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)

# Position independent code
set(CMAKE_POSITION_INDEPENDENT_CODE ON)


# MPI Support - only invoked from Fortran sources in GEOS-5.
# But some BASEDIR packages use MPI from C/C++.
find_package (MPI REQUIRED)

if (APPLE)
  if (DEFINED ENV{MKLROOT})
    set (MKL_Fortran)
    find_package (MKL REQUIRED)
  else ()
    if ("${CMAKE_Fortran_COMPILER_ID}" MATCHES "GNU")
      #USE FRAMEWORK
      message(STATUS "Found macOS and gfortran, using framework Accelerate")
      link_libraries("-framework Accelerate")
    endif ()
  endif ()
else ()
  find_package (MKL REQUIRED)
endif ()

# Unit testing
set (PFUNIT OFF CACHE BOOL "Activate pfunit based tests")
if (PFUNIT)
   add_custom_target(tests COMMAND ${CMAKE_CTEST_COMMAND})
endif ()

# Baselibs ...
include (FindBaselibs)

enable_testing()
set (CMAKE_INSTALL_MESSAGE LAZY)

# This is a "stub" macro to detect building within an ESMA project (for MAPL standalone)
macro (esma)

endmacro ()

find_package(GitInfo)
