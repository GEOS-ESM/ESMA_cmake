# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

### Removed

### Added

### Changed

### Deprecated

## [4.19.0] - 2025-07-02

### Changed

- Prepend our `external_libraries` directory to `CMAKE_MODULE_PATH` so our CMake files win
- On macOS, add `-Wl,-headerpad_max_install_names` when linking

### Added

- Added new CMake test for deprecated FMS1 I/O support

## [4.18.1] - 2025-05-22

### Changed

- Added `TMPDIR` environment variable to f2py and f2py3 compilation processes in CMake scripts to avoid `noexec` `/tmp` directories

## [4.18.0] - 2025-05-13

### Fixed

- Fixed issue with f2py detection where f2py was still being test compiled even if a user specified `-DUSE_F2PY:BOOL=OFF`

### Changed

- Make `proc_description` a `CACHE` variable

## [4.17.0] - 2025-05-06

### Added

- Added code to enforce that we only allow `CMAKE_BUILD_TYPE` of Release, Debug, and Aggressive
  - CMake can recognize others, but we maintain our own flags so we need to be careful

## [4.16.0] - 2025-05-02

### Added

- Explicitly set `CMAKE_INSTALL_LIBDIR` to `lib` to override `GNUInstallDirs` from setting it to `lib64`. This is mainly needed due to assumptions in GEOS scripting

### Changed

- Added support for Emerald Rapids
- Added `DEPENDS` option to f2py and f2py3 code to pass dependencies to the `add_custom_command` used to call f2py

## [4.15.0] - 2025-04-24

### Changed

- Added a timeout to `mepo status` to prevent it from hanging indefinitely. The timeout is set to 60 seconds
- Modified the f2py and f2py3 codes for meson+MPT support
  - It was found that when an f2py code uses MPI, with meson+MPT we need to run with `LD_PRELOAD=/path/to/mpt/libmpi.so`

## [4.14.2] - 2025-04-22

### Fixed

- Do not add `ld_classic` flag on macOS with XCode 16.3 or newer. No longer needed.

## [4.14.1] - 2025-04-03

### Fixed

- Fixed bug in f2py3 code

## [4.14.0] - 2025-03-24

### Removed

- Removed warning about setting `-fallow-argument-mismatch` and `-fallow-invalid-boz` with GCC 10+. This is pretty much common now. Instead, we emit a message

## [4.13.0] - 2025-03-18

### Removed

- Remove code for finding OS at NCCS as system is now all SLES15

### Changed

- Update Intel LLVM Fortran flags to use `-march=x86-64-v3` as `-march=core-avx2` is not (technically?) supported by `ifx`
- Reworked FMS detection to better handle the different `FV_PRECISION` cases in `FindBaselibs.cmake`
- Change f2py detection for the odd case where there might be multiple Python installations. For now, if the path to the Python executable does not match the path to the f2py executable, we issue a `WARNING`. We use a `WARNING` since some installations (e.g., Spack) will have the Python executable in a different location than the f2py executable.
- Removed warning that Baselibs is not supported, to a STATUS message.

## [4.12.0] - 2025-02-11

### Changed

- Updated Intel Fortran flags from @wmputman

## [4.11.0] - 2025-01-03

### Changed

- Move to use Python `FIND_STRATEGY LOCATION` by default. This is needed as NAS (at least) has a very recent, but empty (no f2py) Python stack in the default path. Using `LOCATION` should limit it to the Python we want (e.g., via GEOSpyD module)

## [4.10.0] - 2024-12-02

### Fixed

- Fixed bad behavior in the `MPI_STACK` detection on subsequent calls to `DetermineMPIStack` 

## [4.9.0] - 2024-11-13

### Fixed

- Fixed `mepo status` code to allow for quiet failures. There seems to be an odd scenario on non-internet-connected machines where `mepo status` will fail in blobless clones of some repos. Running `mepo status` on a node with internet access seems to fix this. 

### Changed

- For F2PY3 code, set CMake Policy CMP0132 if Python is 3.12+ or higher
- Add test to see if `ifort` spits out the deprecation warning. Needed to hack f2py/meson
- Set minimum CMake version to 3.24 for the meson + f2py fix

## [4.8.1] - 2024-11-07

### Fixed

- Do not include `DetermineMPIStack` if MPI is not found

## [4.8.0] - 2024-11-05

### Added

- Added new `esma_capture_mepo_status` function (in `esma_support/esma_mepo_status.cmake`) to capture the output of `mepo status --hashes` when `mepo` was used to clone the fixture. It will output this into a file `MEPO_STATUS.rc` which is installed to `${CMAKE_INSTALL_PREFIX}/etc` and can be used to help determine the exact state of the fixture at build time.

## [4.7.0] - 2024-10-10

### Changed

- Support for building GEOSgcm with Spack using MAPL as library
  - Update `esma_create_stub_component` to look for `mapl_stub.pl` in `$MAPL_BASE_DIR/etc` (which is a variable defined by ecbuild)
  - Update `esma_generate_automatic_code` to look for `mapl_acg.pl` in `$MAPL_BASE_DIR/etc` (which is a variable defined by ecbuild)
  - Require CMake 3.18 for features used in above updates
