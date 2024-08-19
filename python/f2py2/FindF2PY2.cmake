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
#   F2PY2_EXECUTABLE      - absolute path to the F2PY2 executable
#
# ::
#
#   F2PY2_VERSION_STRING  - the version of F2PY2 found
#   F2PY2_VERSION_MAJOR   - the F2PY2 major version
#   F2PY2_VERSION_MINOR   - the F2PY2 minor version
#   F2PY2_VERSION_PATCH   - the F2PY2 patch version
#
#
# .. note::
#
#   By default, the module finds the F2PY2 program associated with the installed NumPy package.
#

# It turns out that on machines where Python2 does not exist, this code will still
# find plain "f2py" and think that is f2py2. Even if you remove f2py from the find_program
# call below, it still finds that. So instead, we must disable this code if no Python2
# interpreter is found.

# Find the Python2 interpreter which must exist else we cannot find f2py2
find_package(Python2 COMPONENTS Interpreter QUIET)

# If we do not have a Python2 interpreter, we cannot find f2py2 and we are done
if(NOT Python2_FOUND)
  message(WARNING "[F2PY2]: Python2 interpreter not found, we will not search for f2py2. This means f2py2 libraries will not be built. Please convert your code to Python3.")
  set(F2PY2_FOUND FALSE)
  return()
endif()

# Path to the f2py2 executable
find_program(F2PY2_EXECUTABLE NAMES "f2py${Python2_VERSION_MAJOR}.${Python2_VERSION_MINOR}"
                                    "f2py-${Python2_VERSION_MAJOR}.${Python2_VERSION_MINOR}"
                                    "f2py${Python2_VERSION_MAJOR}"
                                    "f2py"
                                    )

if(F2PY2_EXECUTABLE)
   # extract the version string
   execute_process(COMMAND "${F2PY2_EXECUTABLE}" -v
                     OUTPUT_VARIABLE F2PY2_VERSION_STRING
                     OUTPUT_STRIP_TRAILING_WHITESPACE)
   if("${F2PY2_VERSION_STRING}" MATCHES "^([0-9]+)(.([0-9+]))?(.([0-9+]))?$")
      set(F2PY2_VERSION_MAJOR "${CMAKE_MATCH_1}")
      set(F2PY2_VERSION_MINOR "${CMAKE_MATCH_3}")
      set(F2PY2_VERSION_PATCH "${CMAKE_MATCH_5}")
   endif()

   # Now we need to test if we can actually use f2py2 and what its suffix is

   if (NOT F2PY2_SUFFIX)
      include(try_f2py2_compile)
      try_f2py2_compile(
         ${CMAKE_CURRENT_LIST_DIR}/test.F90
         DETECT_F2PY2_SUFFIX
         )
   endif ()

endif ()

# handle the QUIET and REQUIRED arguments and set F2PY2_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(F2PY2
   REQUIRED_VARS F2PY2_EXECUTABLE F2PY2_SUFFIX
   VERSION_VAR F2PY2_VERSION_STRING
   )

mark_as_advanced(F2PY2_EXECUTABLE F2PY2_SUFFIX)

if (F2PY2_FOUND)
   include(UseF2Py2)
endif ()
