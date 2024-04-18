if (CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 8.3)
  message(FATAL_ERROR "${CMAKE_Fortran_COMPILER_ID} version must be at least 8.3!")
endif()

set (FOPT0 "-O0")
set (FOPT1 "-O1")
set (FOPT2 "-O2")
set (FOPT3 "-O3")
set (FOPT4 "-O3")
set (FOPTFAST "-Ofast")
set (DEBINFO "-g")

set (FPE0 "")
set (FPE3 "")
set (FP_MODEL_SOURCE "")
set (FP_MODEL_STRICT "")
set (FP_MODEL_CONSISTENT "")

set (OPTREPORT0 "")
set (OPTREPORT5 "")

set (FREAL8 "-fdefault-real-8 -fdefault-double-8")
set (FINT8 "-fdefault-integer-8")
set (UNUSED_DUMMY "-Wno-unused-dummy-argument")
set (PP    "-cpp")

# GCC 10 changed behavior in how it handles Fortran. To wit:

#   Mismatches between actual and dummy argument lists in a single file are
#   now rejected with an error. Use the new option -fallow-argument-mismatch
#   to turn these errors into warnings; this option is implied with
#   -std=legacy. -Wargument-mismatch has been removed.

#   The handling of a BOZ literal constant has been reworked to provide
#   better conformance to the Fortran 2008 and 2018 standards. In these
#   Fortran standards, a BOZ literal constant is a typeless and kindless
#   entity. As a part of the rework, documented and undocumented extensions
#   to the Fortran standard now emit errors during compilation. Some of
#   these extensions are permitted with the -fallow-invalid-boz, where the
#   error is degraded to a warning and the code is compiled as with older
#   gfortran.

# GEOS has many places where, if not converted to warning, the model
# will not build. Until the code can be fixed, for now we set the flags to
# convert to warnings. But by using an option() we can allow this to be
# turned off for testing.

# GCC 9 and lower do not have the flag...
set (MISMATCH "")
set (ALLOW_BOZ "")

# With GCC 10...
if (CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL 10)

  # First for the argument mismatch
  option(MISMATCH_IS_ERROR "Argument mismatches are errors, not warnings" OFF)
  if (NOT MISMATCH_IS_ERROR)
    ecbuild_warn (
      "Argument mismatches will be treated as *warnings* and not *errors*. "
      "Per the gfortran 10 man page:\n"
      "Some code contains calls to external procedures which \n"
      "mismatches between the calls and the procedure definition, \n"
      "or with mismatches between different calls.  Such code is \n"
      "non-conforming, and will usually be flagged wi1th an error. \n"
      "This options degrades the error to a warning, which can \n"
      "only be disabled by disabling all warnings vial -w.  Only a \n"
      "single occurrence per argument is flagged by this warning. \n"
      "-fallow-argument-mismatch is implied by -std=legacy.\n"
      "Using this option is *strongly* discouraged.  It is possible to \n"
      "provide standard-conforming code which allows different types \n"
      "of arguments by using an explicit interface and TYPE(*).")
    set (MISMATCH "-fallow-argument-mismatch")
  endif ()

  # Then for BOZ constants
  option(INVALID_BOZ_IS_ERROR "Use of invalid BOZ constants are errors, not warnings" OFF)
  if (NOT INVALID_BOZ_IS_ERROR)
    ecbuild_warn(
      "Invalid use of BOZ literal constants will be treated as *warnings* and not as *errors*. "
      "Per the GCC 10 release notes:\n"
      "The handling of a BOZ literal constant has been reworked \n"
      "to provide better conformance to the Fortran 2008 and 2018 \n"
      "standards. In these Fortran standards, a BOZ literal constant is a \n"
      "typeless and kindless entity. As a part of the rework, documented \n"
      "and undocumented extensions to the Fortran standard now emit \n"
      "errors during compilation. Some of these extensions are permitted \n"
      "with the -fallow-invalid-boz, where the error is degraded to a \n"
      "warning and the code is compiled as with older gfortran.")
    set (ALLOW_BOZ "-fallow-invalid-boz")
  endif ()
endif ()

#set (BIG_ENDIAN "-fconvert=swap") # This doesn't seem to work at the moment
#set (LITTLE_ENDIAN "") # Not sure
set (EXTENDED_SOURCE "-ffixed-line-length-132")
set (FIXED_SOURCE "-ffixed-form")
set (DISABLE_FIELD_WIDTH_WARNING "")
set (CRAY_POINTER "-fcray-pointer")
set (MCMODEL "")
set (HEAPARRAYS "")
set (BYTERECLEN "-frecord-marker=4")
set (ALIGNCOM "-falign-commons")
set (TRACEBACK "-fbacktrace")
set (NOOLD_MAXMINLOC "")
set (REALLOC_LHS "")
set (ARCH_CONSISTENCY "")
set (FTZ "")
set (ALIGN_ALL "")
set (NO_ALIAS "")

set (NO_RANGE_CHECK "-fno-range-check")

cmake_host_system_information(RESULT proc_description QUERY PROCESSOR_DESCRIPTION)

if ( ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL aarch64 )
  set (GNU_TARGET_ARCH "armv8.2-a+crypto+crc+fp16+rcpc+dotprod")
  set (GNU_NATIVE_ARCH ${GNU_TARGET_ARCH})
