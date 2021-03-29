macro (esma_add_f2py2_module name)

  add_f2py2_module (${name} ${ARGN})

  add_test (
    NAME test_${name}
    COMMAND ${Python2_EXECUTABLE} -c "import ${name}"
    )
    
endmacro ()
