set (Baselibs_FOUND FALSE CACHE BOOL "Baselibs Found")

# We want to detect if BASEDIR is set in the environment (but not on the command line)
if (NOT BASEDIR AND DEFINED ENV{BASEDIR})
  message (STATUS "BASEDIR not set on command line, but found BASEDIR in the environment")
  set (BASEDIR $ENV{BASEDIR})
  set (BASEDIR_FROM_ENVIRONMENT TRUE)
else ()
  set (BASEDIR_FROM_ENVIRONMENT FALSE)
endif ()

# Next, GEOS requires all BASEDIR to be of the format
# BASEDIR/ARCH/lib, say, where ARCH is the output of `uname -s`
# In CMake this is CMAKE_HOST_SYSTEM_NAME

if (BASEDIR)
  
  # First, what if we have a BASEDIR/lib, let's make sure it's like we want
  # That is, it has ARCH and it's the *right* ARCH!
  if (IS_DIRECTORY ${BASEDIR}/lib)

    # Get the last directory node in BASEDIR
    get_filename_component(SHOULD_BE_ARCH ${BASEDIR} NAME)

    # Test to make sure it's the right arch
    if (NOT SHOULD_BE_ARCH STREQUAL ${CMAKE_HOST_SYSTEM_NAME})
      message(FATAL_ERROR
        "GEOS requires that BASEDIR be such that /path/to/baselibs/${CMAKE_HOST_SYSTEM_NAME}/lib exists\n"
        "However, you provided\n"
        "   ${BASEDIR} \n"
        "which does not have the correct format. Please make sure BASEDIR is correctly built and set."
        )
    endif ()

    set (Baselibs_FOUND TRUE CACHE BOOL "Baselibs Found" FORCE)
    message (STATUS "BASEDIR: ${BASEDIR}")
  # what if BASEDIR doesn't have ARCH, so we look for BASEDIR/ARCH/lib
  elseif (IS_DIRECTORY ${BASEDIR}/${CMAKE_HOST_SYSTEM_NAME}/lib)
    # Then we re-set BASEDIR so that it has the ARCH as that's what the CMake
    # system here expects
    message (STATUS "BASEDIR passed in without ${CMAKE_HOST_SYSTEM_NAME}. Setting BASEDIR internally to ${BASEDIR}/${CMAKE_HOST_SYSTEM_NAME}.")
    set (BASEDIR ${BASEDIR}/${CMAKE_HOST_SYSTEM_NAME})
    # Say we found Baselibs
    set (Baselibs_FOUND TRUE CACHE BOOL "Baselibs Found" FORCE)
    # And output a message
    message (STATUS "BASEDIR: ${BASEDIR}")

  # If we get here, we have a BASEDIR, but it's not right...
  else ()
    if (BASEDIR_FROM_ENVIRONMENT)
      set (EXTRA_TEXT "in the environment, ")
    endif ()
    message(FATAL_ERROR
      "GEOS requires that BASEDIR be such that /path/to/baselibs/${CMAKE_HOST_SYSTEM_NAME}/lib exists\n"
      "However, we found\n"
      "   ${BASEDIR} \n"
      "${EXTRA_TEXT}but a good path does not seem to exist. Please check your input"
      )
  endif ()
  set (BASEDIR "${BASEDIR}" CACHE PATH "Path to installed baselibs" FORCE)
else ()
  ecbuild_warn(
    "BASEDIR not specified.\n"
    "If you wish to use Baselibs, please use:\n"
    "   cmake ... -DBASEDIR=<path-to-Baselibs>\n"
    "or set BASEDIR in your environment.\n\n"
    "Note that building GEOS-ESM code without Baselibs is unsupported.")
endif ()

if (ESMA_SDF)
   message (FATAL_ERROR "ERROR: -hdf option was thought to be obsolete when CMake was crafted.")
endif ()

