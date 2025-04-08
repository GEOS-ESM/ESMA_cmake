function (esma_mepo_style raw_name mepo_name)

  set (options)
  set (oneValueArgs REL_PATH FOUND)
  set (multiValueArgs)
  cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set (path "")
  if (ARGS_REL_PATH)
    set (path "${ARGS_REL_PATH}/")
  endif ()
  ecbuild_debug("Searching for mepo style variant for $[dir}")

  foreach(subdir ${raw_name} @${raw_name} ${raw_name}@)
    if (IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${path}${subdir}")
      set(${mepo_name} ${path}${subdir} PARENT_SCOPE)
      if (ARGS_FOUND)
	set(${ARGS_FOUND} TRUE PARENT_SCOPE)
      endif ()
      return()
    endif ()

  endforeach ()

  # Failed if got to here
  if (ARGS_FOUND)
    set(${ARGS_FOUND} FALSE PARENT_SCOPE)
  else ()
    ecbuild_error("Directory not found ${dir} (possibly sparse checkout)")
  endif ()
endfunction ()

