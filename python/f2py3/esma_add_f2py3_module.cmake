macro (esma_add_f2py3_module name)

  add_f2py3_module (${name} ${ARGN})

  set(options USE_MPI)
  cmake_parse_arguments (esma_add_f2py3_module "${options}" "" "" ${ARGN})

  # If one of the arguments is USE_MPI we need to
  # do something special on MPT systems.
  # First this only matters if we are on Python 3.12 or higher
  if (Python3_VERSION VERSION_GREATER_EQUAL 3.12)
    message(DEBUG "[F2PY3]: Python version is 3.12 or higher, so meson is our backend")
    message(DEBUG "[F2PY3]: MPI_STACK: ${MPI_STACK}")
    # Next, check if we are using MPI and our stack is 'mpt'
    message(DEBUG "[F2PY3]: Checking for USE_MPI and MPI_STACK=mpt")
    if(esma_add_f2py3_module_USE_MPI AND MPI_STACK STREQUAL "mpt")
      message(DEBUG "[F2PY3]: MPI_Fortran_LIBRARIES: ${MPI_Fortran_LIBRARIES}")
      # Now we need LD_PRELOAD the libmpi.so found in MPI_Fortran_LIBRARIES
      # But MPI_Fortran_LIBRARIES is a list, so we need to find the one
      # that ends with 'libmpi.so'
      foreach (mpi_lib ${MPI_Fortran_LIBRARIES})
        if (mpi_lib MATCHES "libmpi.so$")
          message(DEBUG "[F2PY3]: Found libmpi.so: ${mpi_lib}")
          set(F2PY3_PRELOAD "LD_PRELOAD=${mpi_lib}")
          message(STATUS "[F2PY3]: USE_MPI found and using MPT. Testing will add ${F2PY3_PRELOAD}")
          break()
        endif()
      endforeach()
    endif()
  endif()

# --- NEW: Robust Fortran Runtime Path Detection ---
  # Ask the compiler exactly where libgfortran is
  execute_process(
    COMMAND ${CMAKE_Fortran_COMPILER} -print-file-name=libgfortran.dylib
    OUTPUT_VARIABLE _libgfortran_full_path
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  get_filename_component(_fortran_lib_dir "${_libgfortran_full_path}" DIRECTORY)

  # Also include the build tree lib directory
  set(_base_paths "${CMAKE_BINARY_DIR}/lib:${_fortran_lib_dir}")

  # Construct environment list safely
  set(_test_env
    "LD_LIBRARY_PATH=${_base_paths}:$ENV{LD_LIBRARY_PATH}"
    "DYLD_LIBRARY_PATH=${_base_paths}:$ENV{DYLD_LIBRARY_PATH}"
  )

  if(F2PY3_PRELOAD)
    list(APPEND _test_env "${F2PY3_PRELOAD}")
  endif()
  # --------------------------------------------------

  set(UNIT_TEST test_${name})
  add_test (
    NAME ${UNIT_TEST}
    COMMAND ${CMAKE_COMMAND} -E env ${_test_env} ${Python3_EXECUTABLE} -c "import ${name}"
  )

  add_custom_command(
    TARGET ${name}
    COMMENT "Running Python3 import test on ${name}"
    POST_BUILD
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    # Pass the list directly to -E env
    COMMAND ${CMAKE_COMMAND} -E env ${_test_env} ${Python3_EXECUTABLE} -c "import ${name}"
  )

endmacro ()
