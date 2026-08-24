# esma_regression_tests.cmake
# Provides esma_add_regression_tests() for use in component regression
# subdirectories. Each component passes its short name and S3 data path;
# everything else is identical across components.
#
# Usage:
#   esma_add_regression_tests(
#     NAME       <short-name>   # e.g. "gwd", "gocart2g", "fv3"
#     DATA_PATH  <rel-path>     # relative path under regression-data/
#     TEST_CASES <case> ...     # list of test case names to register
#     [EXTRA_ENV VAR=val ...]   # additional environment variables for tests
#     [LABELS label ...]        # additional CTest labels
#   )

# Capture the directory of this file at include time so the macro can
# reference sibling scripts without relying on find_file().
set(_ESMA_REGRESSION_TESTS_DIR "${CMAKE_CURRENT_LIST_DIR}")

macro(esma_add_regression_tests)
  cmake_parse_arguments(_REG "" "NAME;DATA_PATH" "TEST_CASES;EXTRA_ENV;LABELS" ${ARGN})

  if(NOT _REG_NAME)
    message(FATAL_ERROR "esma_add_regression_tests: NAME is required")
  endif()
  if(NOT _REG_DATA_PATH)
    message(FATAL_ERROR "esma_add_regression_tests: DATA_PATH is required")
  endif()
  if(NOT _REG_TEST_CASES)
    message(FATAL_ERROR "esma_add_regression_tests: TEST_CASES is required")
  endif()

  if(APPLE)
    set(LD_PATH "DYLD_LIBRARY_PATH")
  else()
    set(LD_PATH "LD_LIBRARY_PATH")
    # OpenMPI flags
    string(REPLACE " " ";" MPI_Fortran_LIBRARY_VERSION_LIST ${MPI_Fortran_LIBRARY_VERSION_STRING})
    list(GET MPI_Fortran_LIBRARY_VERSION_LIST 0 MPI_Fortran_LIBRARY_VERSION_FIRSTWORD)
    if(MPI_Fortran_LIBRARY_VERSION_FIRSTWORD MATCHES "Open")
      set(MPIEXEC_PREFLAGS "--oversubscribe;--bind-to;core;--map-by;core" CACHE STRING "Flags for mpiexec" FORCE)
    endif()
  endif()

  if(DEFINED ENV{LOCAL_REGRESSION_DATA_DIR} AND NOT "$ENV{LOCAL_REGRESSION_DATA_DIR}" STREQUAL "")
    set(_REG_DATA_DIR "$ENV{LOCAL_REGRESSION_DATA_DIR}/${_REG_DATA_PATH}")
  else()
    set(_REG_DATA_DIR "${CMAKE_BINARY_DIR}/regression-data/${_REG_DATA_PATH}")
  endif()

  # Fixture test: sync regression data from S3 at ctest (NOT configure) time
  add_test(
    NAME ${_REG_NAME}/sync_data
    COMMAND ${CMAKE_COMMAND}
      "-DLOCAL_DIR=${_REG_DATA_DIR}"
      "-DWORK_DIR=${CMAKE_BINARY_DIR}/regression-data/sync_work/${_REG_NAME}"
      "-DESMA_SYNC_DATA_SCRIPT=${_ESMA_REGRESSION_TESTS_DIR}/esma_sync_data_script.cmake"
      "-DS3_URI=s3://gmao-usw2-si-team/regression-data/${_REG_DATA_PATH}"
      -P "${_ESMA_REGRESSION_TESTS_DIR}/esma_sync_aws_s3_data.cmake"
  )
  set_tests_properties(${_REG_NAME}/sync_data PROPERTIES
    FIXTURES_SETUP ${_REG_NAME}_regression_data
  )

  # Build environment string once; shared across all test cases in this component
  set(_REG_ENV "${LD_PATH}=${CMAKE_BINARY_DIR}/lib:$ENV{${LD_PATH}}")
  foreach(_env_var ${_REG_EXTRA_ENV})
    string(APPEND _REG_ENV ";${_env_var}")
  endforeach()

  # Regression tests
  foreach(TEST_CASE ${_REG_TEST_CASES})
    add_test(
      NAME "${TEST_CASE}"
      COMMAND ${CMAKE_COMMAND}
        -DTEST_CASE=${TEST_CASE}
        -DFORTRAN_COMPILER_ID=${CMAKE_Fortran_COMPILER_ID}
        -DMPIEXEC_EXECUTABLE=${MPIEXEC_EXECUTABLE}
        -DMPIEXEC_NUMPROC_FLAG=${MPIEXEC_NUMPROC_FLAG}
        -DMY_BINARY_DIR=${CMAKE_BINARY_DIR}/bin
        "-DMPIEXEC_PREFLAGS=${MPIEXEC_PREFLAGS}"
        -DREGRESSION_DATA_DIR=${_REG_DATA_DIR}
        "-DESMA_REGRESSION_HELPERS=${_ESMA_REGRESSION_TESTS_DIR}/esma_regression_run_helpers.cmake"
        -P ${CMAKE_CURRENT_SOURCE_DIR}/run_case.cmake
    )
    set_tests_properties("${TEST_CASE}" PROPERTIES
      LABELS "REGRESSION;${_REG_LABELS}"
      ENVIRONMENT "${_REG_ENV}"
      FIXTURES_REQUIRED ${_REG_NAME}_regression_data
    )
  endforeach()
endmacro()
