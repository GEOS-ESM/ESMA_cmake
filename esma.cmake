### Check install prefix

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/esma_support")
include (esma_check_install_prefix)
esma_check_install_prefix()

### ecbuild Support ###

# Bring in ecbuild
if (IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/ecbuild")
  list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/ecbuild/cmake")
elseif (IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/@ecbuild")
  list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/@ecbuild/cmake")
elseif (IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/ecbuild@")
  list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/ecbuild@/cmake")
elseif (ESMA_ECBUILD_DIR)
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

# MPI is now found in FindBaselibs

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
include(DetermineSite)
find_package(GitInfo)
include(DetermineMPIStack)

### ESMA Support ###

#list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/esma_support")
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
