# esma_sync_data_script.cmake
#
# Build-time helper script for esma_sync_data().
#
# This file is intentionally run with:
#
#   cmake -P esma_sync_data_script.cmake
#
# so that all network operations happen at build time, not configure time.

foreach(_var AWS_CLI S3_URI LOCAL_DIR WORK_DIR API_KEY_ENV CREDENTIALS_URL REQUIRED)
  if(NOT DEFINED ${_var})
    message(FATAL_ERROR "esma_sync_data_script: ${_var} was not provided")
  endif()
endforeach()

file(MAKE_DIRECTORY "${LOCAL_DIR}")
file(MAKE_DIRECTORY "${WORK_DIR}")

set(_internet_check_file "${WORK_DIR}/internet_check.out")

# Optional generic internet probe.
#
# If INTERNET_CHECK_URL is empty, skip this and let the credentials endpoint be
# the real reachability test. That is usually preferable because it tests the
# thing we actually need.
if(DEFINED INTERNET_CHECK_URL AND NOT INTERNET_CHECK_URL STREQUAL "")
  message(STATUS "Checking build-node internet access using ${INTERNET_CHECK_URL}")

  file(DOWNLOAD
    "${INTERNET_CHECK_URL}"
    "${_internet_check_file}"
    STATUS _internet_status
    TIMEOUT 10
    INACTIVITY_TIMEOUT 10
    TLS_VERIFY ON
  )

  list(GET _internet_status 0 _internet_code)
  list(GET _internet_status 1 _internet_message)

  file(REMOVE "${_internet_check_file}")

  if(NOT _internet_code EQUAL 0)
    if(REQUIRED)
      message(FATAL_ERROR
        "No internet access from this build node; cannot sync ${S3_URI}: "
        "${_internet_message}"
      )
    else()
      message(STATUS
        "Skipping data sync from ${S3_URI}: no internet access from this "
        "build node: ${_internet_message}"
      )
      return()
    endif()
  endif()
endif()

# API key must be available in the build environment.
if(NOT DEFINED ENV{${API_KEY_ENV}} OR "$ENV{${API_KEY_ENV}}" STREQUAL "")
  if(REQUIRED)
    message(FATAL_ERROR
      "Required environment variable ${API_KEY_ENV} is not set; "
      "cannot sync ${S3_URI}"
    )
  else()
    message(STATUS
      "Skipping data sync from ${S3_URI}: environment variable "
      "${API_KEY_ENV} is not set"
    )
    return()
  endif()
endif()

find_program(CURL_PROGRAM curl)

if(NOT CURL_PROGRAM)
  if(REQUIRED)
    message(FATAL_ERROR
      "curl command-line tool not found; cannot securely retrieve AWS credentials. "
      "curl is required to prevent credentials from being written to disk."
    )
  else()
    message(STATUS
      "Skipping data sync from ${S3_URI}: curl command-line tool not found."
    )
    return()
  endif()
endif()

message(STATUS "Requesting temporary AWS credentials securely via curl (in-memory)")

# Relay the API key through a temporary child-only environment variable so it
# never appears in any process command-line list (ps/top) and is never written
# to disk.  sh reads it from its own environment and pipes it to curl's stdin;
# it is only visible in /proc/<pid>/environ, readable solely by the owner and
# root.
set(ENV{_ESMA_CURL_HDR} "header = \"x-api-key: $ENV{${API_KEY_ENV}}\"")

execute_process(
  COMMAND sh -c
    "printf '%s\n' \"$_ESMA_CURL_HDR\" | \"${CURL_PROGRAM}\" -s -S -f -K - --connect-timeout 20 --max-time 30 \"${CREDENTIALS_URL}\""
  OUTPUT_VARIABLE _creds_json
  ERROR_VARIABLE _curl_err
  RESULT_VARIABLE _curl_code
)

unset(ENV{_ESMA_CURL_HDR})

if(NOT _curl_code EQUAL 0)
  string(STRIP "${_curl_err}" _curl_err_clean)
  if(REQUIRED)
    message(FATAL_ERROR
      "Could not securely retrieve AWS credentials for ${S3_URI} via curl (exit code ${_curl_code}): ${_curl_err_clean}"
    )
  else()
    message(STATUS
      "Skipping data sync from ${S3_URI}: could not securely retrieve AWS credentials: "
      "${_curl_err_clean}"
    )
    return()
  endif()
endif()

string(JSON AWS_ACCESS_KEY_ID
  ERROR_VARIABLE _json_error
  GET "${_creds_json}" AccessKeyId
)

if(_json_error)
  if(REQUIRED)
    message(FATAL_ERROR
      "Could not parse AccessKeyId from credentials response: ${_json_error}"
    )
  else()
    message(STATUS
      "Skipping data sync from ${S3_URI}: could not parse AccessKeyId from "
      "credentials response: ${_json_error}"
    )
    return()
  endif()
endif()

string(JSON AWS_SECRET_ACCESS_KEY
  ERROR_VARIABLE _json_error
  GET "${_creds_json}" SecretAccessKey
)

if(_json_error)
  if(REQUIRED)
    message(FATAL_ERROR
      "Could not parse SecretAccessKey from credentials response: ${_json_error}"
    )
  else()
    message(STATUS
      "Skipping data sync from ${S3_URI}: could not parse SecretAccessKey from "
      "credentials response: ${_json_error}"
    )
    return()
  endif()
endif()

string(JSON AWS_SESSION_TOKEN
  ERROR_VARIABLE _json_error
  GET "${_creds_json}" SessionToken
)

if(_json_error)
  if(REQUIRED)
    message(FATAL_ERROR
      "Could not parse SessionToken from credentials response: ${_json_error}"
    )
  else()
    message(STATUS
      "Skipping data sync from ${S3_URI}: could not parse SessionToken from "
      "credentials response: ${_json_error}"
    )
    return()
  endif()
endif()

message(STATUS "Syncing ${S3_URI} to ${LOCAL_DIR}")

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env
    AWS_EC2_METADATA_DISABLED=true
    AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
    AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
    AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
    ${AWS_CLI} s3 sync --only-show-errors "${S3_URI}" "${LOCAL_DIR}"
  RESULT_VARIABLE _aws_result
)

if(NOT _aws_result EQUAL 0)
  if(REQUIRED)
    message(FATAL_ERROR
      "aws s3 sync failed for ${S3_URI}; exit code: ${_aws_result}"
    )
  else()
    message(STATUS
      "Data sync from ${S3_URI} failed non-fatally; aws exit code: "
      "${_aws_result}"
    )
    return()
  endif()
endif()

message(STATUS "Finished syncing ${S3_URI}")
