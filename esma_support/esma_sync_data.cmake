# esma_sync_data.cmake
#
# Define build-time data sync targets.
#
# Example:
#
#   include(esma_sync_data)
#
#   esma_sync_data(
#     TARGET      sync_regression_data
#     URI         s3://my-bucket/my-data
#     DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/regression_data
#     ALL
#   )
#
# Optional:
#
#   ALL
#     Add the target to the default build target so that it runs automatically
#     during a standard build (e.g., `make` or `cmake --build build`). If omitted,
#     the target is opt-in and must be invoked explicitly (e.g.,
#     `cmake --build build --target <TARGET>`).
#
#     Use ALL when a regression test tree must have the data before tests can run,
#     and users expect "build everything" to prepare the data.
#
#     Omit ALL to avoid unexpected network operations or errors during generic
#     builds (e.g., on compute nodes without internet access).
#
#   REQUIRED
#     Make sync failures fatal. By default, failures are non-fatal so builds on
#     compute nodes without internet access can continue.
#
#   API_KEY_ENV
#     Name of the environment variable holding the API key.
#
#   CREDENTIALS_URL
#     URL of the credentials endpoint.
#
#   INTERNET_CHECK_URL
#     Optional URL used as a cheap build-node internet probe before requesting
#     credentials. If omitted, the credentials request itself is the reachability
#     test.
#
#   AWS_CLI
#     Path or command name for the AWS CLI. Defaults to "aws", resolved at build
#     time via PATH.

include_guard(GLOBAL)

function(esma_sync_data)
  set(options
    ALL
    REQUIRED
  )

  set(oneValueArgs
    TARGET
    URI
    DESTINATION
    API_KEY_ENV
    CREDENTIALS_URL
    INTERNET_CHECK_URL
    AWS_CLI
  )

  set(multiValueArgs)

  cmake_parse_arguments(ARG
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(ARG_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR
      "esma_sync_data: unrecognized arguments: ${ARG_UNPARSED_ARGUMENTS}"
    )
  endif()

  if(NOT ARG_TARGET)
    message(FATAL_ERROR "esma_sync_data: TARGET is required")
  endif()

  if(NOT ARG_URI)
    message(FATAL_ERROR "esma_sync_data: URI is required")
  endif()

  if(NOT ARG_DESTINATION)
    message(FATAL_ERROR "esma_sync_data: DESTINATION is required")
  endif()

  if(NOT ARG_API_KEY_ENV)
    set(ARG_API_KEY_ENV "AWS_API_KEY_GMAO_SITEAM_S3")
  endif()

  if(NOT ARG_CREDENTIALS_URL)
    set(ARG_CREDENTIALS_URL
      "https://api.example.com/credentials"
    )
  endif()

  if(NOT ARG_AWS_CLI)
    set(ARG_AWS_CLI "aws")
  endif()

  if(ARG_REQUIRED)
    set(_required TRUE)
  else()
    set(_required FALSE)
  endif()

  set(_all)
  if(ARG_ALL)
    set(_all ALL)
  endif()

  set(_script "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/esma_sync_data_script.cmake")
  set(_work_dir "${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}_work")

  add_custom_target(${ARG_TARGET} ${_all}
    COMMAND ${CMAKE_COMMAND} -E make_directory "${ARG_DESTINATION}"
    COMMAND ${CMAKE_COMMAND} -E make_directory "${_work_dir}"
    COMMAND ${CMAKE_COMMAND}
      "-DAWS_CLI=${ARG_AWS_CLI}"
      "-DS3_URI=${ARG_URI}"
      "-DLOCAL_DIR=${ARG_DESTINATION}"
      "-DWORK_DIR=${_work_dir}"
      "-DAPI_KEY_ENV=${ARG_API_KEY_ENV}"
      "-DCREDENTIALS_URL=${ARG_CREDENTIALS_URL}"
      "-DINTERNET_CHECK_URL=${ARG_INTERNET_CHECK_URL}"
      "-DREQUIRED=${_required}"
      -P "${_script}"
    COMMENT "Syncing data from ${ARG_URI}"
    VERBATIM
  )
endfunction()
