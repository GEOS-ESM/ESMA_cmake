# This suppresses the warning that ecbuild also does
# an include(CPack)
set(CPack_CMake_INCLUDED 0)

set(CPACK_GENERATOR NONE)

# This undo some things that ecbuild_install_project does internally
set(CPACK_SOURCE_INSTALLED_DIRECTORIES )
set(CPACK_SOURCE_GENERATOR "TGZ")
set(CPACK_VERBATIM_VARIABLES TRUE)
set(CPACK_SOURCE_IGNORE_FILES
  /.git/
  /.mepo/
  /build.*/
  /install.*/
)
set(CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}")
# Note we need to call this again to "overwrite" the CPack done in ecbuild
include(CPack)

# Add the familiar dist target as an alias for package_source
add_custom_target(dist
  COMMAND "${CMAKE_COMMAND}" --build "${CMAKE_BINARY_DIR}" --target package_source
  VERBATIM
  USES_TERMINAL
  )

