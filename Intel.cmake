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
set (FP_MODEL_SOURCE "-fp-model source")
set (FP_MODEL_STRICT "-fp-model strict")
set (FP_MODEL_CONSISTENT "-fp-model consistent")

set (OPTREPORT0 "-qopt-report0")
set (OPTREPORT5 "-qopt-report5")

set (FREAL8 "-r8")
set (FINT8 "-i8")

# [lrb,2020-01-10] 
# Use SHELL: prefix and quotes around multi-word arguments to 
# prevent de-duplication from breaking things. See
# https://cmake.org/cmake/help/latest/command/target_compile_options.html

set (PP    "-fpp")
set (MISMATCH "")
set (BIG_ENDIAN "-convert big_endian")
set (LITTLE_ENDIAN "-convert little_endian")
set (EXTENDED_SOURCE "-extend_source")
set (FIXED_SOURCE "-fixed")
set (DISABLE_FIELD_WIDTH_WARNING "-diag-disable 8291")
set (CRAY_POINTER "")
set (MCMODEL "-mcmodel medium -shared-intel")
set (HEAPARRAYS "-heap-arrays 32")
set (BYTERECLEN "\"SHELL:-assume byterecl\"")
set (ALIGNCOM "\"SHELL:-align dcommons\"")
set (TRACEBACK "-traceback")
set (NOOLD_MAXMINLOC "\"SHELL:-assume noold_maxminloc\"")
set (REALLOC_LHS "\"SHELL:-assume realloc_lhs\"")
set (ARCH_CONSISTENCY "-fimf-arch-consistency=true")
set (FTZ "-ftz")
set (ALIGN_ALL "\"SHELL:-align all\"")
set (NO_ALIAS "-fno-alias")

set (NO_RANGE_CHECK "")

add_definitions(-DHAVE_SHMEM)

####################################################

# Common Fortran Flags
# --------------------
set (common_Fortran_flags "${TRACEBACK} ${REALLOC_LHS}")
set (common_Fortran_fpe_flags "${FPE0} ${FP_MODEL_SOURCE} ${HEAPARRAYS} ${NOOLD_MAXMINLOC}")

# GEOS Debug
# ----------
set (GEOS_Fortran_Debug_Flags "${DEBINFO} ${FOPT0} ${FTZ} ${ALIGN_ALL} ${NO_ALIAS} -debug -nolib-inline -fno-inline-functions -assume protect_parens,minus0 -prec-div -prec-sqrt -check bounds -check uninit -fp-stack-check -warn unused -init=snan,arrays -save-temps")
set (GEOS_Fortran_Debug_FPE_Flags "${common_Fortran_fpe_flags}")

# GEOS Release
# ------------
set (GEOS_Fortran_Release_Flags "${FOPT3} ${DEBINFO} ${OPTREPORT0} ${FTZ} ${ALIGN_ALL} ${NO_ALIAS}")
set (GEOS_Fortran_Release_FPE_Flags "${common_Fortran_fpe_flags} ${ARCH_CONSISTENCY}")

# GEOS Vectorize
# --------------
set (GEOS_Fortran_Vect_Flags "${FOPT3} ${DEBINFO} -xCORE-AVX2 -fma -qopt-report0 ${FTZ} ${ALIGN_ALL} ${NO_ALIAS} -align array32byte")
set (GEOS_Fortran_Vect_FPE_Flags "${FPE3} ${FP_MODEL_CONSISTENT} ${NOOLD_MAXMINLOC}")

# Common variables for every compiler
include(GenericCompiler)
