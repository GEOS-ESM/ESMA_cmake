function (esma_create_stub_component srcs module)
  list (APPEND ${srcs} ${module}.F90)

  find_file (generator
    NAME mapl_stub.pl
    PATHS ${MAPL_SOURCE_DIR}/MAPL_Base ${esma_etc}/MAPL)

  add_custom_command (
    OUTPUT ${module}.F90
    COMMAND ${generator} ${module}Mod > ${module}.F90
    MAIN_DEPENDENCY ${generator}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Making component stub for ${module}Mod in ${module}.F90"
    )
  add_custom_target(stub_${module} DEPENDS ${module}.F90)

endfunction ()

