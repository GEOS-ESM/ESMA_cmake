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
  message(STATUS "BASEDIR not set. Baselibs not found. Assume we are using Spack or other methods to provide dependencies")
endif ()

if (ESMA_SDF)
   message (FATAL_ERROR "ERROR: -hdf option was thought to be obsolete when CMake was crafted.")
endif ()

if (Baselibs_FOUND)

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

  # First we look for esmf.mk which is required for use by FindESMF.cmake
  if (NOT EXISTS ${BASEDIR}/lib/esmf.mk)
    # If we don't find it, die.
    message (FATAL_ERROR "Cannot find ${ESMFMKFILE}")
  else ()
    # If we do find ESMF, then we set the ESMFMKFILE variable
    set (ESMFMKFILE "${BASEDIR}/lib/esmf.mk" CACHE PATH "Path to esmf.mk file" FORCE)
    message(STATUS "ESMFMKFILE: ${ESMFMKFILE}")

    # Now we can use FindESMF.cmake to find ESMF. This uses the one in the current
    # directory, not the one in the ESMF installation. The one here uses
    # ESMF::ESMF as the main target
    find_package(ESMF MODULE REQUIRED)

    # Also, we know ESMF from Baselibs requires MPI (note that this isn't always true, but
    # for ESMF built in Baselibs for use in GEOS, it currently is)
    target_link_libraries(ESMF::ESMF INTERFACE MPI::MPI_Fortran)

    # Finally, we add aliases since GEOS (at the moment) uses esmf and ESMF for the target
    # instead of ESMF::ESMF (MAPL uses ESMF::ESMF)
    if (NOT TARGET ESMF)
      message(STATUS "ESMF alias not found, creating ESMF alias")
      add_library(ESMF ALIAS ESMF::ESMF)
    endif ()
    if (NOT TARGET esmf)
      message(STATUS "esmf alias not found, creating esmf alias")
      add_library(esmf ALIAS ESMF::ESMF)
    endif ()
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

  # Create targets
  # - NetCDF C
  add_library(NetCDF::NetCDF_C STATIC IMPORTED)
  set_target_properties(NetCDF::NetCDF_C PROPERTIES
    IMPORTED_LOCATION ${BASEDIR}/lib/libnetcdf.a
    INTERFACE_INCLUDE_DIRECTORIES "${NETCDF_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES  "${NETCDF_LIBRARIES}"
    INTERFACE_LINK_DIRECTORIES "${BASEDIR}/lib"
    )
  set(NetCDF_C_FOUND TRUE CACHE BOOL "NetCDF C Found" FORCE)

  # - NetCDF Fortran
  add_library(NetCDF::NetCDF_Fortran STATIC IMPORTED)
  set_target_properties(NetCDF::NetCDF_Fortran PROPERTIES
    IMPORTED_LOCATION ${BASEDIR}/lib/libnetcdff.a
    INTERFACE_INCLUDE_DIRECTORIES "${NETCDF_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES  "${NETCDF_LIBRARIES}"
    INTERFACE_LINK_DIRECTORIES "${BASEDIR}/lib"
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
  # the "sz" library is actually "aec sz". So we need to check if
  # libaec is in the BASEDIR/lib directory. If it is, then we
  # can set SZ_LIB to "aec sz", otherwise we set it to just "sz".
  if (EXISTS ${BASEDIR}/lib/libaec.a)
    # If we have libaec, then we use it
    set (SZ_LIB "aec sz")
    message(STATUS "Found libaec in BASEDIR/lib. Using aec sz for SZ_LIB.")
  else ()
    # If we don't have libaec, then we use just sz
    set (SZ_LIB "sz")
    message(STATUS "Did not find libaec in BASEDIR/lib. Using sz for SZ_LIB.")
  endif ()

  set (HDF5_LIBRARIES hdf5_hl_fortran hdf5_fortran hdf5_hl hdf5 ${SZ_LIB} z m dl)
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
    # libyaml
    option(FMS_BUILT_WITH_YAML "FMS was built with YAML" OFF)
    if (FMS_BUILT_WITH_YAML)
      # We use the same Findlibyaml.cmake that FMS uses
      find_package(libyaml REQUIRED)
      message(STATUS "LIBYAML_INCLUDE_DIR: ${LIBYAML_INCLUDE_DIR}")
      message(STATUS "LIBYAML_LIBRARIES: ${LIBYAML_LIBRARIES}")
    endif ()

    # - fms_r4
    if (FV_PRECISION STREQUAL R4 OR FV_PRECISION STREQUAL R4R8)
      # Use find_path and find_library to find the include and library
      find_path(FMS_INCLUDE_DIR_R4 NAMES fms.mod PATHS ${BASEDIR}/FMS/include_r4)
      find_library(FMS_LIBRARIES_R4 NAMES fms_r4 PATHS ${BASEDIR}/FMS/lib ${BASEDIR}/FMS/lib64)
      # We also need the path of where the library is for the INTERFACE_LINK_DIRECTORIES
      get_filename_component(FMS_LIBRARIES_DIR_R4 ${FMS_LIBRARIES_R4} DIRECTORY)
      add_library(FMS::fms_r4 STATIC IMPORTED)
      set_target_properties(FMS::fms_r4 PROPERTIES
        IMPORTED_LOCATION ${FMS_LIBRARIES_R4}
        INCLUDE_DIRECTORIES "${FMS_INCLUDE_DIR_R4}"
        INTERFACE_INCLUDE_DIRECTORIES "${FMS_INCLUDE_DIR_R4}"
        INTERFACE_LINK_LIBRARIES  "NetCDF::NetCDF_Fortran;MPI::MPI_Fortran"
        INTERFACE_LINK_DIRECTORIES "${FMS_LIBRARIES_DIR_R4}"
      )
      if (FMS_BUILT_WITH_YAML)
        target_link_libraries(FMS::fms_r4 INTERFACE ${LIBYAML_LIBRARIES})
      endif ()
      # We will set FMS_R4_FOUND if both FMS_LIBRARIES_R4 and FMS_INCLUDE_DIR_R4 are found
      # and are valid files and directories respectively
      if (EXISTS ${FMS_LIBRARIES_R4} AND IS_DIRECTORY ${FMS_INCLUDE_DIR_R4})
        message(STATUS "Found FMS::fms_r4: ${FMS_LIBRARIES_R4}")
        message(STATUS "FMS::fms_r4 include directory: ${FMS_INCLUDE_DIR_R4}")
        set(FMS_R4_FOUND TRUE CACHE BOOL "fms_r4 Found" FORCE)
      else ()
        message(FATAL_ERROR "FMS::fms_r4 not found")
      endif()
    endif()

    # - fms_r8
    if (FV_PRECISION STREQUAL R8 OR FV_PRECISION STREQUAL R4R8)
      # Use find_path and find_library to find the include and library
      find_path(FMS_INCLUDE_DIR_R8 NAMES fms.mod PATHS ${BASEDIR}/FMS/include_r8)
      find_library(FMS_LIBRARIES_R8 NAMES fms_r8 PATHS ${BASEDIR}/FMS/lib ${BASEDIR}/FMS/lib64)
      # We also need the path of where the library is for the INTERFACE_LINK_DIRECTORIES
      get_filename_component(FMS_LIBRARIES_DIR_R8 ${FMS_LIBRARIES_R8} DIRECTORY)
      add_library(FMS::fms_r8 STATIC IMPORTED)
      set_target_properties(FMS::fms_r8 PROPERTIES
        IMPORTED_LOCATION ${FMS_LIBRARIES_R8}
        INCLUDE_DIRECTORIES "${FMS_INCLUDE_DIR_R8}"
        INTERFACE_INCLUDE_DIRECTORIES "${FMS_INCLUDE_DIR_R8}"
        INTERFACE_LINK_LIBRARIES  "NetCDF::NetCDF_Fortran;MPI::MPI_Fortran"
        INTERFACE_LINK_DIRECTORIES "${FMS_LIBRARIES_DIR_R8}"
      )
      if (FMS_BUILT_WITH_YAML)
        target_link_libraries(FMS::fms_r8 INTERFACE ${LIBYAML_LIBRARIES})
      endif ()
      # We will set FMS_R8_FOUND if both FMS_LIBRARIES_R8 and FMS_INCLUDE_DIR_R8 are found
      # and are valid files and directories respectively
      if (EXISTS ${FMS_LIBRARIES_R8} AND IS_DIRECTORY ${FMS_INCLUDE_DIR_R8})
        message(STATUS "Found FMS::fms_r8: ${FMS_LIBRARIES_R8}")
        message(STATUS "FMS::fms_r8 include directory: ${FMS_INCLUDE_DIR_R8}")
        set(FMS_R8_FOUND TRUE CACHE BOOL "fms_r8 Found" FORCE)
      else ()
        message(FATAL_ERROR "FMS::fms_r8 not found")
      endif()
    endif()

    if (FV_PRECISION STREQUAL R4R8)
      # We will set FMS_FOUND if both fms_r4 and fms_r8 are found
      # and are valid files and directories respectively
      if (FMS_R4_FOUND AND FMS_R8_FOUND)
        set(FMS_FOUND TRUE CACHE BOOL "FMS Found" FORCE)
      endif()
    elseif (FV_PRECISION STREQUAL R4)
      if (FMS_R4_FOUND)
        set(FMS_FOUND TRUE CACHE BOOL "FMS Found" FORCE)
      endif()
    elseif (FV_PRECISION STREQUAL R8)
      if (FMS_R8_FOUND)
        set(FMS_FOUND TRUE CACHE BOOL "FMS Found" FORCE)
      endif()
    else()
      message(FATAL_ERROR "FMS Detection failed in odd way")
    endif()

    if (FMS_FOUND)
      set (FMS_DIR ${BASEDIR}/FMS CACHE PATH "Path to FMS" FORCE)
    endif ()
  endif()

  # BASEDIR.rc file does not have the arch
  string(REPLACE "/${CMAKE_SYSTEM_NAME}" "" BASEDIR_WITHOUT_ARCH ${BASEDIR})
  set(BASEDIR_WITHOUT_ARCH ${BASEDIR_WITHOUT_ARCH} CACHE STRING "BASEDIR without arch")
  mark_as_advanced(BASEDIR_WITHOUT_ARCH)

else ()

  # These should be in each fixture

  ###########################################
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
