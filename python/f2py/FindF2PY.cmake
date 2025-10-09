# MAT This code is based, loosely, on the FindF2PY.cmake file from scikit
#.rst:
#
# The purpose of the F2PY –Fortran to Python interface generator– project is to provide a
# connection between Python and Fortran languages.
#
# F2PY is a Python package (with a command line tool f2py and a module f2py2e) that facilitates
# creating/building Python C/API extension modules that make it possible to call Fortran 77/90/95
# external subroutines and Fortran 90/95 module subroutines as well as C functions; to access Fortran
# 77 COMMON blocks and Fortran 90/95 module data, including allocatable arrays from Python.
#
# For more information on the F2PY project, see http://www.f2py.com/.
#
# The following variables are defined:
#
# ::
#
#   F2PY_EXECUTABLE      - absolute path to the F2PY executable
#
# ::
#
#   F2PY_VERSION_STRING  - the version of F2PY found
#   F2PY_VERSION_MAJOR   - the F2PY major version
#   F2PY_VERSION_MINOR   - the F2PY minor version
#   F2PY_VERSION_PATCH   - the F2PY patch version
#
#
# .. note::
#
#   By default, the module finds the F2PY program associated with the installed NumPy package.
#

# Path to the f2py executable

## We might have an odd circumstance where there are a couple f2py around. As such,
## we need to find the one that matches the Python_EXECUTABLE. This is a bit of a
## hack, but it should work for most cases.

## Find the directory where the Python_EXECUTABLE is located
message(DEBUG "[F2PY]: Searching for f2py executable associated with Python_EXECUTABLE: ${Python_EXECUTABLE}")
get_filename_component(Python_EXECUTABLE_DIR ${Python_EXECUTABLE} DIRECTORY)
message(DEBUG "[F2PY]: Python executable directory: ${Python_EXECUTABLE_DIR}")

find_program(F2PY_EXECUTABLE
  NAMES "f2py${Python_VERSION_MAJOR}"
        "f2py${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}"
        "f2py-${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}"
        "f2py"
  PATHS ${Python_EXECUTABLE_DIR}
  HINTS ${Python_EXECUTABLE_DIR}
)

message(DEBUG "[F2PY]: Found f2py executable: ${F2PY_EXECUTABLE}")

# Now as a sanity check, we need to make sure that the f2py executable is
# actually the one that is associated with the Python_EXECUTABLE
get_filename_component(F2PY_EXECUTABLE_DIR ${F2PY_EXECUTABLE} DIRECTORY)
message(DEBUG "[F2PY]: f2py executable directory: ${F2PY_EXECUTABLE_DIR}")

# Now we issue a WARNING. We can't do more than that because of things like Spack
# where f2py will be in a different location than python.
if (NOT "${F2PY_EXECUTABLE_DIR}" STREQUAL "${Python_EXECUTABLE_DIR}")
  message(WARNING
    "[F2PY]: The f2py executable [${F2PY_EXECUTABLE}] found is not the one associated with the Python_EXECUTABLE [${Python_EXECUTABLE}].\n"
    "Please check your Python environment if this is not expected (for example, not a Spack install) or build with -DUSE_F2PY=OFF.")
endif ()

if(F2PY_EXECUTABLE)
   # extract the version string
   execute_process(COMMAND "${F2PY_EXECUTABLE}" -v
                   OUTPUT_VARIABLE F2PY_VERSION_STRING
                   OUTPUT_STRIP_TRAILING_WHITESPACE)
   if("${F2PY_VERSION_STRING}" MATCHES "^([0-9]+)(.([0-9+]))?(.([0-9+]))?$")
      set(F2PY_VERSION_MAJOR "${CMAKE_MATCH_1}")
      set(F2PY_VERSION_MINOR "${CMAKE_MATCH_3}")
      set(F2PY_VERSION_PATCH "${CMAKE_MATCH_5}")
   endif()

   # Testing has shown that f2py with Python 3.12+ needs to set
   # a new CMake policy, CMP0132, because f2py uses Meson in the
   # instead of distutils.
   # See https://github.com/mesonbuild/meson/issues/13882
   if (Python_VERSION_MINOR GREATER_EQUAL 12)
     message(STATUS "[F2PY]: Setting CMP0132 policy to NEW")
     cmake_policy(SET CMP0132 NEW)
   endif ()

   # Get the compiler-id and map it to compiler vendor as used by f2py.
   # Currently, we only check for GNU, but this can easily be extended.
   # Cache the result, so that we only need to check once.
   if(NOT F2PY_FCOMPILER)
     if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
       if(CMAKE_Fortran_COMPILER_SUPPORTS_F90)
         set(_fcompiler "gnu95")
       else(CMAKE_Fortran_COMPILER_SUPPORTS_F90)
         set(_fcompiler "gnu")
       endif(CMAKE_Fortran_COMPILER_SUPPORTS_F90)
     elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
       set(_fcompiler "intelem")
     elseif(CMAKE_Fortran_COMPILER_ID MATCHES "NVHPC")
       set(_fcompiler "nv")
     endif()

     set(F2PY_FCOMPILER ${_fcompiler} CACHE STRING
       "F2PY: Fortran compiler type by vendor" FORCE)
     message(DEBUG "[F2PY]: Fortran compiler type: ${F2PY3_FCOMPILER}")

     if(NOT F2PY_FCOMPILER)
       message(FATAL_ERROR "[F2PY]: Could not determine Fortran compiler type. ")
     endif(NOT F2PY_FCOMPILER)
   endif(NOT F2PY_FCOMPILER)

   # Now we need to test if we can actually use f2py and what its suffix is

   if (NOT F2PY_SUFFIX)
      include(try_f2py_compile)
      try_f2py_compile(
         ${CMAKE_CURRENT_LIST_DIR}/test.F90
         DETECT_F2PY_SUFFIX
         )
   endif ()

endif ()

# handle the QUIET and REQUIRED arguments and set F2PY_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(F2PY
   REQUIRED_VARS F2PY_EXECUTABLE F2PY_SUFFIX
   VERSION_VAR F2PY_VERSION_STRING
   )

mark_as_advanced(F2PY_EXECUTABLE F2PY_SUFFIX)

if (F2PY_FOUND)
   include(UseF2Py)
endif ()
