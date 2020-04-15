# Only add the directories in alldirs list that actually exist.  GEOS
# can build in multiple configurations, and the build system must be
# able to skip non-existent directories in the list.

# We allow nested repositories to have leading or trailing "@" in their
# name which is disregarded for everything except path.

function  (esma_add_subdirectory dir)

  set (options)
  set (oneValueArgs FOUND)
  set (multiValueArgs)
  cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  string(REPLACE "@" "" dir_ ${dir})

  foreach(d ${dir_} "@${dir_}" "${dir}@")
    if (IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${d})
      add_subdirectory (${d})
      if (ARGS_FOUND)
	set (${ARGS_FOUND} TRUE PARENT_SCOPE)
      endif()
      return()
    endif()
  endforeach()

  # dir not found
  if (ARGS_FOUND)
    set (${ARGS_FOUND} FALSE PARENT_SCOPE)
  else ()
    # The below should be changed to ecbuild_error() once the FOUND option
    # is propagated through client code.
    ecbuild_info(" directory not found ${dir} (possibly sparse checkout)")
  endif()

endfunction (esma_add_subdirectory)

function (esma_add_subdirectories dirs)
  set (dirs_ ${dirs} ${ARGN})
    ecbuild_debug ("esma_add_subdirectories:  ${dirs}")
  foreach (subdir ${dirs_})
    esma_add_subdirectory(${subdir})
  endforeach()
endfunction (esma_add_subdirectories)

