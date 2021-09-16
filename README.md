# GEOS-ESM CMake Configuration Files

This repository contains many of the CMake settings, macros, and functions used for the GEOSgcm and other GEOS-ESM projects. 

## Main Directory

The main directory contains two files: `esma.cmake` and `esma_cpack.cmake`.

The `esma.cmake` file is the "omnibus" script which loads most of the other functions and macros used by GEOS-ESM. A good portion of
it sources other `.cmake` files contained in the subdirectories listed below via
use of appending to `CMAKE_MODULE_PATH`.

The `esma_cpack.cmake` file controls the use of CPack within GEOS-ESM. Due to interactions between GEOS-ESM's cmake and ecbuild's,
this file must be included separately

## Subdirectories

The rest of the GEOS-ESM CMake configuration files are contained in subdirectories:

* `esma_support`

  Macros and functions used to simplify and extend CMake or ecbuild (see below) capabilities. This includes things like `esma_add_library()` and other `esma_` macros that might be encountered in GEOS-ESM CMake.

* `compiler`

  Files related to different compiler options as well as some CMake-time checks for compiler support.

* `operating_system`

  Files related to OS-specific configurations

* `python`

  Files related to the detection and use of Python during the build process. For GEOS-ESM projects, this nearly always means `f2py`.

* `latex`

  Files related to LaTeX processing.

* `external_libraries`

  Files that control the detection and use of external libraries and other dependencies. This includes things like Baselibs (netCDF, ESMF, etc.), math libraries (MKL, BLAS, LAPACK), as well as Git.

* `ecbuild`

  There is a final "hidden" subdirectory that ESMA_cmake expects. This is a checkout of ecbuild which is an underlying framework for most of ESMA_cmake.  This is brought in as a subdirectory via `mepo` from `components.yaml` files in fixtures. 