# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
### Fixed
### Removed
### Added

## [3.5.5] - 2021-Sep-07

### Fixed

- Added `librt` and `libdl` to the `ESMF_LIBRARIES`

## [3.5.4] - 2021-Aug-25

### Added

- Added `esma_cpack.cmake` to allow for creating tarballs of code with `make package_source` or `make dist`

## [3.5.3] - 2021-Aug-03

### Changed

- If building `CMAKE_BUILD_TYPE=Debug` the f2py steps are now more verbose to aid in debugging


## [3.5.2] - 2021-Jul-14

### Fixed

- Changes to `esma_add_f2pyX_module` macros in handling the `python -c 'import foo_'` tests. Adds `LD_LIBRARY_PATH` to it. Still does not fix all problems.

## [3.5.1] - 2021-Jul-01

### Fixed

- Fixed rpath handling on macOS.

## [3.5.0] - 2021-Jun-08

### Changed

- Change `ESMA_USE_GFE_NAMESPACE` default to `ON`. This requires Baselibs v6.2 or the latest libraries
- On Linux, link to `libesmf.so` rather than `libesmf_fullylinked.so` per advice of ESMF developers.
- On macOS, link to `libesmf.dylib` rather than `libesmf.a`. This requires Baselibs v6.2.5 as that has a bug fix for ESMF dylib handling

## [3.4.5] - 2021-Aug-03

### Changed

- If building `CMAKE_BUILD_TYPE=Debug` the f2py steps are now more verbose to aid in debugging

## [3.4.4] - 2021-Jul-14

### Fixed

- Changes to `esma_add_f2pyX_module` macros in handling the `python -c 'import foo_'` tests. Adds `LD_LIBRARY_PATH` to it. Still does not fix all problems.

## [3.4.3] - 2021-Jun-04

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

