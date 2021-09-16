#
# Usage:  esma_find_python2_module(<module> [REQUIRED])
#

# Citation: https://cmake.org/pipermail/cmake/2011-January/041666.html
# Mark Moll

function(esma_find_python2_module module)
  string(TOUPPER ${module} module_upper)
  if(NOT PY2_${module_upper})
    if(ARGC GREATER 1 AND ARGV1 STREQUAL "REQUIRED")
      set(PY2_${module}_FIND_REQUIRED TRUE)
    endif()
    # A module's location is usually a directory, but for binary modules
    # it's a .so file.
    execute_process(COMMAND "${Python2_EXECUTABLE}" "-c" 
      "import re, ${module}; print(re.compile('/__init__.py.*').sub('',${module}.__file__))"
      RESULT_VARIABLE _${module}_status 
      OUTPUT_VARIABLE _${module}_location
      ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT _${module}_status)
      set(PY2_${module_upper} ${_${module}_location} CACHE STRING 
	"Location of Python2 module ${module}")
    endif(NOT _${module}_status)
  endif(NOT PY2_${module_upper})
  find_package_handle_standard_args(PY2_${module} DEFAULT_MSG PY2_${module_upper})
  set (PY2_${module}_FOUND ${PY2_${module}_FOUND} PARENT_SCOPE)
  set (PY2_${module_upper}_FOUND ${PY2_${module_upper}_FOUND} PARENT_SCOPE)

endfunction(esma_find_python2_module)


