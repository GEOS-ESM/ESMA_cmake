macro (esma_create_stub_component srcs module)
  list (APPEND ${srcs} ${module}.F90)

  find_file (stub_generator
    NAME mapl_stub.pl
    PATHS ${MAPL_SOURCE_DIR}/Apps ${esma_etc}/MAPL)

  add_custom_command (
    OUTPUT ${module}.F90
    COMMAND ${stub_generator} ${module}Mod > ${module}.F90
    MAIN_DEPENDENCY ${stub_generator}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Making component stub for ${module}Mod in ${module}.F90"
    )
  add_custom_target(stub_${module} DEPENDS ${module}.F90)

endmacro ()

