enable_testing()
find_package(PFUNIT QUIET)

if(NOT TARGET build-tests)
  add_custom_target(build-tests)
endif()
if(NOT TARGET tests)
  add_custom_target(tests
    COMMAND ${CMAKE_CTEST_COMMAND} -L 'ESSENTIAL' --output-on-failure
    EXCLUDE_FROM_ALL
    USES_TERMINAL
  )
  add_dependencies(tests build-tests)
endif()

if(NOT TARGET tests-all)
  add_custom_target(tests-all
    COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
    EXCLUDE_FROM_ALL
    USES_TERMINAL
  )
  add_dependencies(tests-all build-tests)
endif()
