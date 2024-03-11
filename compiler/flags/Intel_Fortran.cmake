if (CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 15.1)
  message(FATAL_ERROR "${CMAKE_Fortran_COMPILER_ID} version must be at least 15.1!")
endif()

set (FOPT0 "-O0")
set (FOPT1 "-O1")
set (FOPT2 "-O2")
set (FOPT3 "-O3")
set (FOPT4 "-O4")
set (DEBINFO "-g")

set (FPE0 "-fpe0")
set (FPE3 "-fpe3")
set (FP_MODEL_PRECISE "-fp-model precise")
set (FP_MODEL_EXCEPT "-fp-model except")
set (FP_MODEL_SOURCE "-fp-model source")
set (FP_MODEL_STRICT "-fp-model strict")
set (FP_MODEL_CONSISTENT "-fp-model consistent")
set (FP_MODEL_FAST "-fp-model fast")
set (FP_MODEL_FAST1 "-fp-model fast=1")
set (FP_MODEL_FAST2 "-fp-model fast=2")

set (OPTREPORT0 "-qopt-report0")
set (OPTREPORT5 "-qopt-report5")

set (FREAL8 "-r8")
set (FINT8 "-i8")

set (PP    "-fpp")
set (MISMATCH "")
set (BIG_ENDIAN "-convert big_endian")
set (LITTLE_ENDIAN "-convert little_endian")
set (EXTENDED_SOURCE "-extend-source")
set (FIXED_SOURCE "-fixed")
set (DISABLE_FIELD_WIDTH_WARNING "-diag-disable 8291")
set (DISABLE_GLOBAL_NAME_WARNING "-diag-disable 5462")
set (CRAY_POINTER "")
set (MCMODEL "-mcmodel medium -shared-intel")
set (HEAPARRAYS "-heap-arrays 32")
set (BYTERECLEN "-assume byterecl")
set (ALIGNCOM "-align dcommons")
set (TRACEBACK "-traceback")
set (NOOLD_MAXMINLOC "-assume noold_maxminloc")
set (REALLOC_LHS "-assume realloc_lhs")
set (ARCH_CONSISTENCY "-fimf-arch-consistency=true")
set (FTZ "-ftz")
set (FMA "-fma")
set (ALIGN_ALL "-align all")
set (NO_ALIAS "-fno-alias")
set (USE_SVML "-fimf-use-svml=true")
set (INIT_SNAN "-init=snan,arrays")

# Additional flags for better Standards compliance
## Set the Standard to be Fortran 2018
set (STANDARD_F18 "-stand f18")
## Error out if you try to do if(integer)
set (ERROR_IF_INTEGER "-diag-error 6188")
## Error out if you try to set a logical to an integer
set (ERROR_LOGICAL_SET_TO_INTEGER "-diag-error 6192")
## Turn off warning #5268 (Extension to standard: The text exceeds right hand column allowed on the line.)
set (DISABLE_LONG_LINE_LENGTH_WARNING "-diag-disable 5268")

## Turn off ifort: warning #10337: option '-fno-builtin' disables '-imf*' option
set (DISABLE_10337 "-diag-disable 10337")

## Turn off ifort: command line warning #10121: overriding '-fp-model precise' with '-fp-model fast'
set (DISABLE_10121 "-diag-disable 10121")

set (NO_RANGE_CHECK "")

cmake_host_system_information(RESULT proc_description QUERY PROCESSOR_DESCRIPTION)
if (${proc_description} MATCHES "EPYC")
  # AMD EPYC processors support AVX2, but only via the -march=core-avx2 flag
  set (COREAVX2_FLAG "-march=core-avx2")
elseif (${proc_description} MATCHES "Hygon")
  # Hygon processors support AVX2, but only via the -march=core-avx2 flag
  set (COREAVX2_FLAG "-march=core-avx2")
elseif (${proc_description} MATCHES "Intel")
  # All the Intel processors that GEOS runs on support AVX2, but to be
  # consistent with the AMD processors, we use the -march=core-avx2 flag
  set (COREAVX2_FLAG "-march=core-avx2")
  # Previous versions of GEOS used this flag, which was not portable
  # for AMD. Keeping here for a few versions for historical purposes.
  #set (COREAVX2_FLAG "-xCORE-AVX2")
elseif ( ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "x86_64" )
  # This is a fallback for when the above doesn't work. It should work
  # for most x86_64 processors, but it is not guaranteed to be optimal.
  message(WARNING "Unknown processory type. Defaulting to a generic x86_64 processor. Performance may be suboptimal.")
  set (COREAVX2_FLAG "")
  # Once you are in here, you are probably on Rosetta, but not required. 
  # Still, on Apple Rosetta we also now need to use the ld_classic as the linker
  if (APPLE)
    add_link_options("-Wl,-ld_classic")
  endif ()
else ()
  message(FATAL_ERROR "Unknown processor. Please file an issue at https://github.com/GEOS-ESM/ESMA_cmake")
endif ()

add_definitions(-DHAVE_SHMEM)

