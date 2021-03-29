macro (esma_add_f2py3_module name)

  add_f2py3_module (${name} ${ARGN})

  add_test (
    NAME test_${name}
    COMMAND ${Python3_EXECUTABLE} -c "import ${name}"
    )
    
endmacro ()
