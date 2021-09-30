# Only add the directories in alldirs list that actually exist.  GEOS
# can build in multiple configurations, and the build system must be
# able to skip non-existent directories in the list.

# We allow nested repositories to have leading or trailing "@" in their
# name which is disregarded for everything except path.

function  (esma_add_subdirectory dir) # optional "rename" argument

  set (options)
  set (oneValueArgs FOUND RENAME)
  set (multiValueArgs)
  cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

#  string(REPLACE "@" "" dir_ ${dir})

   esma_mepo_style(${dir} mepo_dir FOUND found)
   if (found)
     add_subdirectory (${mepo_dir} ${ARGS_RENAME})
   endif ()

   if (ARGS_FOUND)
     set(${ARGS_FOUND} ${found} PARENT_SCOPE)
   else ()
    # The below should be changed to ecbuild_error() once the FOUND option
    # is propagated through client code.
    ecbuild_debug("Directory not found ${dir} (possibly sparse checkout)")
  endif ()

endfunction (esma_add_subdirectory)

function (esma_add_subdirectories dirs)
  set (dirs_ ${dirs} ${ARGN})
    ecbuild_debug ("esma_add_subdirectories:  ${dirs}")
    foreach (subdir ${dirs_})
    esma_add_subdirectory(${subdir})
  endforeach()
endfunction (esma_add_subdirectories)