- Update to CircleCI orb v5

## [4.6.0] - 2024-09-05

### Added

- Add `FindJeMalloc.cmake` for use with builds of GEOSgcm
- Add preliminary LLVMFlang support

## [4.5.0] - 2024-08-12

### Changed

- Add workaround to support OpenMP linking with NAG under CMake

## [4.4.0] - 2024-08-01
 
### Changed

- Edit the file `esma_add_fortran_submodules.cmake` to add the `SMOD` word to the target submodule file name.

## [4.3.0] - 2024-07-15

### Changed

- Move detection out of `FindBaselibs.cmake` for Spack purposes

## [4.2.0] - 2024-07-11

### Fixed

- Add more features to the file `esma_add_fortran_submodules.cmake` so that the function `esma_add_fortran_submodules` can handle several level of subdirectories.

## [4.1.0] - 2024-06-21

### Added

- Add the file `esma_add_fortran_submodules.cmake` in the `esma_support` folder. The file contains a function that prevents conflicts when several submodule files have the same name.

## [4.0.1] - 2024-06-14

### Fixed

- Fixes for NVHPC
- Fix issue with use of `meson` and `f2py` with more complex codes
  - NOTE: Requires a fix to `f2py` that is not yet released. You can see the change
    in the `numpy` repo at https://github.com/numpy/numpy/pull/26659
    This fix has been applied to GEOSpyD 2.44.0-0

## [4.0.0] - 2024-05-21

### Added

- Add FMS as a library rather than part of Baselibs
- Added `Findlibyaml.cmake` to support FMS with yaml support
  - FMS with YAML support is controlled by `-DFMS_BUILT_WITH_YAML` as there is no good way to determine how FMS was built
    after-the-fact. For now the default is `OFF` but this will change in the future
- Added preliminary support for Hygon processors with GCC

### Changed

- Change the minimum required GCC compiler version to be 11.2
- Change the minumum required NAG compiler verison to be 7.2
- Update CI to use Baselibs v8.0.2

## [3.45.2] - 2024-05-16

### Fixed

- Fix issue with `ld_classic` detection on macOS. Not all XCode versions need this

### Added

- Added YAML linter

## [3.45.1] - 2024-05-03

### Fixed

- Fix bug with meson/distutils for python 3

## [3.45.0] - 2024-04-25

### Fixed

- Edit `FindESMF.cmake` to use `ESMF::ESMF` as the primary target and make `ESMF` an alias for `ESMF::ESMF` if it doesn't exist
- Updates for building with Clang on macOS
  - Add `-Wl,-ld_classic` to linker flags for all macOS
  - Add `-Wno-implicit-int` for Clang on macOS
- Fix for using f2py and Python 3.12

### Added

- Add suppression of remark 10488 for Intel Fortran Classic which is a warning about ifort deprecation in late 2024

## [3.44.0] - 2024-03-29

### Fixed

- Set `BUILT_ON_SLES15` to `FALSE` if not building on SLES15. Before it was blank

## [3.43.0] - 2024-03-18

### Changed

- Change `make tests` to only do tests labeled with `ESSENTIAL`. Add new `make tests-all` to run all tests.

## [3.42.0] - 2024-03-08

### Changed

- Added `-quiet` flag for NAG compilation. This suppresses the compiler banner and the summary line, so that only diagnostic messages will appear.

## [3.41.0] - 2024-02-20

### Fixed

