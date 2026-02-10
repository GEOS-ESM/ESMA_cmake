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
