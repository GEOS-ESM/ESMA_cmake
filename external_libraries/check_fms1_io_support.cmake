# At the top of your check_fms1_io_support.cmake file, BEFORE the macro definition
set(_CHECK_FMS1_IO_SUPPORT_DIR "${CMAKE_CURRENT_LIST_DIR}")

# Test if FMS library supports the deprecated FMS1 IO interface
macro(check_fms1_io_support result_var)

  # Use the captured directory
  set(TEST_FILE_PATH "${_CHECK_FMS1_IO_SUPPORT_DIR}/test_fms1_io.f90")
  message(DEBUG "Checking for FMS1 IO support in FMS library using test file: ${TEST_FILE_PATH}")

  # Get include directories from the FMS target
  get_target_property(FMS_INCLUDE_DIRS FMS::fms_r4 INTERFACE_INCLUDE_DIRECTORIES)
  get_target_property(FMS_LINK_LIBRARIES FMS::fms_r4 INTERFACE_LINK_LIBRARIES)

  # Try to compile the tesy
  try_compile(${result_var}
    ${CMAKE_BINARY_DIR}/test_fms1_compile
    SOURCES "${TEST_FILE_PATH}"
    CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${FMS_INCLUDE_DIRS} -DLINK_LIBRARIES=${FMS_LINK_LIBRARIES}"
  )

  if(${result_var})
    message(STATUS "FMS1 IO support is available.")
  else()
    message(STATUS "FMS1 IO support is NOT available.")
  endif()

endmacro()

