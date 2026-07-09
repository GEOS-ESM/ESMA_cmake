# esma_sync_aws_s3_data.cmake
# Generic script for syncing regression test data from S3.
# Invoked by esma_add_regression_tests() as a ctest fixture.
# Required inputs (via -D): LOCAL_DIR, WORK_DIR, ESMA_SYNC_DATA_SCRIPT, S3_URI

if(EXISTS "${LOCAL_DIR}")
  message(STATUS "Regression data already present: ${LOCAL_DIR} -- skipping sync")
  return()
endif()

set(AWS_CLI "aws")
set(API_KEY_ENV "AWS_API_KEY_GMAO_SITEAM_S3")
set(CREDENTIALS_URL "https://llvsm4u7ij.execute-api.us-east-1.amazonaws.com/credentials")
set(REQUIRED FALSE)

include("${ESMA_SYNC_DATA_SCRIPT}")
