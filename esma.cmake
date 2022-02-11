# Most users of this software do not (should not?) have permissions to
# install in the cmake default of /usr/local (or equiv on other os's).
# Below, the default is changed to a directory within the build tree
# unless the user explicitly sets CMAKE_INSTALL_PREFIX in the cache.
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "default install path" FORCE )
    message(STATUS "*** Setting default install prefix to ${CMAKE_INSTALL_PREFIX}.")
    message(STATUS "*** Override with -DCMAKE_INSTALL_PREFIX=<path>.")
endif()

# There is an issue with CMake, make, and directories with commas 
# in the path. CMake can add -Wl linker options to the makefiles and
# Wl options take comma-separated lists. Until it can be figured out 
# how (or if) CMake can generate quoted arguments to -Wl, we prevent
# either build or install directories with a comma in the path
if ("${CMAKE_BINARY_DIR}" MATCHES "^.*[,].*$")
  message(FATAL_ERROR
    "CMAKE_BINARY_DIR: ${CMAKE_BINARY_DIR}\n"
    "GEOS does not allow directory paths with commas. Please change your build path"
    )
endif ()
if ("${CMAKE_INSTALL_PREFIX}" MATCHES "^.*[,].*$")
  message(FATAL_ERROR
    "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}\n"
    "GEOS does not allow directory paths with commas. Please change your install path"
    )
endif ()

### ecbuild Support ###

# Bring in ecbuild
if (IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/ecbuild")
  list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/ecbuild/cmake")
elseif (IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/@ecbuild")
  list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/@ecbuild/cmake")
elseif (IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/ecbuild@")
  list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/ecbuild@/cmake")
else (ESMA_ECBUILD_DIR)
  if (IS_DIRECTORY ${ESMA_ECBUILD_DIR}/cmake)
    list(APPEND CMAKE_MODULE_PATH "${ESMA_ECBUILD_DIR}/cmake")
  endif()
else ()
  find_package(ecbuild REQUIRED)
endif()
option(BUILD_SHARED_LIBS "Build the shared library" OFF)
set (ECBUILD_2_COMPAT_VALUE OFF)
include (ecbuild_system NO_POLICY_SCOPE)

### Compiler Support ###

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/compiler")
include (esma_compiler)

### OpenMP ###

find_package (OpenMP)

### Position independent code ###

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

### MPI Support ###

# Only invoked from Fortran sources in GEOS-5,  But some BASEDIR packages use MPI from C/C++.
set(MPI_DETERMINE_LIBRARY_VERSION TRUE)
find_package (MPI REQUIRED)

### Threading ###

set(CMAKE_THREAD_PREFER_PTHREAD TRUE)

## Turns out with NAG on Linux, this generates '-pthread' which
## NAG cannot handle. So we set to FALSE in that case
if(UNIX AND CMAKE_Fortran_COMPILER_ID MATCHES "NAG")
  set(THREADS_PREFER_PTHREAD_FLAG FALSE)
else()
  set(THREADS_PREFER_PTHREAD_FLAG TRUE)
endif()

find_package(Threads REQUIRED)

### External Libraries Support ###

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/external_libraries")
include(math_libraries)
include(FindBaselibs)
find_package(GitInfo)

### ESMA Support ###

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/esma_support")
include (esma_support)

### Python ###

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/python")
include(esma_python)

### LaTeX ###

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/latex")
include(esma_latex)

### macOS ###

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/operating_system")
if (APPLE)
  include(osx_extras)
endif ()

option (ESMA_ALLOW_DEPRECATED "suppress warnings about deprecated features" ON)
# Temporary option for transition purposes.
option (ESMA_USE_GFE_NAMESPACE "use cmake namespace with GFE projects" ON)

set (XFLAGS "" CACHE STRING "List of extra FPP options that will be passed to select source files.")
set (XFLAGS_SOURCES "" CACHE STRING "List of sources to which XFLAGS will be applied.")

# On install, print 'Installing' but not 'Up-to-date' messages.
set (CMAKE_INSTALL_MESSAGE LAZY)

# This is a "stub" macro to detect building within an ESMA project (for MAPL standalone)
macro (esma)

endmacro ()

# ecbuild by default puts modules in build-dir/module. This can cause issues if same-named modules
# are in two directories that aren't using esma_add_library(). This sets the the value to
# nothing with puts modules in the build directory equivalent of the source directory
set(CMAKE_Fortran_MODULE_DIRECTORY "" CACHE PATH "Fortran module directory default" FORCE)
