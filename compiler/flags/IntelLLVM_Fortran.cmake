if (CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 2025.1)
  message(FATAL_ERROR "${CMAKE_Fortran_COMPILER_ID} version must be at least 2025.1!")
endif()

# ----------------------------------------------------------------------
# Optimization levels
# ----------------------------------------------------------------------
set (FOPT0 "-O0")
set (FOPT1 "-O1")
set (FOPT2 "-O2")
set (FOPT3 "-O3")
set (FOPT4 "-O4")
set (FFAST "-fast")

# Debug info
set (DEBINFO "-g")

# ----------------------------------------------------------------------
# Floating-point handling
# ----------------------------------------------------------------------
set (FPE0 "-fpe0")
set (FPE1 "-fpe1")
set (FPE3 "-fpe3")

# Grouped FP models
set (FP_SOURCE     "-fp-model source")
set (FP_CONSISTENT "-fp-model consistent")
set (FP_EXCEPT     "-fp-model except")
set (FP_PRECISE    "-fp-model precise")
set (FP_STRICT     "-fp-model strict")
set (FP_FAST       "-fp-model fast")
set (FP_FAST1      "-fp-model fast=1")
set (FP_FAST2      "-fp-model fast=2")

# -fp-speculation=fast is the compiler default
set (FP_SPECULATION_FAST   "-fp-speculation=fast")
# Testing with ifx 2025.2 found these flags caused a lot
# of ICEs. For now we turn off
#set (FP_SPECULATION_SAFE "-fp-speculation=safe")
#set (FP_SPECULATION_STRICT "-fp-speculation=strict")

set (ARCH_CONSISTENCY "-fimf-arch-consistency=true")

set (FTZ "-ftz")
set (NO_PREC_DIV "-no-prec-div")
set (USE_SVML "-fimf-use-svml=true ")

set (IPO "-ipo")
set (FMA "-fma")
set (NO_FMA "-no-fma")
set (FREAL8 "-r8")
set (FINT8 "-i8")

# ----------------------------------------------------------------------
# Reports
# ----------------------------------------------------------------------
set (OPTREPORT0 "-qopt-report0")
set (OPTREPORT5 "-qopt-report5")