- Quoted generator expression arguments (see #308)

### Added

- Added new `DetermineMPIStack.cmake` file that will detect the MPI Stack being used
  - The allowed stacks are `openmpi`, `mpich`, `intel`, `mvapich`, `mpt` which will
    be set in the `MPI_STACK` variable
    - Can be overridden by setting `MPI_STACK` to one of the allowed values via `-DMPI_STACK=...`
  - Will also set `MPI_STACK_VERSION` to the version of the stack being used
    - NOTE: This is the version of the *stack* not the version of MPI supported by the stack 

## [3.40.0] - 2024-02-06

### Changed

- Updated `FindESMF.cmake` to the version from ESMF develop branch, commit da8f410. Will be in ESMF 8.6.1+
  - This provides the `ESMF::ESMF` alias for ESMF library for non-Baselibs builds

## [3.39.0] - 2024-02-06

### Added

- Added `ESMF::ESMF` alias for ESMF library
  - Needed to avoid an issue UFS has with MAPL/GOCART (see https://github.com/GEOS-ESM/MAPL/issues/2569)
  - Needed for Baselibs builds of MAPL 2.44 and higher as we now move to use `ESMF::ESMF` as the target
  - Will be added to `FindESMF.cmake` in a future release of ESMF, so we only add the alias if it doesn't exist

### Changed

- Update CI to v2 orb

## [3.38.0] - 2024-01-19

### Added

- Add `FindESMF.cmake` for use with Spack builds of GEOSgcm
- Added support for Hygon processors with Intel Fortran

## [3.37.0] - 2024-01-09

### Changed

- Fixes for `ifx` compiler
  - Set `nouninit` for check flags when building with Debug build type
  - Remove some debug flags that don't exist with `ifx`
  - Remove `-init=snan` as that causes compiler faults with some MAPL files
- For NAG, turn off setting of `ESMF_HAS_ACHAR_BUG` CMake option as it seems
  no longer needed

### Deprecated

- The `ESMF_HAS_ACHAR_BUG` CMake option is deprecated and will be removed in a future release

## [3.36.0] - 2023-10-26

### Fixed

- Fixes for building with Intel Fortran Classic on macOS on Arm under Clang 15 and Rosetta
  - Uses `ld_classic` as the linker

### Added

- Add setting `-Wno-implicit-int` when running with `icx`

## [3.35.0] - 2023-10-13

### Added

- Updates for supporting Milan at NCCS
  - Makes f2py2 only work if python2 is available. If not, all f2py2 is disabled
  - Add new `BUILT_ON_SLES15` variable since building on SLES15 means running on SLES15

### Changed

- Turn off warning 10121 with Intel Fortran as it is noise

## [3.34.0] - 2023-09-07

### Changed

- Introduced `-not_openmp` flag for NAG to avoid "Questionable" warning messages from compiler about unused openmp constructs.

## [3.33.0] - 2023-09-05

### Changed

- Modified default flags for NAG to allow more aggressive debug flags.  Mostly this is by using a more specific list of procedures for which interface "mismatch" warnings are suppressed.

## [3.32.0] - 2023-09-01

### Added

- Added support for building with Intel Fortran in Rosetta2 (generic x86_64 processor)

## [3.31.1] - 2023-08-03

### Fixed

- Fixed a build incompatibity with ESMF that affects `MAPL_Config::SetAttribute*()`

### Changed

- Update CI to use Baselibs default from CircleCI orb

## [3.31.0] - 2023-07-25

### Changed

- Suppress common unneeded warnings with all debug builds with Intel
  - `warning #5462: Global name too long`
  - `warning #10337: option '-fno-builtin' disables '-imf*' option`

## [3.30.0] - 2023-06-23

### Added

- Added `QUIET_DEBUG` option to remove the `-warn unused` flag for Intel and add some common warning suppressions (Intel only at the moment)

### Changed

- Updated CI to use Baselibs 7.13.0

## [3.29.0] - 2023-05-18

### Changed

- Remove `BUILT_ON_ROME` detection at NAS as all nodes are now TOSS4

## [3.28.0] - 2023-03-23

### Changed

- Updated Python detection to use `FIND_STRATEGY VERSION`. This is needed due to mixing of
  Python 2 and 3 in the same environment.

## [3.27.0] - 2023-03-10

### Changed

- Update Intel Fortran flags
  - NOTE: This is non-zero-diff for Intel Release and Aggressive builds of GEOS

## [3.26.0] - 2023-03-03

### Changed

- Add detection of Azure
- Change site detection code to distinguish between Rome and non-Rome
  nodes at NAS (since there is an OS difference between them that has
  run-time effects)

## [3.25.0] - 2023-02-17

### Added

- Added an `HDF5::HDF5` target to `FindBaselibs.cmake` for compatibility with code that uses `HDF5::HDF5`.
  - NOTE: This is hack for Baselibs builds until we can move to using Spack for libraries

## [3.24.0] - 2023-01-03

### Changed

- Updated label-enforcer to v3 and added custom message

## [3.23.0] - 2023-01-03

### Changed

- Updated CI to Baselibs 7.7

### Added

- Added `IntelLLVM_Fortran.cmake` file
  - At the moment a copy of `Intel_Fortran.cmake` with `-fp-model source` and `-fp-model consistent` blanked due to [changes with ifx](https://www.intel.com/content/www/us/en/develop/documentation/fortran-compiler-oneapi-dev-guide-and-reference/top/compiler-reference/compiler-options/floating-point-options/fp-model-fp.html)

## [3.22.0] - 2022-12-13

### Changed

- Moved to use GitHub Actions for label enforcement
- Add extra flags for Intel Fortran to allow for stricter builds
  - `-stand f18` to enable Fortran 2018 Standard compliance
  - `-diag-error 6188` to cause if(integer) to fail
  - `-diag-error 6192` to cause logical set to integer to fail
  - `-diag-disable 5268` to suppress warning for long source lines (which our macros often make)

## [3.21.0] - 2022-11-28

### Fixed

- Added compiler flags for `x86_64` target architecture and `Linux`, when it is missed by `Intel` processor description. Tested for building MAPL/2.22.0 on Ubuntu 22.04 Linux. Ubuntu is running using the UTM virtualizer on MacOS Monterey with x86_64 architecture system.

### Added

- Added a print for processor description

## [3.20.0] - 2022-11-09

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

