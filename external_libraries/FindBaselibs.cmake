# Determine whether this build uses a Baselibs installation.  Dependency
# targets for the selected provider are configured by the top-level project.
set(Baselibs_FOUND FALSE CACHE BOOL "Baselibs Found")

# Detect BASEDIR from the environment when it was not passed on the command
# line.
if(NOT BASEDIR AND DEFINED ENV{BASEDIR})
  message(STATUS "BASEDIR not set on command line, but found BASEDIR in the environment")
  set(BASEDIR $ENV{BASEDIR})
  set(BASEDIR_FROM_ENVIRONMENT TRUE)
else()
  set(BASEDIR_FROM_ENVIRONMENT FALSE)
endif()

# GEOS Baselibs installations have the form BASEDIR/ARCH/lib, where ARCH is
# CMAKE_HOST_SYSTEM_NAME.
if(BASEDIR)
  if(IS_DIRECTORY ${BASEDIR}/lib)
    get_filename_component(SHOULD_BE_ARCH ${BASEDIR} NAME)
    if(NOT SHOULD_BE_ARCH STREQUAL ${CMAKE_HOST_SYSTEM_NAME})
      message(FATAL_ERROR
        "GEOS requires that BASEDIR be such that /path/to/baselibs/${CMAKE_HOST_SYSTEM_NAME}/lib exists\n"
        "However, you provided\n"
        "   ${BASEDIR} \n"
        "which does not have the correct format. Please make sure BASEDIR is correctly built and set."
      )
    endif()

    set(Baselibs_FOUND TRUE CACHE BOOL "Baselibs Found" FORCE)
    message(STATUS "BASEDIR: ${BASEDIR}")
  elseif(IS_DIRECTORY ${BASEDIR}/${CMAKE_HOST_SYSTEM_NAME}/lib)
    message(STATUS "BASEDIR passed in without ${CMAKE_HOST_SYSTEM_NAME}. Setting BASEDIR internally to ${BASEDIR}/${CMAKE_HOST_SYSTEM_NAME}.")
    set(BASEDIR ${BASEDIR}/${CMAKE_HOST_SYSTEM_NAME})
    set(Baselibs_FOUND TRUE CACHE BOOL "Baselibs Found" FORCE)
    message(STATUS "BASEDIR: ${BASEDIR}")
  else()
    if(BASEDIR_FROM_ENVIRONMENT)
      set(EXTRA_TEXT "in the environment, ")
    endif()
    message(FATAL_ERROR
      "GEOS requires that BASEDIR be such that /path/to/baselibs/${CMAKE_HOST_SYSTEM_NAME}/lib exists\n"
      "However, we found\n"
      "   ${BASEDIR} \n"
      "${EXTRA_TEXT}but a good path does not seem to exist. Please check your input"
    )
  endif()
  set(BASEDIR "${BASEDIR}" CACHE PATH "Path to installed baselibs" FORCE)
else()
  message(STATUS "BASEDIR not set. Baselibs not found. Assume we are using Spack or other methods to provide dependencies")
endif()

if(ESMA_SDF)
  message(FATAL_ERROR "ERROR: -hdf option was thought to be obsolete when CMake was crafted.")
endif()