if (Baselibs_FOUND)

  # For now require MPI with Baselibs
  set(MPI_DETERMINE_LIBRARY_VERSION TRUE)
  find_package(MPI REQUIRED)

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

  # Changes in Baselibs mean on Darwin we need to capture three
  # Framework Libraries needed to link with Curl (so netCDF needs them)
  if (APPLE)
    find_library(FWSystemConfiguration NAMES SystemConfiguration)
    find_library(FWCoreFoundation      NAMES CoreFoundation)
    find_library(FWSecurity            NAMES Security)
  endif ()

  add_definitions(-DHAS_NETCDF4)
  add_definitions(-DHAS_NETCDF3)
  add_definitions(-DH5_HAVE_PARALLEL)
  add_definitions(-DNETCDF_NEED_NF_MPIIO)
  #------------------------------------------------------------------

  set (INC_HDF5 ${BASEDIR}/include/hdf5)
  set (INC_NETCDF ${BASEDIR}/include/netcdf)
  set (INC_HDF ${BASEDIR}/include/hdf)
  set (INC_ESMF ${BASEDIR}/include/esmf)

  # Need to do a bit of kludgy stuff here to allow Fortran linker to
  # find standard C and C++ libraries used by ESMF.
  # _And_ ESMF uses libc++ on some configs and libstdc++ on others.
  if (APPLE)
    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
       set (stdcxx libc++.dylib)
    else () # assume gcc
      execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libstdc++.dylib OUTPUT_VARIABLE stdcxx OUTPUT_STRIP_TRAILING_WHITESPACE)
      execute_process (COMMAND ${CMAKE_C_COMPILER} --print-file-name=libgcc.a OUTPUT_VARIABLE libgcc OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()
  else ()
    execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libstdc++.so OUTPUT_VARIABLE stdcxx OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=librt.so OUTPUT_VARIABLE rt OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libdl.so OUTPUT_VARIABLE dl OUTPUT_STRIP_TRAILING_WHITESPACE)
  endif ()

  # With Baselibs 6.2.5, we can now link to the ESMF dynamic library on macOS
  set (ESMF_LIBRARY esmf)
  # Now set the suffix. Note that unfortunately CMAKE_SHARED_MODULE_SUFFIX doesn't
  # quite do what we want (sets .so on macOS here), so we say "dylib" or "so"
  if (APPLE)
    set (ESMF_LIBRARY_SUFFIX "dylib")
  else ()
    set (ESMF_LIBRARY_SUFFIX "so")
  endif ()
  set (ESMF_LIBRARY_PATH ${BASEDIR}/lib/lib${ESMF_LIBRARY}.${ESMF_LIBRARY_SUFFIX})

  if (NOT EXISTS ${ESMF_LIBRARY_PATH})
    message (FATAL_ERROR "Cannot find ${ESMF_LIBRARY_PATH}")
  else ()
    message(STATUS "ESMF_LIBRARY_PATH: ${ESMF_LIBRARY_PATH}")
  endif ()

  set (NETCDF_LIBRARIES ${NETCDF_LIBRARIES_OLD})

  # We need to append the frameworks to this
  if (APPLE)
    list(APPEND NETCDF_LIBRARIES ${FWSystemConfiguration} ${FWCoreFoundation})
    # The security framework is only used when cURL is compiled with Clang
    # due to a bug between cURL and GCC
    if (CMAKE_C_COMPILER_ID MATCHES "Clang")
      list(APPEND NETCDF_LIBRARIES ${FWSecurity})
    endif ()
  endif ()

  # We also need to append the pthread flag at link time
  list(APPEND NETCDF_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})

  set (ESMF_LIBRARIES ${ESMF_LIBRARY} ${NETCDF_LIBRARIES} ${MPI_Fortran_LIBRARIES} ${MPI_CXX_LIBRARIES} ${rt} ${stdcxx} ${dl} ${libgcc})

  # Create targets
  # - NetCDF Fortran
  add_library(NetCDF::NetCDF_Fortran STATIC IMPORTED)
  set_target_properties(NetCDF::NetCDF_Fortran PROPERTIES
    IMPORTED_LOCATION ${BASEDIR}/lib/libnetcdff.a
    INTERFACE_INCLUDE_DIRECTORIES "${INC_NETCDF}"
    INTERFACE_LINK_LIBRARIES  "${NETCDF_LIBRARIES}"
    INTERFACE_LINK_DIRECTORIES "${BASEDIR}/lib"
    )
  set(NetCDF_Fortran_FOUND TRUE CACHE BOOL "NetCDF Fortran Found" FORCE)

  # - ESMF
  add_library(esmf STATIC IMPORTED)
  set_target_properties(esmf PROPERTIES
    IMPORTED_LOCATION ${ESMF_LIBRARY_PATH}
    INTERFACE_INCLUDE_DIRECTORIES "${INC_ESMF}"
    INTERFACE_LINK_LIBRARIES  "${ESMF_LIBRARIES}"
    INTERFACE_LINK_DIRECTORIES "${BASEDIR}/lib"
    )
  set(esmf_FOUND TRUE CACHE BOOL "ESMF Found" FORCE)

  # BASEDIR.rc file does not have the arch
  string(REPLACE "/${CMAKE_SYSTEM_NAME}" "" BASEDIR_WITHOUT_ARCH ${BASEDIR})
  set(BASEDIR_WITHOUT_ARCH ${BASEDIR_WITHOUT_ARCH} CACHE STRING "BASEDIR without arch")
  mark_as_advanced(BASEDIR_WITHOUT_ARCH)

else ()

  # These should be in each fixture

  ###########################################
  # # For now require MPI with Baselibs     #
  # set(MPI_DETERMINE_LIBRARY_VERSION TRUE) #
  # find_package(MPI REQUIRED)              #
  #                                         #
  # find_package(NetCDF REQUIRED Fortran)   #
  # add_definitions(-DHAS_NETCDF4)          #
  # add_definitions(-DHAS_NETCDF3)          #
  # add_definitions(-DNETCDF_NEED_NF_MPIIO) #
  #                                         #
  # find_package(HDF5 REQUIRED)             #
  # if(HDF5_IS_PARALLEL)                    #
  #    add_definitions(-DH5_HAVE_PARALLEL)  #
  # endif()                                 #
  #                                         #
  # find_package(ESMF MODULE REQUIRED)      #
  ###########################################

endif()
