# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Made gFTL-shared, yaFyaml, and pFlogger REQUIRED

### Fixed
### Removed
### Added

- Added ability for OpenMP and Double Precision to be used with f2py
  Used by the MAM Optics code
- Add ability to allow @-symbol to be at beginning or end of sub-repo (still in progress)
- Emit BASEDIR location during CMake

## [2.2.2]

### Added

- Added macro to verify availability of Python modules
  Use: `esma_find_python_module(<module> [REQUIRED])`
- Added macro to add a post-build check availability of Python modules
  Use: `esma_check_python_module(<module>)`
- Added option is `esma_add_library() to use SHARED
	
## [2.2.1]

### Changed

- Also uptick the ecbuild version in Externals.cfg to prevent a CMake warning.

### Fixed

- Fix for macOS and Clang found by @tclune

## [2.2.0]

### Changed

- Updates to f2py detection

## [2.1.2]

### Changed

- Added flag for Intel to suppress long name warning.

## [2.1.1]

### Changed

- Turn on MPI_DETERMINE_LIBRARY_VERSION

## [2.1.0]

### Changed

- Updates to f2py detection for Python 3

## [2.0.0]

NOTE This release of ESMA Cmake is not backwardly compatible to the 1.x series.

### Changed

- Updates for Baselibs 6.x
  - Needed because CMake interface to FLAP changed
  - Also, this version of ESMA_cmake is based on pFUnit 4 and as such uses find_package(PFUNIT) and then uses the PFUNIT_FOUND variable.

## [1.0.11]

### Changed

- Add `FINDLOC()` detection

## [1.0.10]

### Changed

- Adds CODEOWNERS
- Adds QUIET to find_package of non-required libraries
- Convert options to use OPTION()
- Fixes to esma_add_library from #34
- Fixes for debug flag setting from #17

## [1.0.9]

### Changed

- Update LaTeX detection

## [1.0.8]

### Changed

- Change the @ecbuild location to GEOS-ESM

### Fixed

- Updates necessary for building on macOS (f2py)

## [1.0.7]

### Fixed

- Add code to the automatic code generation macros to install the generated RC files to etc/

## [1.0.6]

### Fixed

- Add executable bit to F2Py shared objects

## [1.0.5]

### Changed

- Add MPI option to UseF2Py

## [1.0.4]

### Changed

- Add GitInfo package

## [1.0.3]

### Fixed

- Fix cmake autodetect when embedded.

