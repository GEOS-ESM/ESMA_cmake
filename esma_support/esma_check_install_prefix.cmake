macro(esma_check_install_prefix)

  # Most users of this software do not (should not?) have permissions to
  # install in the cmake default of /usr/local (or equiv on other os's).
  # Below, the default is changed to a directory within the build tree
  # unless the user explicitly sets CMAKE_INSTALL_PREFIX in the cache.
  if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "default install path" FORCE )
    message(STATUS "*** Setting default install prefix to ${CMAKE_INSTALL_PREFIX}.")
    message(STATUS "*** Override with -DCMAKE_INSTALL_PREFIX=<path>.")
  endif()

  # There is an issue with CMake, make, and directories with commas 
  # in the path. CMake can add -Wl linker options to the makefiles and
  # Wl options take comma-separated lists. Until it can be figured out 
  # how (or if) CMake can generate quoted arguments to -Wl, we prevent
  # either build or install directories with a comma in the path
  if ("${CMAKE_BINARY_DIR}" MATCHES "^.*[,].*$")
    message(FATAL_ERROR
      "CMAKE_BINARY_DIR: ${CMAKE_BINARY_DIR}\n"
      "GEOS does not allow directory paths with commas. Please change your build path"
      )
  endif ()
  if ("${CMAKE_INSTALL_PREFIX}" MATCHES "^.*[,].*$")
    message(FATAL_ERROR
      "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}\n"
      "GEOS does not allow directory paths with commas. Please change your install path"
      )
  endif ()

  # Test to see if a user can actually write to the install directory they provided
  # If not, error out and tell them to change the install path
  # Set a test_file to the install path, and then try to touch a file there
  set(test_file ${CMAKE_INSTALL_PREFIX}/foo})
  # First check to see if CMAKE_INSTALL_PREFIX is a directory that exists
  if (EXISTS ${CMAKE_INSTALL_PREFIX})
    # If it exists, check to see if it is a directory
    if (NOT IS_DIRECTORY ${CMAKE_INSTALL_PREFIX})
      message(FATAL_ERROR
        "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}\n"
        "We do not allow non-directory paths. Please change your install path"
        )
    endif ()
    # If it is a directory, check to see if we can write to it
    file(WRITE ${test_file} "test")
    if (NOT EXISTS ${test_file})
      message(FATAL_ERROR
        "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}\n"
        "You do not have write access to the install path. Please change your install path"
        )
    endif ()
    # If we can write to it, remove the test file
    file(REMOVE ${test_file})
  else ()
    # If it doesn't exist, check to see if we can create it
    file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX})
    if (NOT EXISTS ${CMAKE_INSTALL_PREFIX})
      message(FATAL_ERROR
        "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}\n"
        "You do not have write access to the install path. Please change your install path"
        )
    endif ()
    # If we can create it, remove it as the install step will create it later
    file(REMOVE_RECURSE ${CMAKE_INSTALL_PREFIX})
  endif ()

endmacro(esma_check_install_prefix)
