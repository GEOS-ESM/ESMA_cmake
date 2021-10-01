#
# Usage:  esma_check_python2_module(<module>)
#
# Adapted from
# Citation: https://cmake.org/pipermail/cmake/2011-January/041666.html
# Mark Moll

function(esma_check_python2_module module)

  add_test (check_python2_${module}
    COMMAND "${Python2_EXECUTABLE}" "-c" 
    "import re, ${module}; print(re.compile('/__init__.py.*').sub('',${module}.__file__))"
    )

endfunction (esma_check_python2_module)
