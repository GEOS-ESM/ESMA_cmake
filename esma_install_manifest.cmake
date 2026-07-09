# esma_install_manifest.cmake

set(_prefix "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}")
set(_manifest "${_prefix}/etc/GEOS_RUNTIME_MANIFEST.sha256")

file(MAKE_DIRECTORY "${_prefix}/etc")

file(GLOB_RECURSE _files
  LIST_DIRECTORIES false
  "${_prefix}/bin/*.x"
  "${_prefix}/lib/*.so"
  "${_prefix}/lib/*.so.*"
)

list(SORT _files)

file(WRITE "${_manifest}" "# GEOS runtime manifest\n")
file(APPEND "${_manifest}" "# prefix: ${CMAKE_INSTALL_PREFIX}\n")
file(APPEND "${_manifest}" "# format: sha256 size relative_path\n")

foreach(_file IN LISTS _files)
  if("${_file}" STREQUAL "${_manifest}")
    continue()
  endif()

  if(EXISTS "${_file}" AND NOT IS_DIRECTORY "${_file}")
    file(SHA256 "${_file}" _sha)
    file(SIZE "${_file}" _size)
    file(RELATIVE_PATH _rel "${_prefix}" "${_file}")
    file(APPEND "${_manifest}" "${_sha}  ${_size}  ${_rel}\n")
  endif()
endforeach()

message(STATUS "Wrote GEOS runtime manifest: ${_manifest}")
