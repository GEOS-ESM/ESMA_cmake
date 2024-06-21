# Function to avoid conflicts with files (in separate folders) with the same name.
# The function is necessary for submodule files.

function(esma_add_fortran_submodules)
  set(options)
  set(oneValueArgs TARGET SUBDIRECTORY)
  set(multiValueArgs SOURCES)
  cmake_parse_arguments(
    ARG "${options}" "${oneValueArgs}"
    "${multiValueArgs}" ${ARGN}
  )

  foreach(file ${ARG_SOURCES})

    set(input ${CMAKE_CURRENT_SOURCE_DIR}/${ARG_SUBDIRECTORY}/${file})
    set(output ${CMAKE_CURRENT_BINARY_DIR}/${ARG_SUBDIRECTORY}_${file})
    add_custom_command(
      OUTPUT ${output}
      COMMAND ${CMAKE_COMMAND} -E copy ${input} ${output}
      DEPENDS ${input}
    )
    set_property(SOURCE ${output} PROPERTY GENERATED 1)
    target_sources(${ARG_TARGET} PRIVATE ${output})

  endforeach()

endfunction()
