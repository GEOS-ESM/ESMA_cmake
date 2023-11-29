# Set the site variable

# In ecbuild, ecbuild itself sets a site_name for us 
# called BUILD_SITE. If it didn't, we could use
# site_name(BUILD_SITE) as they do

if (${BUILD_SITE} MATCHES "discover*" OR ${BUILD_SITE} MATCHES "borg*" OR ${BUILD_SITE} MATCHES "warp*")
  set (DETECTED_SITE "NCCS")
  # NCCS now has two OSs. We need to detect if we are on SLES 15. If so, we set a flag "BUILT_ON_SLES15"
  # which we will use to make sure people building on SLES15 run on SLES15
  # The commmand we use in bash is:
  #   grep VERSION_ID /etc/os-release | cut -d= -f2 | cut -d. -f1 | sed 's/"//g'
  execute_process(
    COMMAND grep VERSION_ID /etc/os-release
    COMMAND cut -d= -f2
    COMMAND cut -d. -f1
    COMMAND sed s/\"//g
    OUTPUT_VARIABLE OS_RELEASE
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  if (OS_RELEASE STREQUAL "15")
    set (BUILT_ON_SLES15 TRUE)
  endif ()
elseif (${BUILD_SITE} MATCHES "pfe" OR ${BUILD_SITE} MATCHES "r[0-9]*i[0-9]*n[0-9]*" OR ${BUILD_SITE} MATCHES "r[0-9]*c[0-9]*t[0-9]*n[0-9]*")
   set (DETECTED_SITE "NAS")
elseif (EXISTS /ford1/share/gmao_SIteam AND EXISTS /ford1/local AND ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
   set (DETECTED_SITE "GMAO.desktop")
else ()
   file(DOWNLOAD http://169.254.169.254/latest/meta-data/instance-id ${CMAKE_CURRENT_BINARY_DIR}/instance-id
      INACTIVITY_TIMEOUT 1.0
      TIMEOUT 1.0
      STATUS DOWNLOAD_STATUS
      )
   list(GET DOWNLOAD_STATUS 0 RETURN_CODE)

   if (RETURN_CODE EQUAL 0)
      set (DETECTED_SITE "AWS")
   else ()
      set (DETECTED_SITE ${BUILD_SITE})
   endif ()
endif ()

set(GEOS_SITE ${DETECTED_SITE} CACHE STRING "Detected site for use with GEOS setup scripts")
message(STATUS "Setting GEOS_SITE to ${GEOS_SITE}")

if (DETECTED_SITE STREQUAL "NCCS")
  if (BUILT_ON_SLES15)
    message(STATUS "Building on SLES15 at NCCS. Can only run on Milan processors")
  else ()
    message(STATUS "Building on SLES12 at NCCS. Can run on Cascade Lake or Skylake processors")
  endif ()
endif ()
