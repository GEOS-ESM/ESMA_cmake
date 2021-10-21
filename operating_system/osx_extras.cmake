# OSX fixes/workarounds
#
# 1) OS X has links that claim to be gcc and gxx, but they are not.
#    They are links to clang equivalents.
#    In the future, we'll need a config flag to support both variants.
#    But for now we want gcc only.



# 2) On OS X, object files with variables but no code (e.g. simple Fortran module files)
#    cause warning messages in the link stage.
#    The logic below deactivates the warnings.

foreach(lang Fortran C CXX)
  set (CMAKE_${lang}_ARCHIVE_CREATE "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
  set (CMAKE_${lang}_ARCHIVE_FINISH "<CMAKE_RANLIB> -c -no_warning_for_no_symbols <TARGET>")
  # TODO: check next line
  # I do not think we need this next line anymore.  Keeping it visible in case mistaken.
#  set (CMAKE_EXE_LINKER_FLAGS  "${CMAKE_EXE_LINKER_FLAGS}  -Wl,-no_compact_unwind")
endforeach()



# 3) Rpath handling per https://gitlab.kitware.com/cmake/community/-/wikis/doc/cmake/RPATH-handling#always-full-rpath

## use, i.e. don't skip the full RPATH for the build tree
set(CMAKE_SKIP_BUILD_RPATH FALSE)

## when building, don't use the install RPATH already
## (but later on when installing)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

## add the automatically determined parts of the RPATH
## which point to directories outside the build tree to the install RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

## the RPATH to be used when installing, but only if it's not a system directory
list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
if("${isSystemDir}" STREQUAL "-1")
    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
endif("${isSystemDir}" STREQUAL "-1")


# 4) With the advent of shared libraries in GEOS, one needs to symlink install/lib in an experiment
#    or use this command
ecbuild_warn(
   "Setting ENABLE_RELATIVE_RPATHS to FALSE.\n"
   "This changes LC_RPATH in the executable from:\n"
   " path @loader_path/../lib\n"
   "to:\n"
   " path ${CMAKE_INSTALL_PREFIX}/lib"
   )
set (ENABLE_RELATIVE_RPATHS FALSE)
