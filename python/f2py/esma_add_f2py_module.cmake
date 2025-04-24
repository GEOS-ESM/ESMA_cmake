macro (esma_add_f2py_module name)

  add_f2py_module (${name} ${ARGN})

  set(options USE_MPI)
  cmake_parse_arguments (esma_add_f2py_module "${options}" "" "" ${ARGN})

  # If one of the arguments is USE_MPI we need to
  # do something special on MPT systems.
  # First this only matters if we are on Python 3.12 or higher
  if (Python_VERSION VERSION_GREATER_EQUAL 3.12)
    message(DEBUG "[F2PY]: Python version is 3.12 or higher, so meson is our backend")
    message(DEBUG "[F2PY]: MPI_STACK: ${MPI_STACK}")
    # Next, check if we are using MPI and our stack is 'mpt'
    message(DEBUG "[F2PY]: Checking for USE_MPI and MPI_STACK=mpt")
    if(esma_add_f2py_module_USE_MPI AND MPI_STACK STREQUAL "mpt")
      message(DEBUG "[F2PY]: MPI_Fortran_LIBRARIES: ${MPI_Fortran_LIBRARIES}")
      # Now we need LD_PRELOAD the libmpi.so found in MPI_Fortran_LIBRARIES
      # But MPI_Fortran_LIBRARIES is a list, so we need to find the one
      # that ends with 'libmpi.so'
      foreach (mpi_lib ${MPI_Fortran_LIBRARIES})
        if (mpi_lib MATCHES "libmpi.so$")
          message(DEBUG "[F2PY]: Found libmpi.so: ${mpi_lib}")
          set(F2PY_PRELOAD "LD_PRELOAD=${mpi_lib}")
          message(STATUS "[F2PY3]: USE_MPI found and using MPT. Testing will add ${F2PY_PRELOAD}")
          break()
        endif()
      endforeach()
    endif()
  endif()

  set(UNIT_TEST test_${name})
  add_test (
    NAME ${UNIT_TEST}
    COMMAND ${CMAKE_COMMAND} -E env "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib:$ENV{LD_LIBRARY_PATH}" "${F2PY_PRELOAD}" ${Python_EXECUTABLE} -c "import ${name}"
    )

  add_custom_command(
    TARGET ${name}
    COMMENT "Running Python import test on ${name}"
    POST_BUILD
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMAND ${CMAKE_COMMAND} -E env "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib:$ENV{LD_LIBRARY_PATH}" "${F2PY_PRELOAD}" ${Python_EXECUTABLE} -c "import ${name}"
    )

endmacro ()
