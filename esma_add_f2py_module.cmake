macro (esma_add_f2py_module name)

  add_f2py_module (${name} ${ARGN})

  set(UNIT_TEST test_${name})
  add_test (
     NAME ${UNIT_TEST}
     COMMAND ${Python_EXECUTABLE} -c "import ${name}"
     )

  add_custom_command(
     TARGET ${name}
     COMMENT "Running Python import test on ${name}"
     POST_BUILD
     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
     COMMAND ${Python_EXECUTABLE} -c "import ${name}"
     )

endmacro ()
