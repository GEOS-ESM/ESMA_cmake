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
  set (NETCDF_INCLUDE_DIRS ${BASEDIR}/include/netcdf)
  set (INC_NETCDF ${NETCDF_INCLUDE_DIRS})
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
    if (NOT CMAKE_CXX_COMPILER_ID MATCHES "NVHPC")
      execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libstdc++.so OUTPUT_VARIABLE stdcxx OUTPUT_STRIP_TRAILING_WHITESPACE)
      execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=librt.so     OUTPUT_VARIABLE rt     OUTPUT_STRIP_TRAILING_WHITESPACE)
      execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libdl.so     OUTPUT_VARIABLE dl     OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif ()
  endif ()

  # ------------
  # ESMF Library
  # ------------

  # Prefer the ESMF config package installed below BASEDIR, but retain the
  # esmf.mk module fallback for older Baselibs installations.
  set(_esma_esmf_config_found FALSE)
  if (EXISTS "${BASEDIR}/lib/esmf.mk")
    set (ESMFMKFILE "${BASEDIR}/lib/esmf.mk" CACHE PATH "Path to esmf.mk file" FORCE)
    message(STATUS "ESMFMKFILE: ${ESMFMKFILE}")
  endif ()

  find_package(ESMF ${ESMA_ESMF_MIN_VERSION} CONFIG QUIET
               PATHS "${BASEDIR}" NO_DEFAULT_PATH)
  if (ESMF_FOUND)
    set(_esma_esmf_config_found TRUE)
  else ()
    if (NOT EXISTS "${BASEDIR}/lib/esmf.mk")
      message (FATAL_ERROR "Cannot find ESMFConfig.cmake or ${BASEDIR}/lib/esmf.mk")
    endif ()

    # Use the FindESMF.cmake module in this project for legacy installations.
    find_package(ESMF MODULE REQUIRED)

    # Baselibs' esmf.mk does not carry a CMake-style version string, so
    # find_package() above cannot enforce a minimum version the way
    # ConfigureExternalLibraries.cmake does (find_package(ESMF ${ESMA_ESMF_MIN_VERSION} ...)).
    # Check ESMF_VERSION explicitly instead so Baselibs and Spack builds
    # enforce the same minimum.
    if (ESMF_VERSION VERSION_LESS ${ESMA_ESMF_MIN_VERSION})
      message(FATAL_ERROR "ESMF must be at least ${ESMA_ESMF_MIN_VERSION}")
    endif ()
  endif ()

  # The generated config declares MPI itself. Older module-based ESMF
  # installations need this dependency supplied by ESMA_cmake.
  if (NOT _esma_esmf_config_found)
    target_link_libraries(ESMF::ESMF INTERFACE MPI::MPI_Fortran)
  endif ()

  # Finally, we add aliases since GEOS (at the moment) uses esmf and ESMF for
  # the target instead of ESMF::ESMF (MAPL uses ESMF::ESMF).
  if (NOT TARGET ESMF)
    message(STATUS "ESMF alias not found, creating ESMF alias")
    add_library(ESMF ALIAS ESMF::ESMF)
  endif ()
  if (NOT TARGET esmf)
    message(STATUS "esmf alias not found, creating esmf alias")
    add_library(esmf ALIAS ESMF::ESMF)
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

    # We have a special circumstance with Apple and Baselibs now
    # we might be linking against OpenSSL from homebrew. So we
    # need to parse LIB_NETCDF and first pull out all the -L matches
    string(REGEX MATCHALL " -L[^ ]*" _full_lib_paths "${LIB_NETCDF}")

    # Now, we have a list of all the -L paths, but now we need to look
    # one with 'openssl' in it. If we find one, then we need to capture
    # that
    set (NETCDF_OPENSSL_LIB_PATH "")
    foreach (lib_path ${_full_lib_paths})
      # Strip the -L prefix
      string (REPLACE "-L" "" _tmp ${lib_path})
      string (STRIP ${_tmp} _tmp)
      # Now check if it has 'openssl' in it
      message(DEBUG "Checking if ${_tmp} contains 'openssl'")
      if (_tmp MATCHES "openssl")
        # If it does, then we set the NETCDF_OPENSSL_LIB_PATH
        set (NETCDF_OPENSSL_LIB_PATH ${_tmp})
        message(DEBUG "[macOS] [SSL] Found OpenSSL library path for NetCDF: ${NETCDF_OPENSSL_LIB_PATH}")
        # And we break out of the loop
        break()
      endif ()
    endforeach()

  endif ()

  # We also need to append the pthread flag at link time
  list(APPEND NETCDF_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})

  # Now we need to make a list for our netcdf INTERFACE_LINK_DIRECTORIES
  # We know that ${BASEDIR}/lib is the directory where the libraries baselibs
  # are installed, so we can use that as the link directory.
  set (NETCDF_LINK_DIRECTORIES ${BASEDIR}/lib)
  # Now if we have an OpenSSL library path, we need to add that too
  if (NETCDF_OPENSSL_LIB_PATH)
    # If we have an OpenSSL library path, we need to add that too
    message(DEBUG "[macOS] [SSL] Adding OpenSSL library path to NetCDF link directories: ${NETCDF_OPENSSL_LIB_PATH}")
    list(APPEND NETCDF_LINK_DIRECTORIES ${NETCDF_OPENSSL_LIB_PATH})
  endif ()

  # Create targets
  # - NetCDF C
  add_library(NetCDF::NetCDF_C STATIC IMPORTED)
  set_target_properties(NetCDF::NetCDF_C PROPERTIES
    IMPORTED_LOCATION ${BASEDIR}/lib/libnetcdf.a
    INTERFACE_INCLUDE_DIRECTORIES "${NETCDF_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES  "${NETCDF_LIBRARIES}"
    INTERFACE_LINK_DIRECTORIES "${NETCDF_LINK_DIRECTORIES}"
    )
  set(NetCDF_C_FOUND TRUE CACHE BOOL "NetCDF C Found" FORCE)

  # - NetCDF Fortran
  add_library(NetCDF::NetCDF_Fortran STATIC IMPORTED)
  set_target_properties(NetCDF::NetCDF_Fortran PROPERTIES
    IMPORTED_LOCATION ${BASEDIR}/lib/libnetcdff.a
    INTERFACE_INCLUDE_DIRECTORIES "${NETCDF_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES  "${NETCDF_LIBRARIES}"
    INTERFACE_LINK_DIRECTORIES "${NETCDF_LINK_DIRECTORIES}"
    )
  set(NetCDF_Fortran_FOUND TRUE CACHE BOOL "NetCDF Fortran Found" FORCE)

  # ----
  # HDF5
  # ----

  # Like above, baselibs does not build HDF5 as CMake so the HDF5::HDF5 target is
  # not available. So we create it here.
  # NOTE: This is *very* fragile and mainly creates a target that satisfies the
  #       needs of GEOS. It is not a general HDF5 target. If you need a general
  #       HDF5 target, please use the HDF5 CMake build (which we hope to move
  #       to in the future with spack)

  # HDF5_LIBRARIES is a list of libraries that HDF5 needs to link to

  # We need to be careful here. If Baselibs was built with libaec, then
  # the "sz" library is actually "sz aec". So we need to check if
  # libaec is in the BASEDIR/lib directory. If it is, then we
  # can set SZ_LIB to "sz aec", otherwise we set it to just "sz".
  # We should also check to see if sz is there as well! If it isn't
  # we set SZ_LIB to "".
  set (SZ_LIB)
  if (EXISTS ${BASEDIR}/lib/libaec.a)
    # If we have libaec, then we use it
    list (APPEND SZ_LIB sz aec)
    message(DEBUG "Found libaec in BASEDIR/lib. Using sz aec for SZ_LIB.")
  elseif (EXISTS ${BASEDIR}/lib/libsz.a)
    # We don't have libaec, but we do have sz
    list (APPEND SZ_LIB sz)
    message(DEBUG "Did not find libaec in BASEDIR/lib. Using sz for SZ_LIB.")
  else ()
    # We don't have sz or libaec
    message(DEBUG "Did not find libsz or libaec in BASEDIR/lib. Not using sz or aec for SZ_LIB.")
  endif ()

  set (HDF5_LIBRARIES
    hdf5_hl_fortran hdf5_fortran hdf5_hl hdf5
    ${SZ_LIB}
    z m dl)
  # Create targets

  # - HDF5 C
  add_library(hdf5::hdf5 STATIC IMPORTED)
  set_target_properties(hdf5::hdf5 PROPERTIES
    IMPORTED_LOCATION ${BASEDIR}/lib/libhdf5.a
    INTERFACE_INCLUDE_DIRECTORIES "${INC_HDF5}"
    INTERFACE_LINK_LIBRARIES  "${HDF5_LIBRARIES}"
    INTERFACE_LINK_DIRECTORIES "${BASEDIR}/lib"
    )
  set(HDF5_C_FOUND TRUE CACHE BOOL "HDF5 C Found" FORCE)

  # - HDF5 C HL
  add_library(hdf5::hdf5_hl STATIC IMPORTED)
  set_target_properties(hdf5::hdf5_hl PROPERTIES
    IMPORTED_LOCATION ${BASEDIR}/lib/libhdf5_hl.a
    INTERFACE_INCLUDE_DIRECTORIES "${INC_HDF5}"
    INTERFACE_LINK_LIBRARIES  "${HDF5_LIBRARIES}"
    INTERFACE_LINK_DIRECTORIES "${BASEDIR}/lib"
    )
  set(HDF5_HL_FOUND TRUE CACHE BOOL "HDF5 C HL Found" FORCE)

  # - HDF5 Fortran
  add_library(hdf5::hdf5_fortran STATIC IMPORTED)
  set_target_properties(hdf5::hdf5_fortran PROPERTIES
    IMPORTED_LOCATION ${BASEDIR}/lib/libhdf5_fortran.a
    INTERFACE_INCLUDE_DIRECTORIES "${INC_HDF5}"
    INTERFACE_LINK_LIBRARIES  "${HDF5_LIBRARIES}"
    INTERFACE_LINK_DIRECTORIES "${BASEDIR}/lib"
    )
  set(HDF5_Fortran_FOUND TRUE CACHE BOOL "HDF5 Fortran Found" FORCE)

  # - HDF5 Fortran HL
  add_library(hdf5::hdf5_hl_fortran STATIC IMPORTED)
  set_target_properties(hdf5::hdf5_hl_fortran PROPERTIES
    IMPORTED_LOCATION ${BASEDIR}/lib/libhdf5_hl_fortran.a
    INTERFACE_INCLUDE_DIRECTORIES "${INC_HDF5}"
    INTERFACE_LINK_LIBRARIES  "${HDF5_LIBRARIES}"
    INTERFACE_LINK_DIRECTORIES "${BASEDIR}/lib"
    )
  set(HDF5_Fortran_HL_FOUND TRUE CACHE BOOL "HDF5 Fortran HL Found" FORCE)

  # Now we make a target that is the "super" HDF5 target
  add_library(HDF5::HDF5 INTERFACE IMPORTED)
  target_link_libraries(HDF5::HDF5 INTERFACE hdf5::hdf5 hdf5::hdf5_hl hdf5::hdf5_fortran hdf5::hdf5_hl_fortran)
  set(HDF5_FOUND TRUE CACHE BOOL "HDF5 Found" FORCE)

  # We only need to look for FMS if we need it. Projects like MAPL
  # don't use FMS, so we don't need to look for it.
  # For Baselibs, can see if FV_PRECISION is set to anything
  # if not set, then we assume it is not used


  if (DEFINED FV_PRECISION)
    message(STATUS "Looking for FMS")

    # fms-config.cmake supplies a FindNetCDF.cmake compatible with the
    # Baselibs NetCDF installation. It appends that directory, so prioritize
    # it over ESMA_cmake's older module while resolving FMS dependencies.
    # The Baselibs targets above already provide both requested NetCDF
    # components; record that for FMS's FindNetCDF module to avoid replacing
    # their static-library link information.
    set(${PROJECT_NAME}_NetCDF_C_FOUND TRUE)
    set(${PROJECT_NAME}_NetCDF_Fortran_FOUND TRUE)
    set(NetCDF_FOUND TRUE)
    if (EXISTS "${BASEDIR}/FMS/lib64/cmake/fms")
      set(_FMS_CMAKE_DIR "${BASEDIR}/FMS/lib64/cmake/fms")
    elseif (EXISTS "${BASEDIR}/FMS/lib/cmake/fms")
      set(_FMS_CMAKE_DIR "${BASEDIR}/FMS/lib/cmake/fms")
    endif ()

    if (_FMS_CMAKE_DIR)
      list(PREPEND CMAKE_MODULE_PATH "${_FMS_CMAKE_DIR}")
    endif ()
    find_package(FMS CONFIG REQUIRED
      PATHS "${BASEDIR}/FMS/lib64/cmake/fms" "${BASEDIR}/FMS/lib/cmake/fms"
      NO_DEFAULT_PATH)
    if (_FMS_CMAKE_DIR)
      list(REMOVE_ITEM CMAKE_MODULE_PATH "${_FMS_CMAKE_DIR}")
      unset(_FMS_CMAKE_DIR)
    endif ()

    # FMS's FindNetCDF module clears this legacy variable after it observes
    # the targets above.  f2py still uses it to construct its link line.
    set(NETCDF_LIBRARIES ${NETCDF_LIBRARIES_OLD})
    list(APPEND NETCDF_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
  endif()

  # BASEDIR.rc file does not have the arch
  string(REPLACE "/${CMAKE_SYSTEM_NAME}" "" BASEDIR_WITHOUT_ARCH ${BASEDIR})
  set(BASEDIR_WITHOUT_ARCH ${BASEDIR_WITHOUT_ARCH} CACHE STRING "BASEDIR without arch")
  mark_as_advanced(BASEDIR_WITHOUT_ARCH)
