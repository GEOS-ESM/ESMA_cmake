##### OS Detection #####

# At NAS, there are two OSs: TOSS4 and TOSS5. As such, if you build on TOSS5, you
# must submit from TOSS5 to TOSS5 compute nodes (and vice versa). So we need to
# detect the OS and make a file like SITE.rc

if(LINUX)
  cmake_host_system_information(RESULT os_id QUERY DISTRIB_ID)
  cmake_host_system_information(RESULT os_version QUERY DISTRIB_VERSION_ID)
  cmake_host_system_information(RESULT os_name QUERY DISTRIB_PRETTY_NAME)
elseif(APPLE)
  # cmake_host_system_information for distrib_id does not work on macOS
  cmake_host_system_information(RESULT os_id QUERY OS_NAME)
  cmake_host_system_information(RESULT os_version QUERY OS_RELEASE)
  cmake_host_system_information(RESULT os_name QUERY OS_NAME)
endif()

set(GEOS_OS_ID ${os_id} CACHE STRING "Detected OS ID for use with GEOS setup scripts")
set(GEOS_OS_VERSION ${os_version} CACHE STRING "Detected OS version for use with GEOS setup scripts")
set(GEOS_OS_NAME ${os_name} CACHE STRING "Detected OS name for use with GEOS setup scripts")
message(STATUS "Setting GEOS_OS_ID to ${GEOS_OS_ID}")
message(STATUS "Setting GEOS_OS_VERSION to ${GEOS_OS_VERSION}")
message(STATUS "Setting GEOS_OS_NAME to ${GEOS_OS_NAME}")

configure_file(OS.rc.in OS.rc @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/OS.rc DESTINATION etc)
