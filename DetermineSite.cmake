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
   find_package(CURL)
   if (CURL_FOUND)
      execute_process(
         COMMAND curl --connect-timeout 0.1 http://169.254.169.254/latest/meta-data/instance-id
         TIMEOUT 1.0
         OUTPUT_QUIET ERROR_QUIET
         RESULT_VARIABLE STATUS
         )
      if(STATUS AND NOT STATUS EQUAL 0)
         set (DETECTED_SITE ${BUILD_SITE})
      else ()
         set (DETECTED_SITE "AWS")
      endif ()
   else ()
      set (DETECTED_SITE ${BUILD_SITE})
   endif ()
endif ()

set(GEOS_SITE ${DETECTED_SITE} CACHE STRING "Detected site for use with GEOS setup scripts")
message(STATUS "Setting GEOS_SITE to ${GEOS_SITE}")
