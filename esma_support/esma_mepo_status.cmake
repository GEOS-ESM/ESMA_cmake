function(esma_capture_mepo_status)

  # Step 1: Set the path to the .mepo directory
  set(MEPO_DIR "${CMAKE_SOURCE_DIR}/.mepo")
  set(OUTPUT_FILE_NAME "MEPO_STATUS.rc")
  set(OUTPUT_FILE "${CMAKE_BINARY_DIR}/${OUTPUT_FILE_NAME}")

  if(EXISTS "${MEPO_DIR}")
    message(DEBUG ".mepo directory found")

    # Step 2: Check for the `mepo` command
    find_program(MEPO_COMMAND mepo)

    if(MEPO_COMMAND)
      message(DEBUG "Found mepo command at ${MEPO_COMMAND}")

      # Step 3: Run `mepo status --hashes` and capture the output
      execute_process(
        COMMAND ${MEPO_COMMAND} status --hashes
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_FILE "${OUTPUT_FILE}"
        RESULT_VARIABLE MEPO_STATUS_RESULT
        ERROR_QUIET
      )

      if(NOT MEPO_STATUS_RESULT EQUAL 0)
        message(WARNING "mepo state and command were found but failed to run mepo status --hashes. This seems to happen when internet access is not available. Sometimes. We are not sure yet.")
      else()
        message(STATUS "mepo status output captured in ${OUTPUT_FILE_NAME}")

        # Step 4: Install the output file in the etc directory
        install(
          FILES "${OUTPUT_FILE}"
          DESTINATION etc
          )
      endif()
    else()
      message(DEBUG "mepo command not found, skipping mepo status")
    endif()
  else()
    message(DEBUG ".mepo directory not found, skipping mepo status check")
  endif()

endfunction()
