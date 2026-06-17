# Capture the directory of this file at include time, before the macro is invoked
# (CMAKE_CURRENT_LIST_DIR changes when the macro body runs)
set(_CHECK_FMS_YAML_SUPPORT_DIR "${CMAKE_CURRENT_LIST_DIR}")

macro(check_fms_yaml_support result_var)
  # Select the FMS target to probe against.
  set(_FMS_YAML_TARGET FMS::fms)

  get_target_property(_FMS_YAML_INCLUDE_DIRS ${_FMS_YAML_TARGET} INTERFACE_INCLUDE_DIRECTORIES)
  if(NOT _FMS_YAML_INCLUDE_DIRS)
    set(_FMS_YAML_INCLUDE_DIRS "")
  endif()

  set(_TEST_FILE_PATH "${_CHECK_FMS_YAML_SUPPORT_DIR}/test_fms_yaml.f90")
  if(NOT EXISTS "${_TEST_FILE_PATH}")
    message(FATAL_ERROR "FMS YAML test file not found: ${_TEST_FILE_PATH}")
  endif()

  # Compile-only probe (STATIC_LIBRARY avoids needing libyaml at this stage)
  set(_SAVED_CMAKE_TRY_COMPILE_TARGET_TYPE ${CMAKE_TRY_COMPILE_TARGET_TYPE})
  set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

  set(_CMAKE_FLAGS_LIST "")
  if(_FMS_YAML_INCLUDE_DIRS)
    list(APPEND _CMAKE_FLAGS_LIST "-DINCLUDE_DIRECTORIES=${_FMS_YAML_INCLUDE_DIRS}")
  endif()

  try_compile(${result_var}
    ${CMAKE_BINARY_DIR}/test_fms_yaml_compile
    SOURCES ${_TEST_FILE_PATH}
    CMAKE_FLAGS ${_CMAKE_FLAGS_LIST}
  )

  set(CMAKE_TRY_COMPILE_TARGET_TYPE ${_SAVED_CMAKE_TRY_COMPILE_TARGET_TYPE})

  if(${result_var})
    message(STATUS "FMS YAML support detected.")
  else()
    message(STATUS "FMS YAML support NOT detected.")
  endif()
endmacro()
