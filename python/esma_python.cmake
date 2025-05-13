# CMake code involving Python

# FIND_STRATEGY needs CMake 3.15 or later
# The new policy needed for f2py3 and Meson is 3.24
cmake_minimum_required(VERSION 3.24)

# Note f2py (-> distutils) does seem to support nagfor as an fcompiler, but
# testing with it did not work. For now, just don't do any f2py if using NAG
if (CMAKE_Fortran_COMPILER_ID MATCHES "NAG")
  option(USE_F2PY "Turn on F2PY builds" OFF)
else ()
  option(USE_F2PY "Turn on F2PY builds" ON)
endif ()

# Find Python
set(Python_FIND_STRATEGY LOCATION)
set(Python_FIND_UNVERSIONED_NAMES FIRST)
set(Python_FIND_FRAMEWORK LAST)
find_package(Python COMPONENTS Interpreter)
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/f2py")
include (esma_find_python_module)
include (esma_check_python_module)
if (USE_F2PY)
  include (esma_add_f2py_module)
endif ()

# Find Python2
set(Python2_FIND_STRATEGY LOCATION)
set(Python2_FIND_UNVERSIONED_NAMES FIRST)
set(Python2_FIND_FRAMEWORK LAST)
find_package(Python2 COMPONENTS Interpreter)
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/f2py2")
include (esma_find_python2_module)
include (esma_check_python2_module)
if (USE_F2PY)
  include (esma_add_f2py2_module)
endif ()

# Find Python3
set(Python3_FIND_STRATEGY LOCATION)
set(Python3_FIND_UNVERSIONED_NAMES FIRST)
set(Python3_FIND_FRAMEWORK LAST)
find_package(Python3 COMPONENTS Interpreter)
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/f2py3")
include (esma_find_python3_module)
include (esma_check_python3_module)
if (USE_F2PY)
  include (esma_add_f2py3_module)
endif ()