# ----------------------------------------------------------------------
# Portability / source format
# ----------------------------------------------------------------------
set(PP "-fpp") # default for all other versions
if(CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL 2025.2 AND CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 2025.3)

  message(STATUS "Working around ifx ${CMAKE_Fortran_COMPILER_VERSION} FPP bug (using external cpp -P)")

  # Find a preprocessor; prefer 'cpp', fall back to 'clang-cpp'
  find_program(cpp_exe NAMES cpp clang-cpp)
  if(NOT cpp_exe)
    message(FATAL_ERROR "ifx 2025.2 workaround requested but no 'cpp' or 'clang-cpp' found")
  endif()
  message(STATUS "Found preprocessor: ${cpp_exe}")

  # Make a small wrapper that injects -P (no linemarkers)
  set(cpp_wrapper "${CMAKE_BINARY_DIR}/tools/cpp_no_lines")
  file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/tools")

  if(WIN32)
    # If you actually build on Windows with ifx, create a .bat wrapper
    file(WRITE "${cpp_wrapper}.bat"
"@echo off\r
\"${cpp_exe}\" -P -traditional-cpp -undef %*\r
")
    set(PP "-fpp-name=${cpp_wrapper}.bat")
  else()
    file(WRITE "${cpp_wrapper}"
"#!/usr/bin/env bash
exec \"${cpp_exe}\" -P -traditional-cpp -undef \"$@\"
")
    file(CHMOD "${cpp_wrapper}" FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
    set(PP "-fpp-name=${cpp_wrapper}")
  endif()
endif()

set (BIG_ENDIAN "-convert big_endian")
set (LITTLE_ENDIAN "-convert little_endian")
set (EXTENDED_SOURCE "-extend-source")
set (FIXED_SOURCE "-fixed")
set (NO_RANGE_CHECK "")

# ----------------------------------------------------------------------
# Warnings / diagnostics
# ----------------------------------------------------------------------
set (DISABLE_FIELD_WIDTH_WARNING "-diag-disable 8291")
set (DISABLE_GLOBAL_NAME_WARNING "-diag-disable 5462")
set (DISABLE_10337 "-diag-disable 10337")   # fno-builtin warning
set (DISABLE_10121 "-diag-disable 10121")   # fp-model override warning
set (DISABLE_10448 "-diag-disable 10448")   # ifort deprecation remark
set (DISABLE_LONG_LINE_LENGTH_WARNING "-diag-disable 5268")

# Make an option to make things quiet during debug builds
option (QUIET_DEBUG "Suppress excess compiler output during debug builds" OFF)
if (QUIET_DEBUG)
  set (WARN_UNUSED "")
  set (SUPPRESS_COMMON_WARNINGS "${DISABLE_FIELD_WIDTH_WARNING} ${DISABLE_GLOBAL_NAME_WARNING} ${DISABLE_10337}")
else ()
  set (WARN_UNUSED "-warn unused")
  set (SUPPRESS_COMMON_WARNINGS "${DISABLE_GLOBAL_NAME_WARNING} ${DISABLE_10337}")
endif ()

# ----------------------------------------------------------------------
# Standards Compliance (used in MAPL)
# ----------------------------------------------------------------------
## Set the Standard to be Fortran 2018
set (STANDARD_F18 "-stand f18")
## Error out if you try to do if(integer)
set (ERROR_IF_INTEGER "-diag-error 6188")
## Error out if you try to set a logical to an integer
set (ERROR_LOGICAL_SET_TO_INTEGER "-diag-error 6192")
## Turn off warning #5268 (Extension to standard: The text exceeds right hand column allowed on the line.)
set (DISABLE_LONG_LINE_LENGTH_WARNING "-diag-disable 5268")

# ----------------------------------------------------------------------
# Memory / alignment
# ----------------------------------------------------------------------
set (MCMODEL "-mcmodel medium -shared-intel")
set (HEAPARRAYS "-heap-arrays 32")
set (BYTERECLEN "-assume byterecl")
set (TRACEBACK "-traceback")
set (NOOLD_MAXMINLOC "-assume noold_maxminloc")
set (REALLOC_LHS "-assume realloc_lhs")
set (ALIGNCOM "-align dcommons")
set (NO_ALIAS "-fno-alias")
set (ALIGN_ALL "-align all")
set (ARRAY_ALIGN_32BYTE "-align array32byte")
set (ARRAY_ALIGN_64BYTE "-align array64byte")

cmake_host_system_information(RESULT proc_description QUERY PROCESSOR_DESCRIPTION)
if (${proc_description} MATCHES "EPYC")
  set (MARCH_FLAG "-march=x86-64-v3")
elseif (${proc_description} MATCHES "Hygon")
  set (MARCH_FLAG "-march=x86-64-v3")
elseif (${proc_description} MATCHES "Intel|INTEL")
  # All the Intel processors that GEOS runs on support AVX2, but to be
  # consistent with the AMD processors, we use the -march=x86-64-v3 flag
  set (MARCH_FLAG "-march=x86-64-v3")
elseif ( ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "x86_64" )
  # This is a fallback for when the above doesn't work. It should work
  # for most x86_64 processors, but it is not guaranteed to be optimal.
  message(WARNING "Unknown processor type. Defaulting to a generic x86_64 processor. Performance may be suboptimal.")
  set (MARCH_FLAG "x86-64")
else ()
  message(FATAL_ERROR "Unknown processor. Please file an issue at https://github.com/GEOS-ESM/ESMA_cmake")
endif ()

# ----------------------------------------------------------------------
# Defines
# ----------------------------------------------------------------------
add_definitions(-DHAVE_SHMEM)

# ----------------------------------------------------------------------
# Common flag bundles
# ----------------------------------------------------------------------
set (common_Fortran_flags "${TRACEBACK} ${REALLOC_LHS} ${OPTREPORT0} ${ALIGN_ALL} ${NO_ALIAS} ${PP}")
set (common_Fortran_fpe_flags "${FTZ} ${NOOLD_MAXMINLOC}")

# ----------------------------------------------------------------------
# Build type specific bundles
# ----------------------------------------------------------------------
# Debug
set (GEOS_Fortran_Debug_Flags "${DEBINFO} ${FOPT0} -debug -nolib-inline -fno-inline-functions -assume protect_parens,minus0 -prec-div -prec-sqrt -check all,noarg_temp_created -fp-stack-check ${WARN_UNUSED} -init=snan,arrays -save-temps")
set (GEOS_Fortran_Debug_FPE_Flags "${FPE0} ${FP_MODEL_STRICT} ${FP_SPECULATION_STRICT} ${common_Fortran_fpe_flags} ${SUPPRESS_COMMON_WARNINGS}")

# Strict (bitwise reproducible, IEEE-compliant)
set (GEOS_Fortran_Strict_Flags "${FOPT2} ${DEBINFO}")
set (GEOS_Fortran_Strict_FPE_Flags
     "${FP_STRICT} ${FP_SPECULATION_STRICT} ${FPE0} -check uninit -prec-div -prec-sqrt -no-ftz ${common_Fortran_fpe_flags}")

# NoVect (bitwise stable, no FMA)
set (GEOS_Fortran_NoVect_Flags
     "${FOPT3}")
set (GEOS_Fortran_NoVect_FPE_Flags
     "${FP_CONSISTENT} ${NO_FMA} ${ARCH_CONSISTENCY} ${FPE1} ${common_Fortran_fpe_flags}")

# Vectorization with floating point exception trapping
set (GEOS_Fortran_VectTrap_Flags
     "${FOPT2} ${COREAVX2_FLAG} ${ARRAY_ALIGN_32BYTE}")
set (GEOS_Fortran_VectTrap_FPE_Flags
     "${FP_CONSISTENT} ${NO_FMA} ${ARCH_CONSISTENCY} ${FPE0} -check uninit ${common_Fortran_fpe_flags}")

# Vectorized
set (GEOS_Fortran_Vect_Flags
     "${FOPT3} ${COREAVX2_FLAG} ${ARRAY_ALIGN_32BYTE}")
set (GEOS_Fortran_Vect_FPE_Flags
     "${FP_FAST1} ${FP_CONSISTENT} ${NO_FMA} ${ARCH_CONSISTENCY} ${FP_SPECULATION_SAFE} ${FPE1} ${common_Fortran_fpe_flags}")

# Aggressive (fast math, SVML)
set (GEOS_Fortran_Aggressive_Flags
     "${FOPT3} ${COREAVX2_FLAG} ${ARRAY_ALIGN_32BYTE}")
set (GEOS_Fortran_Aggressive_FPE_Flags
     "${FP_FAST2} ${FP_CONSISTENT} ${FMA} ${USE_SVML} ${FPE3} ${common_Fortran_fpe_flags}")

# Set Release flags
# -----------------
set (GEOS_Fortran_Release_Flags  "${GEOS_Fortran_Vect_Flags}")
set (GEOS_Fortran_Release_FPE_Flags "${GEOS_Fortran_Vect_FPE_Flags}")

# Common variables for every compiler
include(Generic_Fortran)