# Make an option to make things quiet during debug builds
option (QUIET_DEBUG "Suppress excess compiler output during debug builds" OFF)
if (QUIET_DEBUG)
  set (WARN_UNUSED "")
  set (SUPPRESS_COMMON_WARNINGS "${DISABLE_FIELD_WIDTH_WARNING} ${DISABLE_GLOBAL_NAME_WARNING} ${DISABLE_10337}")
else ()
  set (WARN_UNUSED "-warn unused")
  set (SUPPRESS_COMMON_WARNINGS "${DISABLE_GLOBAL_NAME_WARNING} ${DISABLE_10337}")
endif ()

####################################################

# Common Fortran Flags
# --------------------
set (common_Fortran_flags "${TRACEBACK} ${REALLOC_LHS} ${OPTREPORT0} ${ALIGN_ALL} ${NO_ALIAS}")
set (common_Fortran_fpe_flags "${FTZ} ${NOOLD_MAXMINLOC} ${DISABLE_10121}")

# GEOS Debug
# ----------
set (GEOS_Fortran_Debug_Flags "${DEBINFO} ${FOPT0} -debug -nolib-inline -fno-inline-functions -assume protect_parens,minus0 -prec-div -prec-sqrt -check all,noarg_temp_created -fp-stack-check ${WARN_UNUSED} -save-temps")

# Testing shows that -init=snan,arrays and -fpe0 causes MAPL test failures with
# Intel Fortran 2021.10. So we will append the flags only if the version
# is less than 2021.10. However, we have to check the version in a weird
# way. For example, Intel ifort 2021.6 is reported by CMake as:
#   2021.6.0.20220226
# Intel 2021.10 reports as:
#   2021.10.0.20230609
# but Intel ifort 2021.11 is reported by CMake as:
#   2021.0.0.20231010
# So we can't depend on anything but the last node of the version string.
# First we need to extract the last node of the version string
string(REGEX MATCH "([0-9]+)$" CMAKE_Fortran_COMPILER_VERSION_LAST_NODE ${CMAKE_Fortran_COMPILER_VERSION})
message(STATUS "CMAKE_Fortran_COMPILER_VERSION_LAST_NODE: ${CMAKE_Fortran_COMPILER_VERSION_LAST_NODE}")

# Now we can compare the last node to see if it is less than 20230609
if (CMAKE_Fortran_COMPILER_VERSION_LAST_NODE VERSION_LESS 20230609)
  message(STATUS "Adding -init=snan,arrays to GEOS_Fortran_Debug_Flags")
  set (GEOS_Fortran_Debug_Flags "${GEOS_Fortran_Debug_Flags} ${INIT_SNAN}")
endif ()

set (GEOS_Fortran_Debug_FPE_Flags "${FP_MODEL_SOURCE} ${FP_MODEL_CONSISTENT} ${FP_MODEL_EXCEPT} ${common_Fortran_fpe_flags} ${SUPPRESS_COMMON_WARNINGS}")

# Like above, we can only add ${FPE0} if the version is less than 20230609
if (CMAKE_Fortran_COMPILER_VERSION_LAST_NODE VERSION_LESS 20230609)
  message(STATUS "Adding ${FPE0} to GEOS_Fortran_Debug_FPE_Flags")
  set (GEOS_Fortran_Debug_FPE_Flags "${GEOS_Fortran_Debug_FPE_Flags} ${FPE0}")
endif ()

# GEOS NoVectorize
# ----------------
set (GEOS_Fortran_NoVect_Flags "${FOPT3} ${DEBINFO}")
set (GEOS_Fortran_NoVect_FPE_Flags "${FPE3} ${FP_MODEL_FAST} ${FP_MODEL_SOURCE} ${FP_MODEL_CONSISTENT} ${common_Fortran_fpe_flags}")

# NOTE It was found that the Vectorizing Flags gave better performance with the same results in testing.
#      But in case they are needed, we keep the older flags available

# GEOS Vectorize
# ---------------
set (GEOS_Fortran_Vect_Flags "${FOPT3} ${DEBINFO} ${COREAVX2_FLAG} ${FMA} -align array32byte")
set (GEOS_Fortran_Vect_FPE_Flags "${FPE3} ${FP_MODEL_FAST} ${FP_MODEL_SOURCE} ${FP_MODEL_CONSISTENT} ${common_Fortran_fpe_flags}")

# --------------

# Set Release flags
# -----------------
set (GEOS_Fortran_Release_Flags  "${GEOS_Fortran_Vect_Flags}")
set (GEOS_Fortran_Release_FPE_Flags "${GEOS_Fortran_Vect_FPE_Flags}")

# GEOS Aggressive
# ---------------
set (GEOS_Fortran_Aggressive_Flags "${FOPT3} ${DEBINFO} ${COREAVX2_FLAG} ${FMA} -align array32byte")
set (GEOS_Fortran_Aggressive_FPE_Flags "${FPE3} ${FP_MODEL_FAST2} ${USE_SVML} ${common_Fortran_fpe_flags}")

# Common variables for every compiler
include(Generic_Fortran)
