enable_testing()
find_package(PFUNIT QUIET)

add_custom_target(build-tests)
add_custom_target(tests
  COMMAND ${CMAKE_CTEST_COMMAND} -L 'ESSENTIAL' --output-on-failure
  EXCLUDE_FROM_ALL
  USES_TERMINAL
)
add_dependencies(tests build-tests)

add_custom_target(tests-all
  COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
  EXCLUDE_FROM_ALL
  USES_TERMINAL
)
add_dependencies(tests-all build-tests)

# The following forces tests to be built when using "make ctest" even if some targets
# are EXCLUDE_FROM_ALL
# From https://stackoverflow.com/questions/733475/cmake-ctest-make-test-doesnt-build-tests/56448477#56448477
build_command(CTEST_CUSTOM_PRE_TEST TARGET build-tests)
string(CONFIGURE \"@CTEST_CUSTOM_PRE_TEST@\" CTEST_CUSTOM_PRE_TEST_QUOTED ESCAPE_QUOTES)
file(WRITE "${CMAKE_BINARY_DIR}/CTestCustom.cmake" "set(CTEST_CUSTOM_PRE_TEST ${CTEST_CUSTOM_PRE_TEST_QUOTED})" "\n")
