# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

### Fixed

### Removed

### Added

- Add `NETCDF_INCLUDE_DIRS` as alias to `INC_NETCDF` for spack compatibility when using Baselibs

## [3.19.0] - 2022-10-27

### Added

- Added check to `esma.cmake` to ensure `CMAKE_INSTALL_PREFIX` is writable
- Add `-save-temps` to GNU debug flags

### Changed

- Updated CI and changelog enforcer

## [3.18.0] - 2022-08-18

### Changed

- Changed the Apple M1 detection to be "Apple M" in anticipation of M2 machines.

### Fixed

- Updated the CI to work with latest Baselibs
- Updated the list of files ignored by CPack

## [3.17.0] - 2022-06-15

### Changed

- Update GNU Release compile target architecture from `westmere` to `haswell`
  - This is done as it seems to fix an issue with GCC 12
  - **NOTE**: This is non-zero-diff for GNU Release
- Update M1 flags on GNU from GEOS testing
- Also add M1-Rosetta2 flags from @climbfuji

## [3.16.0] - 2022-06-03

### Changed

- NAG Fortran flags no longer have `-dusty` by default.
- GNU Fortran flag added to disable warnings about unused dummy arguments.  (Not terribly useful, though as at least one other compiler lacks such a flag. So we still need the `_UNUSED_DUMMY` fpp macro.)
- Explicitly made `USE_F2PY=OFF` the default for NAG.

## [3.15.1] - 2022-05-16

### Fixed

- Add dependency to MPI for ESMF when building with ESMF built within Baselibs.

## [3.15.0] - 2022-05-16

### Changed

- Changes to use the `FindESMF.cmake` module directly from ESMF build.
- Add ALIAS library for `ESMF` due to historical use of `esmf` in GEOS

### Removed

- Removed `FindESMF.cmake` to prefer using the version from ESMF itself. Note that `CMAKE_MODULE_PATH` for Baselibs users is
  automatically appended. Users of ESMA_cmake that don't use Baselibs, will need to append their own.

## [3.14.0] - 2022-05-13

### Changed

- Moved to use `find_package(ESMF)` for even use with Baselibs. This allows GEOS to more smoothly accept changes in ESMF builds by basing off of `esmf.mk`.
- Changed `FindESMF.cmake` to prefer `SHARED` libraries over `STATIC` to match how ESMF-in-Baselibs worked before moving to `find_package`
- Changes to support non-Baselibs builds
   - Move `find_package(MPI)` code in `FindBaselibs.cmake` only if Baselibs found
   - Remove code if not using Baselibs; should be placed in each fixture/directory

## [3.13.0] - 2022-04-11

### Changed

- Changed how f2py handles Fortran compiler detection
- Updated to circleci-tools orb for CI

### Fixed

- Fix bug in f2py testing

## [3.12.0] - 2022-03-17

### Removed

- Remove `PGI.cmake` file as NVHPC is the correct file for now. Add symlink

### Added

- Added preliminary support for GNU on M1 Macs

## [3.11.0] - 2022-03-10

### Changed

- Various changes to support building GEOS with Spack
  - Edit to FindESMF.cmake file
  - Move `include(DetermineSite)`
  - Fix for finding ecbuild cmake files
  - Fixes for f2py scripts

## [3.10.0] - 2022-02-04

### Added

- Add `FindESMF.cmake` package. Used for Spack builds not Baselibs builds

## [3.9.0] - 2022-02-01

### Changed

- Compress CircleCI artifacts

### Added

- Add NVHPC Compiler Flag file

## [3.8.0] - 2021-12-16

### Changed

- Changed the default vectorization flag for Intel Fortran from
`-xCORE-AVX2` to `-march=core-avx2`. This change allows GEOS to run
on both Intel and AMD EPYC chips at NAS without need for another
build.
  - This change is non-zero-diff on Intel chips
  - The Intel/AMD "run on both" is only valid on TOSS
  - See https://github.com/GEOS-ESM/ESMA_cmake/issues/240 for more information

## [3.7.3] - 2021-12-13

### Fixed

- Fix for `FindGitInfo` if in a git-stripped distribution

## [3.7.2] - 2021-11-08

### Fixed

