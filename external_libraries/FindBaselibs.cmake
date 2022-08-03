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
  find_package(MPI)

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

  # Need to do a bit of kludgy stuff here to allow Fortran linker to
  # find standard C and C++ libraries used by ESMF.
  # _And_ ESMF uses libc++ on some configs and libstdc++ on others.
  if (APPLE)
    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
       set (stdcxx libc++.dylib)
    else () # assume gcc
      execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libstdc++.dylib OUTPUT_VARIABLE stdcxx OUTPUT_STRIP_TRAILING_WHITESPACE)
      execute_process (COMMAND ${CMAKE_C_COMPILER}   --print-file-name=libgcc.a        OUTPUT_VARIABLE libgcc OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()
  else ()
    execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libstdc++.so OUTPUT_VARIABLE stdcxx OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=librt.so     OUTPUT_VARIABLE rt     OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libdl.so     OUTPUT_VARIABLE dl     OUTPUT_STRIP_TRAILING_WHITESPACE)
  endif ()

  # ------------
  # ESMF Library
  # ------------

  # First we look for esmf.mk which is required for use by FindESMF.cmake
  if (NOT EXISTS ${BASEDIR}/lib/esmf.mk)
    # If we don't find it, die.
    message (FATAL_ERROR "Cannot find ${ESMFMKFILE}")
  else ()
    # If we do find ESMF, then we set the ESMFMKFILE variable
    set (ESMFMKFILE "${BASEDIR}/lib/esmf.mk" CACHE PATH "Path to esmf.mk file" FORCE)
    message(STATUS "ESMFMKFILE: ${ESMFMKFILE}")

    # Now, let us use the FindESMF.cmake that ESMF itself includes and installs
    list (APPEND CMAKE_MODULE_PATH "${BASEDIR}/include/esmf")
    find_package(ESMF MODULE REQUIRED)

    # Also, we know ESMF from Baselibs requires MPI (note that this isn't always true, but
    # for ESMF built in Baselibs for use in GEOS, it currently is)
    target_link_libraries(ESMF INTERFACE MPI::MPI_Fortran)

    # Finally, we add an alias since GEOS (at the moment) uses esmf not ESMF for the target
    add_library(esmf ALIAS ESMF)
  endif ()

  # ------
  # NetCDF
  # ------

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

  # Now we try to detect if the netcdf library was linked statically or
  # dynamically by looking for hdf5 in NETCDF_LIBRARIES. Could be fragile,
  # but nf-config --flibs for a shared build should never have libhdf5
  if ("hdf5" IN_LIST NETCDF_LIBRARIES)
    set(NETCDF_LIBRARY_TYPE STATIC)
    set(NETCDF_LIBRARY_SUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX})
  else ()
    set(NETCDF_LIBRARY_TYPE SHARED)
    set(NETCDF_LIBRARY_SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX})
  endif ()
  message(STATUS "Detected that NetCDF in Baselibs was built as ${NETCDF_LIBRARY_TYPE}")

  if (NETCDF_LIBRARY_TYPE STREQUAL SHARED)
    # If we build as shared, we have a chance for zstandard support. But older versions
    # of netcdf don't even have the --has-zstd option, so we must detect for that.

    # First run execute_process to see if the flag even exists (only in netCDF-C v4.9.0 or higher). 
    # We do this because Cmake will print the usage of nc-config if a bad flag is passed in, but here
    # we can quiet the output
    execute_process (
      COMMAND ${BASEDIR}/bin/nc-config --has-zstd
      RESULT_VARIABLE NC_CONFIG_HAS_ZSTD_FLAG
      ERROR_QUIET OUTPUT_QUIET
      )

    if (NC_CONFIG_HAS_ZSTD_FLAG)
      # Non zero status code, we are done
      set(NETCDF_HAS_ZSTD FALSE)
    else ()
      # So the flag was accepted, now actually capture the output
      execute_process (
        COMMAND ${BASEDIR}/bin/nc-config --has-zstd
        OUTPUT_VARIABLE NETCDF_BUILT_WITH_ZSTD
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
      # So we returned a zero return code, so the --has-zstd flag was available
      if (NETCDF_BUILT_WITH_ZSTD STREQUAL "yes")
        set(NETCDF_HAS_ZSTD TRUE)
      else ()
        set(NETCDF_HAS_ZSTD FALSE)
      endif ()
    endif ()
    message(STATUS "Detected NetCDF built with zstd support: ${NETCDF_HAS_ZSTD}")

    # Now do a check that HDF5_PLUGIN_PATH is set and give a warning if not
    if (NETCDF_HAS_ZSTD AND NOT DEFINED ENV{HDF5_PLUGIN_PATH})
      message(WARNING 
        "NetCDF has reported it was built with zstandard support, but you do not have the HDF5_PLUGIN_PATH set\n"
        "This will lead to runtime failures if zstandard compression is used.\n"
        )
    else ()
      message(STATUS "Detected HDF5_PLUGIN_PATH: $ENV{HDF5_PLUGIN_PATH}")
    endif ()
  endif ()



  # Create targets
  # - NetCDF C
  add_library(NetCDF::NetCDF_C ${NETCDF_LIBRARY_TYPE} IMPORTED)
  set_target_properties(NetCDF::NetCDF_C PROPERTIES
    IMPORTED_LOCATION ${BASEDIR}/lib/libnetcdf${NETCDF_LIBRARY_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES "${INC_NETCDF}"
    INTERFACE_LINK_LIBRARIES  "${NETCDF_LIBRARIES}"
    INTERFACE_LINK_DIRECTORIES "${BASEDIR}/lib"
    )
  set(NetCDF_C_FOUND TRUE CACHE BOOL "NetCDF C Found" FORCE)

  # - NetCDF Fortran
  add_library(NetCDF::NetCDF_Fortran ${NETCDF_LIBRARY_TYPE} IMPORTED)
  set_target_properties(NetCDF::NetCDF_Fortran PROPERTIES
    IMPORTED_LOCATION ${BASEDIR}/lib/libnetcdff${NETCDF_LIBRARY_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES "${INC_NETCDF}"
    INTERFACE_LINK_LIBRARIES  "${NETCDF_LIBRARIES}"
    INTERFACE_LINK_DIRECTORIES "${BASEDIR}/lib"
    )
  set(NetCDF_Fortran_FOUND TRUE CACHE BOOL "NetCDF Fortran Found" FORCE)

  # BASEDIR.rc file does not have the arch
  string(REPLACE "/${CMAKE_SYSTEM_NAME}" "" BASEDIR_WITHOUT_ARCH ${BASEDIR})
  set(BASEDIR_WITHOUT_ARCH ${BASEDIR_WITHOUT_ARCH} CACHE STRING "BASEDIR without arch")
  mark_as_advanced(BASEDIR_WITHOUT_ARCH)

else ()

  # These should be in each fixture

  ###########################################
  # # For now require MPI with Baselibs     #
  # set(MPI_DETERMINE_LIBRARY_VERSION TRUE) #
  # find_package(MPI)                       #
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
  # add_library(esmf ALIAS ESMF).           #
  ###########################################

endif()
