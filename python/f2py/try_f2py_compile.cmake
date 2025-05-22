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
     set(MESON_F2PY_FCOMPILER "ifort -diag-disable=10448")
   else ()
     set(MESON_F2PY_FCOMPILER "${CMAKE_Fortran_COMPILER}")
   endif ()
   message(DEBUG "MESON_F2PY_FCOMPILER is set to ${MESON_F2PY_FCOMPILER}")
   message(DEBUG "F2PY_COMPILER is set to ${F2PY_COMPILER}")
   # hack for Macs. If the C compiler is clang and we are on Apple,
   # we need to set the CC environment to /usr/bin/clang
   if(APPLE AND CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
     set(MESON_CCOMPILER "/usr/bin/clang")
     message(STATUS "Detected AppleClang on macOS. Using ugly hack for meson by passing in CC=/usr/bin/clang")
   else()
     set(MESON_CCOMPILER "${CMAKE_C_COMPILER}")
   endif()
   message(DEBUG "MESON_CCOMPILER is set to ${MESON_CCOMPILER}")
   list(APPEND ENV_LIST FC=${MESON_F2PY_FCOMPILER})
   list(APPEND ENV_LIST CC=${MESON_CCOMPILER})
   list(APPEND ENV_LIST TMPDIR=${_f2py_check_bindir})
   message(DEBUG "ENV_LIST is set to ${ENV_LIST}")
   execute_process(
     COMMAND cmake -E env ${ENV_LIST} ${F2PY_EXECUTABLE} -m test_ -c ${file} --fcompiler=${F2PY_FCOMPILER}
     WORKING_DIRECTORY ${_f2py_check_bindir}
     RESULT_VARIABLE result
     OUTPUT_QUIET
     ERROR_QUIET
     )

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
