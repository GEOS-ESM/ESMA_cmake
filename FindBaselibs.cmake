
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
find_package(GFTL REQUIRED)

# Find GFTL_SHARED
set(GFTL_SHARED_IS_REQUIRED_ARG "" CACHE STRING "Argument in GFTL_SHARED's find_package call")
mark_as_advanced(GFTL_SHARED_IS_REQUIRED_ARG)
find_package(GFTL_SHARED ${GFTL_SHARED_IS_REQUIRED_ARG} CONFIG)

# Find FARGPARSE
set(FARGPARSE_IS_REQUIRED_ARG "" CACHE STRING "Argument in FARGPARSE's find_package call")
mark_as_advanced(FARGPARSE_IS_REQUIRED_ARG)
find_package(FARGPARSE CONFIG)

# Find FLAP
set(FLAP_IS_REQUIRED_ARG "REQUIRED" CACHE STRING "Argument in FLAP's find_package call")
mark_as_advanced(FLAP_IS_REQUIRED_ARG)
find_package(FLAP ${FLAP_IS_REQUIRED_ARG} CONFIG)
# Set non-standard expected variables
set (INC_FLAP ${FLAP_INCLUDE_DIRS})
set (LIB_FLAP ${FLAP_LIBRARIES})

# Find ESMF
find_package(ESMF REQUIRED)
# Set non-standard expected variables
set(INC_ESMF ${ESMF_INCLUDE_DIRS})

# Find MPI
find_package(MPI REQUIRED COMPONENTS C CXX Fortran)

# Conditionally find PFUNIT
if (PFUNIT)
  find_package(PFUNIT REQUIRED CONFIG)
endif()

if(BASEDIR)
  # BASEDIR.rc file does not have the arch
  string(REPLACE "/${CMAKE_SYSTEM_NAME}" "" BASEDIR_WITHOUT_ARCH ${BASEDIR})
  set(BASEDIR_WITHOUT_ARCH ${BASEDIR_WITHOUT_ARCH} CACHE STRING "BASEDIR without arch")
  mark_as_advanced(BASEDIR_WITHOUT_ARCH)
endif()

# Set the site variable
include(DetermineSite)


# Make Baselibs target
add_library(Baselibs INTERFACE)
target_include_directories(Baselibs INTERFACE ${NETCDF_INCLUDE_DIRS})
target_link_libraries(Baselibs INTERFACE 
    $<$<TARGET_EXISTS:gftl-shared>:gftl-shared>
    $<$<TARGET_EXISTS:fargparse>:fargparse>
    $<$<TARGET_EXISTS:FLAP>:FLAP>
    $<$<TARGET_EXISTS:pfunit>:pfunit>
    gftl ESMF
    MPI::MPI_C MPI::MPI_CXX MPI::MPI_Fortran
    OpenMP::OpenMP_Fortran
  )
target_compile_options(Baselibs INTERFACE
	$<$<COMPILE_LANGUAGE:Fortran>:
		$<$<OR:$<CONFIG:Release>,$<CONFIG:RelWithDebInfo>,$<CONFIG:MinSizeRel>>:${GEOS_Fortran_FLAGS_RELEASE}>
  		$<$<CONFIG:Debug>:${GEOS_Fortran_FLAGS_DEBUG}>
	>
	""
  )
target_compile_definitions(Baselibs INTERFACE
  HAS_NETCDF4
  HAS_NETCDF3
  H5_HAVE_PARALLEL
  NETCDF_NEED_NF_MPIIO
  HAS_NETCDF3
  )
install(TARGETS Baselibs EXPORT MAPL-targets)
