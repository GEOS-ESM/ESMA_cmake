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

function(compare_netcdf_files baseline_file current_file)
  cmake_parse_arguments(COMPARE "NANS_ARE_EQUAL;NAN_ARE_EQUAL;JOIN_TOLERANCES" "ABSOLUTE_TOLERANCE;RELATIVE_TOLERANCE;TOLERANCE" "EXCLUDE_VARS" ${ARGN})
  if(COMPARE_NAN_ARE_EQUAL)
    set(COMPARE_NANS_ARE_EQUAL TRUE)
  endif()

  # A single positional tolerance and TOLERANCE both retain their historical
  # absolute-tolerance meaning.
  if(NOT COMPARE_ABSOLUTE_TOLERANCE)
    if(COMPARE_TOLERANCE)
      set(COMPARE_ABSOLUTE_TOLERANCE "${COMPARE_TOLERANCE}")
    elseif(COMPARE_UNPARSED_ARGUMENTS)
      list(LENGTH COMPARE_UNPARSED_ARGUMENTS _unparsed_len)
      if(_unparsed_len EQUAL 1)
        set(COMPARE_ABSOLUTE_TOLERANCE "${COMPARE_UNPARSED_ARGUMENTS}")
      else()
        message(FATAL_ERROR "Unexpected comparison arguments: ${COMPARE_UNPARSED_ARGUMENTS}")
      endif()
    elseif(DEFINED REGRESSION_TOLERANCE)
      set(COMPARE_ABSOLUTE_TOLERANCE "${REGRESSION_TOLERANCE}")
    elseif(DEFINED TOLERANCE)
      set(COMPARE_ABSOLUTE_TOLERANCE "${TOLERANCE}")
    endif()
  endif()

  if(NOT COMPARE_NANS_ARE_EQUAL)
    if(DEFINED REGRESSION_NANS_ARE_EQUAL AND REGRESSION_NANS_ARE_EQUAL)
      set(COMPARE_NANS_ARE_EQUAL TRUE)
    elseif(DEFINED NANS_ARE_EQUAL AND NANS_ARE_EQUAL)
      set(COMPARE_NANS_ARE_EQUAL TRUE)
    endif()
  endif()

  if(NOT COMPARE_EXCLUDE_VARS AND DEFINED REGRESSION_EXCLUDE_VARS)
    set(COMPARE_EXCLUDE_VARS "${REGRESSION_EXCLUDE_VARS}")
  elseif(NOT COMPARE_EXCLUDE_VARS AND DEFINED EXCLUDE_VARS)
    set(COMPARE_EXCLUDE_VARS "${EXCLUDE_VARS}")
  endif()

  find_program(NCCMP_EXECUTABLE nccmp)
  if(NCCMP_EXECUTABLE)
    set(COMPARE_COMMAND ${NCCMP_EXECUTABLE} -dmfgsB)
    if(COMPARE_NANS_ARE_EQUAL)
      list(APPEND COMPARE_COMMAND --nans-are-equal)
    endif()
    if(COMPARE_ABSOLUTE_TOLERANCE)
      list(APPEND COMPARE_COMMAND --tolerance ${COMPARE_ABSOLUTE_TOLERANCE})
    endif()
    if(COMPARE_RELATIVE_TOLERANCE)
      list(APPEND COMPARE_COMMAND --Tolerance ${COMPARE_RELATIVE_TOLERANCE})
    endif()
    if(COMPARE_JOIN_TOLERANCES)
      if(NOT COMPARE_ABSOLUTE_TOLERANCE OR NOT COMPARE_RELATIVE_TOLERANCE)
        message(FATAL_ERROR "JOIN_TOLERANCES requires ABSOLUTE_TOLERANCE and RELATIVE_TOLERANCE")
      endif()
      list(APPEND COMPARE_COMMAND --join-tolerance)
    endif()
    if(COMPARE_EXCLUDE_VARS)
      list(JOIN COMPARE_EXCLUDE_VARS "," _exclude_vars_csv)
      list(APPEND COMPARE_COMMAND --exclude=${_exclude_vars_csv})
    endif()
  else()
    set(COMPARE_COMMAND cmp)
  endif()

  execute_process(
    COMMAND ${COMPARE_COMMAND} ${baseline_file} ${current_file}
    RESULT_VARIABLE CMP_RESULT
    OUTPUT_VARIABLE CMP_OUTPUT
    ERROR_VARIABLE CMP_OUTPUT
  )
  if(CMP_RESULT)
    message(FATAL_ERROR "Files differ: ${baseline_file}\n${CMP_OUTPUT}")
  endif()
endfunction()

function(compare_results baseline_dir current_dir)
  cmake_parse_arguments(COMPARE "NANS_ARE_EQUAL;NAN_ARE_EQUAL;JOIN_TOLERANCES" "ABSOLUTE_TOLERANCE;RELATIVE_TOLERANCE;TOLERANCE" "EXCLUDE_VARS" ${ARGN})
  file(GLOB baseline_files ${baseline_dir}/*.nc ${baseline_dir}/*.nc4)
  foreach(baseline_file IN LISTS baseline_files)
    get_filename_component(fname ${baseline_file} NAME)
    message(STATUS "Comparing ${fname}")
    compare_netcdf_files(${baseline_file} ${current_dir}/${fname} ${ARGN})
  endforeach()
endfunction()
