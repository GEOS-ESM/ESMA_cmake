macro (esma_add_f2py3_module name)

  add_f2py3_module (${name} ${ARGN})

  if (NOT CMAKE_Fortran_COMPILER_ID MATCHES GNU)
    set(UNIT_TEST test_${name})
    add_test (
      NAME ${UNIT_TEST}
      COMMAND ${CMAKE_COMMAND} -E env "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib:$ENV{LD_LIBRARY_PATH}" ${Python3_EXECUTABLE} -c "import ${name}"
      )

    add_custom_command(
      TARGET ${name}
      COMMENT "Running Python3 import test on ${name}"
      POST_BUILD
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMAND ${CMAKE_COMMAND} -E env "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib:$ENV{LD_LIBRARY_PATH}" ${Python3_EXECUTABLE} -c "import ${name}"
      )
  else ()
    # This code emits the warning once
    get_property(prop_defined GLOBAL PROPERTY GNU_F2PY3_WARNING_EMITTED DEFINED)
    if (NOT prop_defined)
      ecbuild_warn("There are currently issues with GNU and f2py3 from Conda that prevent running tests")
      define_property(GLOBAL PROPERTY GNU_F2PY3_WARNING_EMITTED BRIEF_DOCS "GNU-f2py3" FULL_DOCS "GNU-f2py3")
    endif ()
  endif ()

endmacro ()
