# Used to determine whether compiler is able to compile and/or run a
# given snippet of source.  Useful for compiler bug workarounds and
# unsupported features.

macro (try_f2py_compile file var)

   if (NOT CMAKE_REQUIRED_QUIET)
      message (STATUS "Performing Test ${var}")
   endif ()

   set( _f2py_check_bindir "${CMAKE_BINARY_DIR}/f2py_tmp")
   file(MAKE_DIRECTORY ${_f2py_check_bindir})

   # We need to work around a meson bug with ifort and stderr output
   # Once we fully move to use ifx this can be removed
   if (IFORT_HAS_DEPRECATION_WARNING)
     message(STATUS "Using workaround for ifort with deprecation message")
     set(IFORT_IGNORE_DEPRECATION_WARNING "ifort -diag-disable=10448")
     execute_process(
       COMMAND cmake -E env "FC=${FC_WITH_SPACES}" ${F2PY_EXECUTABLE} -m test_ -c ${file} --fcompiler=${F2PY_FCOMPILER}
       WORKING_DIRECTORY ${_f2py_check_bindir}
       RESULT_VARIABLE result
       OUTPUT_QUIET
       ERROR_QUIET
       )
   else ()
     execute_process(
       COMMAND ${F2PY_EXECUTABLE} -m test_ -c ${file} --fcompiler=${F2PY_FCOMPILER}
       WORKING_DIRECTORY ${_f2py_check_bindir}
       RESULT_VARIABLE result
       OUTPUT_QUIET
       ERROR_QUIET
       )
   endif ()

   if (result EQUAL 0)
      file(GLOB F2PY_TEST_OUTPUT_FILE ${_f2py_check_bindir}/*.so)

      get_filename_component(F2PY_FOUND_EXTENSION ${F2PY_TEST_OUTPUT_FILE} EXT)

      set(F2PY_SUFFIX ${F2PY_FOUND_EXTENSION} CACHE STRING "f2py suffix")
      message(STATUS "Setting F2PY_SUFFIX to ${F2PY_SUFFIX}")
      if (NOT CMAKE_REQUIRED_QUIET)
         message(STATUS "Performing Test ${var}: SUCCESS")
      endif ()
   else ()
      if (NOT CMAKE_REQUIRED_QUIET)
         message(STATUS "Performing Test ${var}: FAILURE")
      endif ()
      message(WARNING "Test f2py compile using ${F2PY_EXECUTABLE} failed. F2PY modules will not be built. This usually indicates an incomplete Python/numpy installation.")
   endif ()

endmacro (try_f2py_compile)