elseif (${proc_description} MATCHES "Apple M")
  if (${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "arm64")
    # Testing show GEOS fails with -march=native on M1 in native mode
    set (GNU_TARGET_ARCH "armv8-a")
    set (GNU_NATIVE_ARCH ${GNU_TARGET_ARCH})
  elseif (${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "x86_64")
    # Rosetta2 flags per tests by @climbfuji
    set (GNU_TARGET_ARCH "westmere")
    set (GNU_NATIVE_ARCH "native")
    set (PREFER_AVX128 "-mprefer-avx128")
    set (NO_FMA "-mno-fma")
  endif ()
elseif (${proc_description} MATCHES "EPYC")
  set (GNU_TARGET_ARCH "znver2")
  set (GNU_NATIVE_ARCH "native")
  set (NO_FMA "-mno-fma")
elseif (${proc_description} MATCHES "Intel")
  set (GNU_TARGET_ARCH "haswell")
  set (GNU_NATIVE_ARCH "native")
  set (PREFER_AVX128 "-mprefer-avx128")
  set (NO_FMA "-mno-fma")
elseif ( ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "x86_64" )
  message(WARNING "Unknown processor type. Defaulting to a generic x86_64 processor. Performance may be suboptimal.")
  set (GNU_TARGET_ARCH "x86-64")
  set (GNU_NATIVE_ARCH "native")
else ()
  message(FATAL_ERROR "Unknown processor. Please file an issue at https://github.com/GEOS-ESM/ESMA_cmake")
endif ()

if (APPLE)
  # We seem to now require (sometimes?) the use of ld_classic if on Apple
  add_link_options(-Wl,-ld_classic)

  # Also, if our C compiler is Apple Clang, we need to pass -Wno-implicit-int to our C flags
  if (CMAKE_C_COMPILER_ID MATCHES "Clang")
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-implicit-int")
  endif ()
endif ()

####################################################

add_definitions(-D__GFORTRAN__)

# Common Fortran Flags
# --------------------
set (common_Fortran_flags "-ffree-line-length-none ${NO_RANGE_CHECK} -Wno-missing-include-dirs ${TRACEBACK} ${UNUSED_DUMMY}" )
set (common_Fortran_fpe_flags "-ffpe-trap=zero,overflow ${TRACEBACK} ${MISMATCH} ${ALLOW_BOZ}")

# GEOS Debug
# ----------
set (GEOS_Fortran_Debug_Flags "${FOPT0} ${DEBINFO} -fcheck=all,no-array-temps -finit-real=snan -save-temps")
set (GEOS_Fortran_Debug_FPE_Flags "${common_Fortran_fpe_flags}")

# GEOS Release
# ------------
set (GEOS_Fortran_Release_Flags "${FOPT3} -march=${GNU_TARGET_ARCH} -mtune=generic -funroll-loops ${DEBINFO}")
set (GEOS_Fortran_Release_FPE_Flags "${common_Fortran_fpe_flags}")

# Create a NoVectorize version for consistency. No difference from Release for GNU

# GEOS NoVectorize
# ----------------
set (GEOS_Fortran_NoVect_Flags  "${GEOS_Fortran_Release_Flags}")
set (GEOS_Fortran_NoVect_FPE_Flags "${GEOS_Fortran_Release_FPE_Flags}")

# GEOS Vectorize
# --------------
# NOTE: gfortran does get a benefit from vectorization, but the resulting code
#       does not layout regress. See Aggressive for the vectorizing flags

# Until good options can be found, make vectorize equal common flags
set (GEOS_Fortran_Vect_Flags ${GEOS_Fortran_Release_Flags})
set (GEOS_Fortran_Vect_FPE_Flags ${GEOS_Fortran_Release_FPE_Flags})

# GEOS Aggressive
# ---------------
# NOTE: gfortran does get a benefit from vectorization, but the resulting code
#       does not layout regress.
# NOTE2: This uses -march=native so compile on your target architecture!!!

# Options per Jerry DeLisle on GCC Fortran List
if (${proc_description} MATCHES "Apple M1" AND ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "arm64")
  # For now the only arm64 we have tested is Apple M1. This
  # might need to be revisited for M1 Max/Ultra and M2+.
  # Testing has not yet found any aggressive flags better than
  # the release so for now, use those
  set (GEOS_Fortran_Aggressive_Flags "${GEOS_Fortran_Release_Flags}")
  set (GEOS_Fortran_Aggressive_FPE_Flags "${GEOS_Fortran_Release_FPE_Flags}")
else ()
  set (GEOS_Fortran_Aggressive_Flags "${FOPT2} -march=${GNU_NATIVE_ARCH} -ffast-math -ftree-vectorize -funroll-loops --param max-unroll-times=4 ${PREFER_AVX128} ${NO_FMA}")
  set (GEOS_Fortran_Aggressive_FPE_Flags "${DEBINFO} ${TRACEBACK} ${MISMATCH} ${ALLOW_BOZ}")
endif ()


# Options per Jerry DeLisle on GCC Fortran List with SVML (does not seem to help)
#set (GEOS_Fortran_Aggressive_Flags "-O2 -march=native -ffast-math -ftree-vectorize -funroll-loops --param max-unroll-times=4 ${PREFER_AVX128} -mno-fma -mveclibabi=svml")
#set (GEOS_Fortran_Aggressive_FPE_Flags "${DEBINFO} ${TRACEBACK} ${MISMATCH} ${ALLOW_BOZ}")


# Common variables for every compiler
include(Generic_Fortran)
