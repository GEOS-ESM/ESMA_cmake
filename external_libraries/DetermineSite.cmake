# Set the site variable

set(DETECTED_SITE "UNKNOWN")

# In ecbuild, ecbuild itself sets a site_name for us 
# called BUILD_SITE. If it didn't, we could use
# site_name(BUILD_SITE) as they do

# Here we try to detect the site using the hostname essentially. This we can pretty easily do
# because we know the NASA systems.

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
  else ()
    set (BUILT_ON_SLES15 FALSE)
  endif ()
elseif (${BUILD_SITE} MATCHES "pfe" OR ${BUILD_SITE} MATCHES "r[0-9]*i[0-9]*n[0-9]*" OR ${BUILD_SITE} MATCHES "r[0-9]*c[0-9]*t[0-9]*n[0-9]*")
  set (DETECTED_SITE "NAS")
elseif (EXISTS /ford1/share/gmao_SIteam AND EXISTS /ford1/local AND ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set (DETECTED_SITE "GMAO.desktop")
endif ()

# If we didn't detect the site, try to detect AWS
if (NOT DEFINED DETECTED_SITE OR DETECTED_SITE STREQUAL "UNKNOWN")
  # Try to detect AWS
  file(DOWNLOAD http://169.254.169.254/latest/meta-data/instance-id ${CMAKE_CURRENT_BINARY_DIR}/instance-id
    INACTIVITY_TIMEOUT 1.0
    TIMEOUT 1.0
    STATUS DOWNLOAD_STATUS
    )
  list(GET DOWNLOAD_STATUS 0 RETURN_CODE)

  if (RETURN_CODE EQUAL 0)
    set (DETECTED_SITE "AWS")
  endif ()
endif ()

# If we didn't detect AWS, we look for Azure
if (NOT DEFINED DETECTED_SITE OR DETECTED_SITE STREQUAL "UNKNOWN")
  # Per https://learn.microsoft.com/en-us/azure/virtual-machines/linux/instance-metadata-service?tabs=linux
  # it says you can run:
  # curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq
  # to know more about the instance. Well, we don't need jq, we just need to know if we can get to 
  # that page. So we'll just try to download it.
  file(DOWNLOAD http://169.254.169.254/metadata/instance?api-version=2021-02-01 ${CMAKE_CURRENT_BINARY_DIR}/instance
    HTTPHEADER "Metadata:true"
    INACTIVITY_TIMEOUT 1.0
    TIMEOUT 1.0
    STATUS DOWNLOAD_STATUS
    )

  list(GET DOWNLOAD_STATUS 0 RETURN_CODE)

  if (RETURN_CODE EQUAL 0)
    set (DETECTED_SITE "Azure")
  endif ()
endif ()

# Note: No access to Google Cloud yet but my guess is we do something similar following:
# https://cloud.google.com/compute/docs/instances/detect-compute-engine

# Finally, if we didn't detect anything, we'll just use the BUILD_SITE
if (NOT DEFINED DETECTED_SITE OR DETECTED_SITE STREQUAL "UNKNOWN")
  set (DETECTED_SITE ${BUILD_SITE})
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

