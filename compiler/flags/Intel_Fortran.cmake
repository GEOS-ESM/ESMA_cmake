if (CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 15.1)
  message(FATAL_ERROR "${CMAKE_Fortran_COMPILER_ID} version must be at least 15.1!")
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
set (FP_SPECULATION_SAFE   "-fp-speculation=safe")
set (FP_SPECULATION_STRICT "-fp-speculation=strict")

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
set (PP    "-fpp")
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
set (ARRAY_ALIGN_32BYTE "-align array32byte")
set (ARRAY_ALIGN_64BYTE "-align array64byte")

cmake_host_system_information(RESULT proc_description QUERY PROCESSOR_DESCRIPTION)
if (${proc_description} MATCHES "EPYC")
  # AMD EPYC processors support AVX2, but only via the -march=core-avx2 flag
  set (COREAVX2_FLAG "-march=core-avx2")
elseif (${proc_description} MATCHES "Hygon")
  # Hygon processors support AVX2, but only via the -march=core-avx2 flag
  set (COREAVX2_FLAG "-march=core-avx2")
elseif (${proc_description} MATCHES "Intel|INTEL")
  # All the Intel processors that GEOS runs on support AVX2, but to be
  # consistent with the AMD processors, we use the -march=core-avx2 flag
  set (COREAVX2_FLAG "-march=core-avx2")
  # Previous versions of GEOS used this flag, which was not portable
  # for AMD. Keeping here for a few versions for historical purposes.
  #set (COREAVX2_FLAG "-xCORE-AVX2")
elseif ( ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "x86_64" )
  # This is a fallback for when the above doesn't work. It should work
  # for most x86_64 processors, but it is not guaranteed to be optimal.
  message(WARNING "Unknown processor type. Defaulting to a generic x86_64 processor. Performance may be suboptimal.")
  set (COREAVX2_FLAG "")
  # Once you are in here, you are probably on Rosetta, but not required.
  # Still, on Apple Rosetta we also now need to use the ld_classic as the linker
  if (APPLE)
    # Determine whether we need to add link options for version 15+ of the Apple command line utilities
    execute_process(COMMAND "pkgutil"
                            "--pkg-info=com.apple.pkg.CLTools_Executables"
                    OUTPUT_VARIABLE TEST)

    # Extract the full version X.Y
    string(REGEX REPLACE ".*version: ([0-9]+\\.[0-9]+).*" "\\1" CMDLINE_UTILS_VERSION ${TEST})
    message(STATUS "Apple command line utils version is '${CMDLINE_UTILS_VERSION}'")

    if ((${CMDLINE_UTILS_VERSION} VERSION_GREATER 14) AND (${CMDLINE_UTILS_VERSION} VERSION_LESS 16.3))
      message(STATUS "Adding link options '-Wl,-ld_classic'")
      add_link_options(-Wl,-ld_classic)
    endif ()
  endif ()
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
set (common_Fortran_flags "${TRACEBACK} ${REALLOC_LHS} ${OPTREPORT0} ${ALIGNCOM} ${NO_ALIAS}")
set (common_Fortran_fpe_flags "${NOOLD_MAXMINLOC} ${DISABLE_10121} ${DISABLE_10448}")

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
     "${FP_PRECISE} ${FP_SOURCE} ${FP_CONSISTENT} ${NO_FMA} ${ARCH_CONSISTENCY} ${FPE1} ${common_Fortran_fpe_flags}")

# Vectorization with floating point exception trapping
set (GEOS_Fortran_VectTrap_Flags
     "${FOPT2} ${COREAVX2_FLAG} ${ARRAY_ALIGN_32BYTE}")
set (GEOS_Fortran_VectTrap_FPE_Flags
     "${FP_PRECISE} ${FP_SOURCE} ${FP_CONSISTENT} ${NO_FMA} ${ARCH_CONSISTENCY} ${FPE0} -check uninit ${common_Fortran_fpe_flags}")

# Vectorized
set (GEOS_Fortran_Vect_Flags
     "${FOPT3} ${COREAVX2_FLAG} ${ARRAY_ALIGN_32BYTE}")
set (GEOS_Fortran_Vect_FPE_Flags
     "${FP_FAST1} ${FP_SOURCE} ${FP_CONSISTENT} ${NO_FMA} ${ARCH_CONSISTENCY} ${FP_SPECULATION_SAFE} ${FPE1} ${common_Fortran_fpe_flags}")

# Aggressive (fast math, SVML)
set (GEOS_Fortran_Aggressive_Flags
     "${FOPT3} ${COREAVX2_FLAG} ${ARRAY_ALIGN_32BYTE}")
set (GEOS_Fortran_Aggressive_FPE_Flags
     "${FP_FAST2} ${FP_SOURCE} ${FP_CONSISTENT} ${FMA} ${USE_SVML} ${FPE3} ${common_Fortran_fpe_flags}")

# Set Release flags
# -----------------
set (GEOS_Fortran_Release_Flags  "${GEOS_Fortran_Vect_Flags}")
set (GEOS_Fortran_Release_FPE_Flags "${GEOS_Fortran_Vect_FPE_Flags}")

# Common variables for every compiler
include(Generic_Fortran)