- Move finding of OpenMP, MPI, and Threads above `FindBaselibs`. This was interfering with f2py...for some reason.

## [3.7.1] - 2021-11-05

### Fixed

- Call `FindBaselibs.cmake` earlier in sequence. This sets the `CMAKE_PREFIX_PATH` before any `find_package()` calls for Baselibs libraries (i.e., GFE)

## [3.7.0] - 2021-11-02

### Removed

- Remove `find_package()` calls for GFE libraries from `FindBaselibs.cmake`

### Changed

- Updated CI to use both gfortran and Intel, and Baselibs 6.2.8

## [3.6.6] - 2021-10-21

### Fixed

- Attempt to detect SSL library path and use that with f2py

## [3.6.5] - 2021-10-18

### Added

- Added warp nodes as NCCS nodes

## [3.6.4] - 2021-10-15

### Added

- Added `esma_postinstall.cmake` script for tarring up code post install

## [3.6.3] - 2021-10-14

### Fixed

- Fixed bug in caching `BASEDIR`

## [3.6.2] - 2021-10-06

### Changed

- Changed the warning for missing Basedir to be more prominent

## [3.6.1] - 2021-10-05

### Changed

- Created a new set of flags for Intel that mimic the old non-vectorized Release flags

### Fixed

- Fix issue with `tests` target due to bad refactor

## [3.6.0] - 2021-10-01

### Changed

- Refactored ESMA_cmake
- Changed the Release flags for the Intel Compiler to be the Vectorized flags. Testing shows it is zero-diff and faster, however we
  are moving the minor version number as a signal of "just in case"

### Fixed

- Cache BASEDIR when a valid path is found

## [3.5.7] - 2021-09-27

### Fixed

- Fix pthreads use on Linux with NAG compiler

## [3.5.6] - 2021-09-24

### Changed

- `esma_add_subdirectory` now uses the new `esma_mepo_style`

### Fixed

- Prevent build or install directories from having a comma (due to -Wl issue)

### Added

- New function `esma_mepo_style` which searches for a directory under
  any mepo style option and returns a variable filled in accordingly.
  It can optionally return a bool FOUND argument.  Throws an ecbuild error
  if dir is not found and FOUND argument is not used.

## [3.5.5] - 2021-09-07

### Changed

- Updated some MAPL references in the stub and ACG code

### Fixed

- Added `librt` and `libdl` to the `ESMF_LIBRARIES` on Linux.

## [3.5.4] - 2021-08-25

### Added

- Added `esma_cpack.cmake` to allow for creating tarballs of code with `make package_source` or `make dist`

## [3.5.3] - 2021-08-03

### Changed

- If building `CMAKE_BUILD_TYPE=Debug` the f2py steps are now more verbose to aid in debugging


## [3.5.2] - 2021-07-14

### Fixed

- Changes to `esma_add_f2pyX_module` macros in handling the `python -c 'import foo_'` tests. Adds `LD_LIBRARY_PATH` to it. Still does not fix all problems.

## [3.5.1] - 2021-07-01

### Fixed

- Fixed rpath handling on macOS.

## [3.5.0] - 2021-06-08

### Changed

- Change `ESMA_USE_GFE_NAMESPACE` default to `ON`. This requires Baselibs v6.2 or the latest libraries
- On Linux, link to `libesmf.so` rather than `libesmf_fullylinked.so` per advice of ESMF developers.
- On macOS, link to `libesmf.dylib` rather than `libesmf.a`. This requires Baselibs v6.2.5 as that has a bug fix for ESMF dylib handling

## [3.4.5] - 2021-08-03

### Changed

- If building `CMAKE_BUILD_TYPE=Debug` the f2py steps are now more verbose to aid in debugging

## [3.4.4] - 2021-07-14

### Fixed

- Changes to `esma_add_f2pyX_module` macros in handling the `python -c 'import foo_'` tests. Adds `LD_LIBRARY_PATH` to it. Still does not fix all problems.

## [3.4.3] - 2021-06-04

### Changed

- Add ability to detect BASEDIR from the environment.
- Add checks to `FindBaselibs.cmake` to make sure BASEDIR has the right arch (as defined by `uname -s`) as this is still a requirement for
  GEOS run scripts. The code will also try to make a valid BASEDIR. That is, if you pass in `/path/to/baselibs`, but it sees a
  `/path/to/baselibs/arch/lib` exists, it will allow that and try to use it.
