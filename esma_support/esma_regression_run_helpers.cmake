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
  cmake_parse_arguments(COMPARE "NANS_ARE_EQUAL;NAN_ARE_EQUAL" "TOLERANCE" "" ${ARGN})
  if(COMPARE_NAN_ARE_EQUAL)
    set(COMPARE_NANS_ARE_EQUAL TRUE)
  endif()
  if(NOT COMPARE_TOLERANCE AND COMPARE_UNPARSED_ARGUMENTS)
    list(LENGTH COMPARE_UNPARSED_ARGUMENTS _unparsed_len)
    if(_unparsed_len EQUAL 1)
      set(COMPARE_TOLERANCE "${COMPARE_UNPARSED_ARGUMENTS}")
    endif()
  endif()
  if(NOT COMPARE_TOLERANCE AND DEFINED REGRESSION_TOLERANCE)
    set(COMPARE_TOLERANCE "${REGRESSION_TOLERANCE}")
  elseif(NOT COMPARE_TOLERANCE AND DEFINED TOLERANCE)
    set(COMPARE_TOLERANCE "${TOLERANCE}")
  endif()

  if(NOT COMPARE_NANS_ARE_EQUAL)
    if(DEFINED REGRESSION_NANS_ARE_EQUAL AND REGRESSION_NANS_ARE_EQUAL)
      set(COMPARE_NANS_ARE_EQUAL TRUE)
    elseif(DEFINED NANS_ARE_EQUAL AND NANS_ARE_EQUAL)
      set(COMPARE_NANS_ARE_EQUAL TRUE)
    endif()
  endif()

  find_program(NCCMP_EXECUTABLE nccmp)
  if(NCCMP_EXECUTABLE)
    set(COMPARE_COMMAND ${NCCMP_EXECUTABLE} -dmfgsB)
    if(COMPARE_NANS_ARE_EQUAL)
      list(APPEND COMPARE_COMMAND --nans-are-equal)
    endif()
    if(COMPARE_TOLERANCE)
      list(APPEND COMPARE_COMMAND --tolerance ${COMPARE_TOLERANCE})
    endif()
  else()
    set(COMPARE_COMMAND cmp)
  endif()

  file(GLOB baseline_files ${baseline_dir}/*.nc)
  foreach(baseline_file IN LISTS baseline_files)
    get_filename_component(fname ${baseline_file} NAME)
    message(STATUS "Comparing ${fname}")
    execute_process(
      COMMAND ${COMPARE_COMMAND} ${baseline_file} ${current_dir}/${fname}
      RESULT_VARIABLE CMP_RESULT
      OUTPUT_VARIABLE CMP_OUTPUT
      ERROR_VARIABLE CMP_OUTPUT
    )
    if(CMP_RESULT)
      message(FATAL_ERROR "Files differ: ${fname}\n${CMP_OUTPUT}")
    endif()
  endforeach()
endfunction()
