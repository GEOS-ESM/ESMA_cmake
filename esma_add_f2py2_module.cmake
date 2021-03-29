macro (esma_add_f2py2_module name)

  add_f2py2_module (${name} ${ARGN})

  set(UNIT_TEST test_${name})
  add_test (
     NAME ${UNIT_TEST}
     COMMAND ${Python2_EXECUTABLE} -c "import ${name}"
     )

  add_custom_command(
     TARGET ${name}
     COMMENT "Running Python2 import test on ${name}"
     POST_BUILD
     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
     COMMAND ${Python2_EXECUTABLE} -c "import ${name}"
     )

endmacro ()
