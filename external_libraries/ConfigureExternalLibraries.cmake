# Configure dependencies provided by Spack or another non-Baselibs package
# manager.  This file is included only when Baselibs_FOUND is false.

find_package(NetCDF REQUIRED C Fortran)
add_definitions(-DHAS_NETCDF4)
add_definitions(-DHAS_NETCDF3)
add_definitions(-DNETCDF_NEED_NF_MPIIO)

set(HDF5_PREFER_PARALLEL TRUE)
find_package(HDF5 REQUIRED COMPONENTS C Fortran HL)

# FindHDF5 does not consistently set HDF5_IS_PARALLEL for parallel HDF5
# installations, so recognize either reported variable.
if(HDF5_IS_PARALLEL OR HDF5_PROVIDES_PARALLEL)
  add_definitions(-DH5_HAVE_PARALLEL)
endif()

if(NOT TARGET ESMF::ESMF)
  # Prefer the config package installed by ESMF 9.  In particular, this lets
  # a loaded Spack environment provide ESMF through CMAKE_PREFIX_PATH without
  # requiring users to set ESMF_DIR themselves.
  set(_esma_esmf_config_hints)
  foreach(_esma_esmf_mkfile IN ITEMS "${ESMFMKFILE}" "$ENV{ESMFMKFILE}")
    if(_esma_esmf_mkfile AND EXISTS "${_esma_esmf_mkfile}")
      get_filename_component(_esma_esmf_libdir "${_esma_esmf_mkfile}" DIRECTORY)
      get_filename_component(_esma_esmf_prefix "${_esma_esmf_libdir}" DIRECTORY)
      list(APPEND _esma_esmf_config_hints "${_esma_esmf_prefix}")
      break()
    endif()
  endforeach()

  find_package(ESMF ${ESMA_ESMF_MIN_VERSION} CONFIG QUIET
               HINTS ${_esma_esmf_config_hints})

  if(NOT ESMF_FOUND)
    # ESMF 8 and older ESMF 9 installations may provide only esmf.mk.
    if(NOT DEFINED ESMFMKFILE AND _esma_esmf_config_hints)
      list(GET _esma_esmf_config_hints 0 _esma_esmf_prefix)
      set(ESMFMKFILE "${_esma_esmf_prefix}/lib/esmf.mk")
    endif()
    find_package(ESMF ${ESMA_ESMF_MIN_VERSION} MODULE REQUIRED)
    target_link_libraries(ESMF::ESMF INTERFACE MPI::MPI_Fortran)
  endif()

  # GEOS uses these historical target names.  The generated config provides
  # ESMF::ESMF but not the lowercase esmf alias.
  if(NOT TARGET esmf)
    add_library(esmf ALIAS ESMF::ESMF)
  endif()
  if(NOT TARGET ESMF)
    add_library(ESMF ALIAS ESMF::ESMF)
  endif()
endif()

find_package(GFTL_SHARED REQUIRED)

find_package(ZLIB REQUIRED)
# Historical GEOS code uses this target spelling. Some ZLIB providers
# (e.g. zlib-ng's CMake config package) already export a target with
# this exact name, so only create the alias if it doesn't already exist.
if(NOT TARGET ZLIB::zlib)
  add_library(ZLIB::zlib ALIAS ZLIB::ZLIB)
endif()

# We only need to look for FMS if we need it. Projects like MAPL don't
# use FMS, so we don't need to look for it. Mirror the Baselibs-branch
# convention (ConfigureBaselibs.cmake) of using FV_PRECISION, which
# GEOS-model top-level projects set but library projects like MAPL do
# not, as the signal that FMS is required.
if(DEFINED FV_PRECISION)
  find_package(FMS REQUIRED)

  # FMS versions before 2026.01 do not export libyaml as a dependency in
  # fms-config.cmake. Probe for the YAML module so that we add libyaml only
  # when the external FMS was built with YAML support.
  include(check_fms_yaml_support)
  check_fms_yaml_support(FMS_BUILT_WITH_YAML)
  if(FMS_BUILT_WITH_YAML)
    find_package(libyaml REQUIRED)
    message(STATUS "LIBYAML_INCLUDE_DIR: ${LIBYAML_INCLUDE_DIR}")
    message(STATUS "LIBYAML_LIBRARIES: ${LIBYAML_LIBRARIES}")
    if(TARGET FMS::fms)
      target_link_libraries(FMS::fms INTERFACE ${LIBYAML_LIBRARIES})
      message(STATUS "Linking libyaml into FMS::fms")
    endif()
  endif()
endif()

find_package(MAPL 2.70 QUIET)
if(MAPL_FOUND)
  message(STATUS "Found MAPL: ${MAPL_BASE_DIR} (found version \"${MAPL_VERSION})\"")
endif()
