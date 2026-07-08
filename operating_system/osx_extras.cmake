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


# 3) Rpath handling
#
# GEOS uses an install-tree layout like:
#
#   install/bin/GEOSgcm.x
#   install/lib/*.dylib
#
# On Linux this is handled with:
#
#   $ORIGIN/../lib
#
# On macOS/Darwin the equivalent is:
#
#   @loader_path/../lib
#
# This allows an experiment-local copy of install/bin and install/lib
# to be self-contained.

## use, i.e. don't skip the full RPATH for the build tree
set(CMAKE_SKIP_BUILD_RPATH FALSE)

## when building, don't use the install RPATH already
## (but later on when installing)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

## Historically we used ${CMAKE_INSTALL_PREFIX}/lib here following the
## "always full RPATH" CMake guidance. That worked for running directly
## from the build install prefix, but it prevents experiment-local install
## trees from being self-contained: a copied EXPDIR/install/bin/GEOSgcm.x
## keeps loading GEOS dylibs from the original install prefix.
##
## Use the Darwin equivalent of Linux $ORIGIN/../lib instead.
set(CMAKE_INSTALL_RPATH "@loader_path/../lib")

## Do not automatically append link directories to the install RPATH.
## In particular, avoid hard-wiring ${CMAKE_INSTALL_PREFIX}/lib into
## installed executables, since that defeats experiment-local install trees.
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)

# 4) With the advent of shared libraries in GEOS, installed executables
# should use relative RPATHs so that:
#
#   EXPDIR/install/bin/GEOSgcm.x
#
# resolves GEOS/MAPL shared libraries from:
#
#   EXPDIR/install/lib
#
message(STATUS "Setting ENABLE_RELATIVE_RPATHS to TRUE. This keeps LC_RPATH in installed executables relocatable: path @loader_path/../lib")
set(ENABLE_RELATIVE_RPATHS TRUE)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-headerpad_max_install_names")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-headerpad_max_install_names")

# 5) Flang compiler workarounds for macOS shared libraries
# CMake natively uses Apple's '-dynamiclib' and '-install_name' for shared libraries,
# but the LLVM flang frontend strictly rejects them.
# We force flang to use '-shared' (which it correctly translates down to the linker)
# and use -Xlinker to safely pass the soname without space-parsing errors.
if(CMAKE_Fortran_COMPILER_ID MATCHES "Flang" OR CMAKE_Fortran_COMPILER_ID MATCHES "LLVMFlang")
  set(CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS "-shared -Wl,-headerpad_max_install_names")
  set(CMAKE_SHARED_LIBRARY_SONAME_Fortran_FLAG "-Xlinker -install_name -Xlinker ")
endif()

# 6) Suppress duplicate rpath/library warnings that arise only with the
# clang/clang++/gfortran toolchain on macOS. gfortran injects its Cellar
# lib directories as implicit link paths/rpaths; those get accumulated
# multiple times via ESMF and Baselibs transitive dependencies, producing
# noise on every link. These are upstream issues, not MAPL bugs.
#
# Not needed (and not applied) when using nagfor, which has its own runtime
# and does not inject gfortran Cellar paths.
#
# -Wl,-w suppresses all ld warnings (duplicate
#         rpath, missing search paths from the
#         gfortran 15.2.0 vs 15.2.0_1 Cellar mismatch)
# -Wl,-no_warn_duplicate_libraries suppresses "ignoring duplicate libraries"
#
# Both flags are Apple ld (ld-prime/ld64) specific.
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-w -Wl,-no_warn_duplicate_libraries")
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-w -Wl,-no_warn_duplicate_libraries")
  set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,-w -Wl,-no_warn_duplicate_libraries")
endif()
