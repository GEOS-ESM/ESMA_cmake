# Set the site variable

# In ecbuild, ecbuild itself sets a site_name for us 
# called BUILD_SITE. If it didn't, we could use
# site_name(BUILD_SITE) as they do

if (${BUILD_SITE} MATCHES "discover*" OR ${BUILD_SITE} MATCHES "borg*")
   set (DETECTED_SITE "NCCS")
elseif (${BUILD_SITE} MATCHES "pfe" OR ${BUILD_SITE} MATCHES "r[0-9]*i[0-9]*n[0-9]*" OR ${BUILD_SITE} MATCHES "maia*")
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