- Previous option `CPP_DEBUG_<target` has now been replaced with a
  more fine-grained combination of cmake variables: `XFLAGS` and
  `XFLAGS_SOURCES`.   To use

  ```
  $cmake .. -DXFLAGS="foo bar=7 DEBUG" -DXFLAGS_SOURCES="<file1> <file2>"
  $ make
  ```

  NOTE: This change requires checking for specified sources in every
  directory (or rather in those that use `esma_set_this()` and thus
  add some overhead to cmake.  We may later decide to implement a
  per-target or per-directory pair of flags to address this, but that
  will be harder for the user to use.

## [3.4.2] - 2021-05-17

### Fixed

- Fixes for F2PY and GNU as well as some cleanup

## [3.4.1] - 2021-05-14

### Fixed

- Removed extra space in diagnostic message about missing directories
- Fixed a bug with double precision handling and GNU

### Added

- A new CMake variable `CPP_DEBUG_<target>` has been added for each
  target.  The value is a list of source files that should receive the
  "`-DDEBUG`" compile definition.  To use:
  ```
  $ cmake .. -DCPP_DEBUG_MAPL.base=MAPL_base.F90
  ```
  To use with multiple files use quotes and separate with `;`
  ```
  $ cmake .. -DCPP_DEBUG_MAPL.base="MAPL_base.F90;MAPL_CFIO.F90"
  ```

## [3.4.0] - 2021-04-30

### Added

- Added Python2 and Python3 versions of generic Python F2PY macros.

## [3.3.9] - 2021-04-14

### Added

- Added option `BUILD_WITH_PFLOGGER` which defaults to `ON`. This is
  added for collaborators that do not use pFlogger

## [3.3.8] - 2021-04-09

### Added

- Added new `ESMA_USE_GFE_NAMESPACE` which defaults to `OFF`. If you set this to `ON`, you must then use the new GFE namespace style in CMake, e.g., `gftl` ==> `GFTL::gftl`.

## [3.3.7] - 2021-03-09

### Fixed

- Fixed Aggressive GNU flags on Graviton2 processors

## [3.3.6] - 2021-02-10

### Added

- Added test for GNU and Intel to try and determine if building on Intel or AMD chips and choose correct vectorization flags.

## [3.3.5] - 2020-12-23

### Fixed

- Changed `-extend_source` to `-extend-source` due to warning print in
  Intel 2021

## [3.3.4] - 2020-12-10

### Fixed

- Fixed Aggressive flags with GCC 10

## [3.3.3] - 2020-12-10

### Added

- Add ability for `Aggressive` build type (note: requires [GEOS-ESM/ecbuild geos/v1.0.6](https://github.com/GEOS-ESM/ecbuild/releases/tag/geos%2Fv1.0.6) to use as ecbuild restricts allowed `CMAKE_BUILD_TYPE`)

## [3.3.2] - 2020-12-08

### Fixed

- Fixed `new_esma_generate_automatic_code` macro to better handle automatically generated files (see https://github.com/GEOS-ESM/GEOSchem_GridComp/issues/108)

### Added

- Add changelog enforcer

## [3.3.1] - 2020-11-23

### Removed

- Remove `Externals.cfg` as part of `manage_externals` deprecation

## [3.3.0] - 2020-11-19

### Changed

- Added Docker authentication for CI
- Updates from UFS to enable use with MAPL without Baselibs (Requires MAPL 2.4.0+)

## [3.2.1] - 2020-09-28

### Fixed

- Fix for default Fortran module directory

## [3.2.0] - 2020-09-22

### Added

- Add support for Arm64 machines

### Changed

- Requirement for MKL is removed (MKL is used if found, otherwise BLAS/LAPACK is used)

## [3.1.4] - 2020-09-18

### Changed

- Update Intel Debug flags to be more comprehensive

### Added

- Add CircleCI testing

## [3.1.3] - 2020-08-07

### Fixed

- Fix for handling f2py tests

## [3.1.2] - 2020-08-04

### Fixed

- Fix for coding of AWS detection found on Ubuntu/CircleCI

## [3.1.1] - 2020-07-31

### Fixed

- Fixes for handling MOM/MOM6 shared libraries on macOS

## [3.1.0] - 2020-07-28

### Added

- Add support to detect AWS systems

## [3.0.7] - 2020-07-16

### Added

- Add an option `USE_F2PY` which by default is `ON` preserving current
  behavior. (Useful on pioneer systems and containers where f2py might
  not be available.)

## [3.0.6] - 2020-06-09

### Changed

- Updates in support of MAPL 2.2
  - Fix up how testing is done
  - Generalize the stub generator

## [3.0.5] - 2020-06-05

### Changed

- Use `find_file` to generalize path to MAPL utilities (acg)

## [3.0.4] - 2020-06-03

### Changed

- Updated to ecbuild geos/v1.0.5

### Fixed

- Updates for JEDI Compatibility

## [3.0.3] - 2020-05-18

### Added

- Support for GCC 10
  - See releases tab for more information

## [3.0.2] - 2020-05-04

### Fixed

- Typo in message in `esma_add_library()`.

### Added

- Added macro `esma_add_f2py_module()` which wraps existing `add_f2py_module()` and
  a call to `add_test()`.

## [3.0.1] - 2020-04-21

### Changed

- Allow ecbuild to be mounted as `ecbuild@`, `@ecbuild`, or `ecbuild`

## [3.0.0] - 2020-04-15

NOTE: This version of ESMA_cmake now requires Baselibs 6.0.10 or higher
due to the need for yaFyaml and pFlogger

### Changed

- Made gFTL-shared, yaFyaml, and pFlogger REQUIRED

### Added

- Added ability for OpenMP and Double Precision to be used with f2py
  Used by the MAM Optics code
- Add ability to allow @-symbol to be at beginning or end of sub-repo (still in progress)
- Emit BASEDIR location during CMake

## [2.2.2] - 2020-04-10

### Added

- Added macro to verify availability of Python modules
  Use: `esma_find_python_module(<module> [REQUIRED])`
- Added macro to add a post-build check availability of Python modules
  Use: `esma_check_python_module(<module>)`
- Added option is `esma_add_library() to use SHARED

## [2.2.1] - 2020-03-27

### Changed

- Also uptick the ecbuild version in Externals.cfg to prevent a CMake warning.

### Fixed

- Fix for macOS and Clang found by @tclune

## [2.2.0] - 2020-03-25

### Changed

- Updates to f2py detection

## [2.1.2] - 2020-01-23

### Changed

- Added flag for Intel to suppress long name warning.

## [2.1.1] - 2020-01-07

### Changed

- Turn on MPI_DETERMINE_LIBRARY_VERSION

## [2.1.0] - 2020-01-02

### Changed

- Updates to f2py detection for Python 3

## [2.0.0] - 2019-12-05

NOTE This release of ESMA Cmake is not backwardly compatible to the 1.x series.

### Changed

- Updates for Baselibs 6.x
  - Needed because CMake interface to FLAP changed
  - Also, this version of ESMA_cmake is based on pFUnit 4 and as such uses find_package(PFUNIT) and then uses the PFUNIT_FOUND variable.

## [1.0.11] - 2019-11-14

### Changed

- Add `FINDLOC()` detection

## [1.0.10] - 2019-10-01

### Changed

- Adds CODEOWNERS
- Adds QUIET to find_package of non-required libraries
- Convert options to use OPTION()
- Fixes to esma_add_library from #34
- Fixes for debug flag setting from #17

## [1.0.9] - 2019-07-25

### Changed

- Update LaTeX detection

## [1.0.8] - 2019-07-22

### Changed

- Change the @ecbuild location to GEOS-ESM

### Fixed

- Updates necessary for building on macOS (f2py)

## [1.0.7] - 2019-07-18

### Fixed

- Add code to the automatic code generation macros to install the generated RC files to etc/

## [1.0.6] - 2019-07-11

### Fixed

- Add executable bit to F2Py shared objects

## [1.0.5] - 2019-07-10

### Changed

- Add MPI option to UseF2Py

## [1.0.4] - 2019-07-09

### Changed

- Add GitInfo package

## [1.0.3] - 2019-07-03

### Fixed

- Fix cmake autodetect when embedded.

