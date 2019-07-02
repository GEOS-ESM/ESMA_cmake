set (BASEDIR /does-not-exist CACHE PATH "Path to installed baselibs _including_ OS subdirectory (Linux or Darwin).")

if (NOT EXISTS ${BASEDIR})
  message (FATAL_ERROR "ERROR: Must specify a value for BASEDIR with cmake ... -DBASEDIR=<path>.")
endif ()
if (ESMA_SDF)
  message (FATAL_ERROR "ERROR: -hdf option was thought to be obsolete when CMake was crafted.")
endif ()

link_directories (${BASEDIR}/lib)

# Add path to GFE packages
list (APPEND CMAKE_PREFIX_PATH ${BASEDIR})

#------------------------------------------------------------------
# netcdf
# The following command provides the list of libraries that netcdf
# uses.  Unfortunately it also includes the library path and "-l"
# prefixes, which CMake handles in a different manner. So we need so
# strip off that item from the list
execute_process (
  COMMAND ${BASEDIR}/bin/nf-config --flibs
  OUTPUT_VARIABLE LIB_NETCDF
  )

string(REGEX MATCHALL " -l[^ ]*" _full_libs "${LIB_NETCDF}")
set (NETCDF_LIBRARIES_OLD)
foreach (lib ${_full_libs})
  string (REPLACE "-l" "" _tmp ${lib})
  string (STRIP ${_tmp} _tmp)
  list (APPEND NETCDF_LIBRARIES_OLD ${_tmp})
endforeach()

list (REVERSE NETCDF_LIBRARIES_OLD)
list (REMOVE_DUPLICATES NETCDF_LIBRARIES_OLD)
list (REVERSE NETCDF_LIBRARIES_OLD)

add_definitions(-DHAS_NETCDF4)
add_definitions(-DHAS_NETCDF3)
add_definitions(-DH5_HAVE_PARALLEL)
add_definitions(-DNETCDF_NEED_NF_MPIIO)
add_definitions(-DHAS_NETCDF3)
#------------------------------------------------------------------

set (INC_HDF5 ${BASEDIR}/include/hdf5)
set (INC_NETCDF ${BASEDIR}/include/netcdf)
set (INC_HDF ${BASEDIR}/include/hdf)
set (INC_ESMF ${BASEDIR}/include/esmf)

find_package(GFTL REQUIRED)
find_package(GFTL_SHARED)
find_package(FARGPARSE)

set (INC_FLAP ${BASEDIR}/include/FLAP)
set (LIB_FLAP ${BASEDIR}/lib/libflap.a)
if (NOT EXISTS ${INC_FLAP})
  message (FATAL_ERROR  "FLAP directory, ${INC_FLAP} does not exist.")
endif ()

if (APPLE)
  if (NOT "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    execute_process (COMMAND ${CMAKE_C_COMPILER} --print-file-name=libgcc.a OUTPUT_VARIABLE libgcc OUTPUT_STRIP_TRAILING_WHITESPACE)
  endif ()
  execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libstdc++.dylib OUTPUT_VARIABLE stdcxx OUTPUT_STRIP_TRAILING_WHITESPACE)
else ()
  execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libstdc++.so OUTPUT_VARIABLE stdcxx OUTPUT_STRIP_TRAILING_WHITESPACE)
endif ()

# For OS X - use the gcc stdc++ library - not clang
#find_library (STDCxx
#  stdc++
#  HINTS "/opt/local/lib/gcc5"
#  )

# We must statically link ESMF on Apple due mainly to an issue with how Baselibs is built.
# Namely, the esmf dylib libraries end up with the full *build* path on Darwin (which is in 
# src/esmf/lib/libO...) But we copy the dylib to $BASEDIR/lib. Thus, DYLD_LIBRARY_PATH gets
# hosed. yay.

if (APPLE)
   set (ESMF_LIBRARY ${BASEDIR}/lib/libesmf.a)
else ()
   set (ESMF_LIBRARY esmf_fullylinked)
endif ()

#find_package (NetCDF REQUIRED COMPONENTS Fortran)
#set (INC_NETCDF ${NETCDF_INCLUDE_DIRS})

set (NETCDF_LIBRARIES ${NETCDF_LIBRARIES_OLD})
set (ESMF_LIBRARIES ${ESMF_LIBRARY} ${NETCDF_LIBRARIES} ${MPI_Fortran_LIBRARIES} ${MPI_CXX_LIBRARIES} ${stdcxx} ${libgcc})


if (PFUNIT)
  set (PFUNIT_PATH ${BASEDIR}/pFUnit/pFUnit-mpi)
  set (PFUNIT_LIBRARY_DIRS ${PFUNIT_PATH}/lib)
  set (PFUNIT_LIBRARIES ${PFUNIT_PATH}/lib/libpfunit.a)
  set (PFUNIT_INCLUDE_DIRS ${PFUNIT_PATH}/mod ${PFUNIT_PATH}/include)
endif ()

# BASEDIR.rc file does not have the arch
string(REPLACE "/${CMAKE_SYSTEM_NAME}" "" BASEDIR_WITHOUT_ARCH ${BASEDIR})
set(BASEDIR_WITHOUT_ARCH ${BASEDIR_WITHOUT_ARCH} CACHE STRING "BASEDIR without arch")
mark_as_advanced(BASEDIR_WITHOUT_ARCH)

# Set the site variable
include(DetermineSite)
