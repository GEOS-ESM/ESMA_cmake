macro (esma_add_f2py_module name)

  add_f2py_module (${name} ${ARGN})

  add_test (
    NAME test_${name}
    COMMAND ${Python_EXECUTABLE} -c "import ${name}"
    )
    
endmacro ()
