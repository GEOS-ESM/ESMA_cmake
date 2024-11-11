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
#   F2PY3_EXECUTABLE      - absolute path to the F2PY3 executable
#
# ::
#
#   F2PY3_VERSION_STRING  - the version of F2PY3 found
#   F2PY3_VERSION_MAJOR   - the F2PY3 major version
#   F2PY3_VERSION_MINOR   - the F2PY3 minor version
#   F2PY3_VERSION_PATCH   - the F2PY3 patch version
#
#
# .. note::
#
#   By default, the module finds the F2PY3 program associated with the installed NumPy package.
#

# Path to the f2py3 executable
find_program(F2PY3_EXECUTABLE NAMES "f2py${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}"
                                    "f2py-${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}"
                                    "f2py${Python3_VERSION_MAJOR}"
                                    "f2py"
                                    )

if(F2PY3_EXECUTABLE)
   # extract the version string
   execute_process(COMMAND "${F2PY3_EXECUTABLE}" -v
                   OUTPUT_VARIABLE F2PY3_VERSION_STRING
                   OUTPUT_STRIP_TRAILING_WHITESPACE)
   if("${F2PY3_VERSION_STRING}" MATCHES "^([0-9]+)(.([0-9+]))?(.([0-9+]))?$")
      set(F2PY3_VERSION_MAJOR "${CMAKE_MATCH_1}")
      set(F2PY3_VERSION_MINOR "${CMAKE_MATCH_3}")
      set(F2PY3_VERSION_PATCH "${CMAKE_MATCH_5}")
   endif()

   # Testing has shown that f2py3 with Python 3.12+ needs to set
   # a new CMake policy, CMP0132, because f2py3 uses Meson in the
   # instead of distutils.
   # See https://github.com/mesonbuild/meson/issues/13882
   if (F2PY_VERSION_MAJOR GREATER_EQUAL 3 AND F2PY_VERSION_MINOR GREATER_EQUAL 12)
      cmake_policy(SET CMP0132 NEW)
    endif ()

   # Get the compiler-id and map it to compiler vendor as used by f2py3.
   # Currently, we only check for GNU, but this can easily be extended.
   # Cache the result, so that we only need to check once.
   if(NOT F2PY3_FCOMPILER)
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

     set(F2PY3_FCOMPILER ${_fcompiler} CACHE STRING
       "F2PY3: Fortran compiler type by vendor" FORCE)

     if(NOT F2PY3_FCOMPILER)
       message(FATAL_ERROR "[F2PY3]: Could not determine Fortran compiler type. ")
     endif(NOT F2PY3_FCOMPILER)
   endif(NOT F2PY3_FCOMPILER)

   # Now we need to test if we can actually use f2py and what its suffix is

   if (NOT F2PY3_SUFFIX)
      include(try_f2py3_compile)
      try_f2py3_compile(
         ${CMAKE_CURRENT_LIST_DIR}/test.F90
         DETECT_F2PY3_SUFFIX
         )
   endif ()

endif ()

# handle the QUIET and REQUIRED arguments and set F2PY3_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(F2PY3
   REQUIRED_VARS F2PY3_EXECUTABLE F2PY3_SUFFIX F2PY3_FCOMPILER
   VERSION_VAR F2PY3_VERSION_STRING
   )

mark_as_advanced(F2PY3_EXECUTABLE F2PY3_SUFFIX F2PY3_FCOMPILER)

if (F2PY3_FOUND)
   include(UseF2Py3)
endif ()
