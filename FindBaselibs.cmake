
# Set BASEDIR to non-existant path if it is not already set
set (BASEDIR /does-not-exist CACHE PATH "Path to installed baselibs _including_ OS subdirectory (Linux or Darwin).")

# If BASEDIR evaluates to TRUE but it isn't a valid path throw an error
# This lets BASEDIR be skipped if BASEDIR is set to a false value (e.g. setting BASEDIR to IGNORE)
if (BASEDIR AND NOT EXISTS ${BASEDIR})
  message (FATAL_ERROR "ERROR: Must specify a value for BASEDIR with cmake ... -DBASEDIR=<path>.")
elseif(EXISTS ${BASEDIR})
  # Add path to GFE packages
  list (APPEND CMAKE_PREFIX_PATH ${BASEDIR} 

    # Add BASEDIR's include directories
    ${BASEDIR}/include/netcdf
    ${BASEDIR}/include/hdf5
    ${BASEDIR}/include/hdf
    ${BASEDIR}/include/esmf
    ${BASEDIR}/include/FLAP
    )
endif ()
if (ESMA_SDF)
  message (FATAL_ERROR "ERROR: -hdf option was thought to be obsolete when CMake was crafted.")
endif ()

# Find NetCDF
find_package(NetCDF REQUIRED COMPONENTS C Fortran)
# Set non-standard expected variables
set(INC_NETCDF ${NETCDF_INCLUDE_DIRS})
set(LIB_NETCDF ${NETCDF_LIBRARIES})

# If BASEDIR exists, set the expected HDF and HDF5 variables
if(EXISTS ${BASEDIR}/include/hdf5)
  set (INC_HDF5 ${BASEDIR}/include/hdf5)
endif()
if(EXISTS ${BASEDIR}/include/hdf)
  set (INC_HDF ${BASEDIR}/include/hdf)
endif()

# Find GFTL 
set(GFTL_IS_REQUIRED_ARG "REQUIRED" CACHE STRING "Argument in GFTL's find_package call")
mark_as_advanced(GFTL_IS_REQUIRED_ARG)
find_package(GFTL ${GFTL_IS_REQUIRED_ARG} CONFIG)

# Find GFTL_SHARED
set(GFTL_SHARED_IS_REQUIRED_ARG "" CACHE STRING "Argument in GFTL_SHARED's find_package call")
mark_as_advanced(GFTL_SHARED_IS_REQUIRED_ARG)
find_package(GFTL_SHARED ${GFTL_SHARED_IS_REQUIRED_ARG} CONFIG)

# Find FARGPARSE
set(FARGPARSE_IS_REQUIRED_ARG "" CACHE STRING "Argument in FARGPARSE's find_package call")
mark_as_advanced(FARGPARSE_IS_REQUIRED_ARG)
find_package(FARGPARSE ${FARGPARSE_IS_REQUIRED_ARG} CONFIG)

# Find FLAP
set(FLAP_IS_REQUIRED_ARG "REQUIRED" CACHE STRING "Argument in FLAP's find_package call")
mark_as_advanced(FLAP_IS_REQUIRED_ARG)
find_package(FLAP ${FLAP_IS_REQUIRED_ARG} CONFIG)

# Find ESMF
find_package(ESMF REQUIRED)
# Set non-standard expected variables
set(INC_ESMF ${ESMF_INCLUDE_DIRS})

# Find MPI
find_package(MPI REQUIRED COMPONENTS C CXX Fortran)

# Unit testing
# option (PFUNIT "Activate pfunit based tests" OFF)
find_package(PFUNIT QUIET)
if (PFUNIT_FOUND)
  add_custom_target(tests COMMAND ${CMAKE_CTEST_COMMAND})
endif ()

if(BASEDIR)
  # BASEDIR.rc file does not have the arch
  string(REPLACE "/${CMAKE_SYSTEM_NAME}" "" BASEDIR_WITHOUT_ARCH ${BASEDIR})
  set(BASEDIR_WITHOUT_ARCH ${BASEDIR_WITHOUT_ARCH} CACHE STRING "BASEDIR without arch")
  mark_as_advanced(BASEDIR_WITHOUT_ARCH)
endif()

# Set the site variable
include(DetermineSite)