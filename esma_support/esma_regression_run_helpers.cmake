# esma_regression_run_helpers.cmake
# Shared helper functions for component regression test run_case.cmake scripts.
# Included via include("${ESMA_REGRESSION_HELPERS}") at the top of each
# per-component run_case.cmake.

function(copy_directory source destination)
  if(EXISTS ${source})
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${source} ${destination})
  else()
    message(FATAL_ERROR "Source directory not found: ${source}")
  endif()
endfunction()

function(link_directory source destination)
  if(EXISTS ${source})
    execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink ${source} ${destination})
  else()
    message(FATAL_ERROR "Source directory not found: ${source}")
  endif()
endfunction()

function(copy_file source destination)
  if(EXISTS ${source})
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${source} ${destination})
  else()
    message(FATAL_ERROR "Source file not found: ${source}")
  endif()
endfunction()

function(run_geos num_procs case_name expdir)
  execute_process(
    COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${num_procs} ${MPIEXEC_PREFLAGS} ${MY_BINARY_DIR}/GEOS.x cap.yaml
    RESULT_VARIABLE CMD_RESULT
    WORKING_DIRECTORY ${expdir}
    COMMAND_ECHO STDOUT
  )
  if(EXISTS ${expdir}/PET0.ESMF_LogFile)
    execute_process(COMMAND ${CMAKE_COMMAND} -E cat ${expdir}/PET0.ESMF_LogFile)
  endif()
  if(CMD_RESULT)
    message(FATAL_ERROR "Error running ${case_name}")
  endif()
endfunction()

function(copy_restarts root_dir expdir)
  file(GLOB checkpoint_subdirs LIST_DIRECTORIES true ${root_dir}/checkpoints/*)
  foreach(ckpt_dir IN LISTS checkpoint_subdirs)
    get_filename_component(ckpt_name ${ckpt_dir} NAME)
    if(IS_DIRECTORY ${ckpt_dir} AND NOT ckpt_name STREQUAL "last")
      copy_directory(${ckpt_dir} ${expdir}/checkpoints/${ckpt_name})
    endif()
  endforeach()
endfunction()

function(compare_results baseline_dir current_dir)
  file(GLOB baseline_files ${baseline_dir}/*.nc)
  foreach(baseline_file IN LISTS baseline_files)
    get_filename_component(fname ${baseline_file} NAME)
    message(STATUS "Comparing ${fname}")
    execute_process(
      COMMAND cmp ${baseline_file} ${current_dir}/${fname}
      RESULT_VARIABLE CMP_RESULT
      OUTPUT_VARIABLE CMP_OUTPUT
      ERROR_VARIABLE CMP_OUTPUT
    )
    if(CMP_RESULT)
      message(FATAL_ERROR "Files differ: ${fname}\n${CMP_OUTPUT}")
    endif()
  endforeach()
endfunction()
