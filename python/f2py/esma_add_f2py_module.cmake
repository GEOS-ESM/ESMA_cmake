macro (esma_add_f2py_module name)

  add_f2py_module (${name} ${ARGN})

  set(UNIT_TEST test_${name})
  add_test (
    NAME ${UNIT_TEST}
    COMMAND ${CMAKE_COMMAND} -E env "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib:$ENV{LD_LIBRARY_PATH}" ${Python_EXECUTABLE} -c "import ${name}"
    )

  add_custom_command(
    TARGET ${name}
    COMMENT "Running Python import test on ${name}"
    POST_BUILD
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMAND ${CMAKE_COMMAND} -E env "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib:$ENV{LD_LIBRARY_PATH}" ${Python_EXECUTABLE} -c "import ${name}"
    )

endmacro ()
