# Most users of this software do not (should not?) have permissions to
# install in the cmake default of /usr/local (or equiv on other os's).
# Below, the default is changed to a directory within the build tree
# unless the user explicitly sets CMAKE_INSTALL_PREFIX in the cache.
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "default install path" FORCE )
    message(STATUS "*** Setting default install prefix to ${CMAKE_INSTALL_PREFIX}.")
    message(STATUS "*** Override with -DCMAKE_INSTALL_PREFIX=<path>.")
endif()

### ecbuild Support ###

# Bring in ecbuild
if (IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/ecbuild")
  list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/ecbuild/cmake")
elseif (IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/@ecbuild")
  list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/@ecbuild/cmake")
elseif (IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/ecbuild@")
  list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/ecbuild@/cmake")
else ()
  find_package(ecbuild REQUIRED)
endif()
option(BUILD_SHARED_LIBS "Build the shared library" OFF)
set (ECBUILD_2_COMPAT_VALUE OFF)
include (ecbuild_system NO_POLICY_SCOPE)

### Compiler Support ###

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/compiler")
include (esma_compiler)

### ESMA Support ###

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/esma_support")
include (esma_check_if_debug)
include (esma_set_this)
include (esma_add_subdirectories)
include (esma_add_library)
include (esma_generate_automatic_code)
include (esma_create_stub_component)
include (esma_fortran_generator_list)

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

### OpenMP ###

find_package (OpenMP)

### Threading ###

set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)

### Position independent code ###

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

### MPI Support ###

# Only invoked from Fortran sources in GEOS-5,  But some BASEDIR packages use MPI from C/C++.
set(MPI_DETERMINE_LIBRARY_VERSION TRUE)
find_package (MPI REQUIRED)


option (ESMA_ALLOW_DEPRECATED "suppress warnings about deprecated features" ON)
# Temporary option for transition purposes.
option (ESMA_USE_GFE_NAMESPACE "use cmake namespace with GFE projects" ON)

set (XFLAGS "" CACHE STRING "List of extra FPP options that will be passed to select source files.")
set (XFLAGS_SOURCES "" CACHE STRING "List of sources to which XFLAGS will be applied.")

### External Libraries Support ###

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/external_libraries")
include(math_libraries)
include(FindBaselibs)
find_package(GitInfo)

# On install, print 'Installing' but not 'Up-to-date' messages.
set (CMAKE_INSTALL_MESSAGE LAZY)

# This is a "stub" macro to detect building within an ESMA project (for MAPL standalone)
macro (esma)

endmacro ()

# ecbuild by default puts modules in build-dir/module. This can cause issues if same-named modules
# are in two directories that aren't using esma_add_library(). This sets the the value to
# nothing with puts modules in the build directory equivalent of the source directory
set(CMAKE_Fortran_MODULE_DIRECTORY "" CACHE PATH "Fortran module directory default" FORCE)
