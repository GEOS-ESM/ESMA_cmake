# At the top of your check_fms1_io_support.cmake file, BEFORE the macro definition
set(_CHECK_FMS1_IO_SUPPORT_DIR "${CMAKE_CURRENT_LIST_DIR}")

macro(check_fms1_io_support result_var)
  # Get include directories from the FMS target
  set(FMS_TARGET FMS::fms)
  get_target_property(FMS_INCLUDE_DIRS ${FMS_TARGET} INTERFACE_INCLUDE_DIRECTORIES)

  # Handle cases where properties might not be set
  if(NOT FMS_INCLUDE_DIRS)
    set(FMS_INCLUDE_DIRS "")
  endif()

  # Set the test file path
  set(TEST_FILE_PATH "${_CHECK_FMS1_IO_SUPPORT_DIR}/test_fms1_io.f90")
  if(NOT EXISTS "${TEST_FILE_PATH}")
    message(FATAL_ERROR "FMS1 IO test file not found: ${TEST_FILE_PATH}")
  endif()

  # Save the current value
  set(_SAVED_CMAKE_TRY_COMPILE_TARGET_TYPE ${CMAKE_TRY_COMPILE_TARGET_TYPE})

  # Set to static library (compile only, no linking)
  set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

  # Build CMAKE_FLAGS
  set(CMAKE_FLAGS_LIST "")
  if(FMS_INCLUDE_DIRS)
    list(APPEND CMAKE_FLAGS_LIST "-DINCLUDE_DIRECTORIES=${FMS_INCLUDE_DIRS}")
  endif()

  # Try to compile the test
  try_compile(${result_var}
    ${CMAKE_BINARY_DIR}/test_fms1_compile
    SOURCES ${TEST_FILE_PATH}
    CMAKE_FLAGS ${CMAKE_FLAGS_LIST}
  )

  # Restore the previous value
  set(CMAKE_TRY_COMPILE_TARGET_TYPE ${_SAVED_CMAKE_TRY_COMPILE_TARGET_TYPE})

  if(${result_var})
    message(STATUS "FMS1 IO support is available.")
  else()
    message(STATUS "FMS1 IO support is NOT available.")
  endif()
endmacro()
