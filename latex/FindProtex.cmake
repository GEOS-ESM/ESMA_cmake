set (protex_exe ${CMAKE_CURRENT_SOURCE_DIR}/protex)
set (protex_flags -g -b -f)

function(protex src)
  get_filename_component (base ${src} NAME_WE)
  add_custom_command (OUTPUT ${base}.tex
    COMMAND ${protex_exe} ${protex_flags} -f ${src} > ${base}.tex
    DEPENDS ${src}
    COMMENT "[protex] Building documentation for ${src}"
    )
endfunction (protex src)
