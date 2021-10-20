if (CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 18.0.5)
  message(FATAL_ERROR "${CMAKE_Fortran_COMPILER_ID} version must be at least 18.0.5!")
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
set (ALIGN_ALL "-align all")
set (NO_ALIAS "-fno-alias")
set (USE_SVML "-fimf-use-svml=true")

set (NO_RANGE_CHECK "")

cmake_host_system_information(RESULT proc_decription QUERY PROCESSOR_DESCRIPTION)
if (${proc_decription} MATCHES "EPYC")
   set (COREAVX2_FLAG "-march=core-avx2")
elseif (${proc_decription} MATCHES "Intel")
   set (COREAVX2_FLAG "-xCORE-AVX2")
else ()
   message(FATAL_ERROR "Unknown processor. Contact Matt Thompson")
endif ()

add_definitions(-DHAVE_SHMEM)

####################################################

# Common Fortran Flags
# --------------------
set (common_Fortran_flags "${TRACEBACK} ${REALLOC_LHS}")
set (common_Fortran_fpe_flags "${FPE0} ${FP_MODEL_SOURCE} ${HEAPARRAYS} ${NOOLD_MAXMINLOC}")

# GEOS Debug
# ----------
set (GEOS_Fortran_Debug_Flags "${DEBINFO} ${FOPT0} ${FTZ} ${ALIGN_ALL} ${NO_ALIAS} -debug -nolib-inline -fno-inline-functions -assume protect_parens,minus0 -prec-div -prec-sqrt -check all,noarg_temp_created -fp-stack-check -warn unused -init=snan,arrays -save-temps")
set (GEOS_Fortran_Debug_FPE_Flags "${common_Fortran_fpe_flags}")

# GEOS NoVectorize
# ----------------
set (GEOS_Fortran_NoVect_Flags "${FOPT3} ${DEBINFO} ${OPTREPORT0} ${FTZ} ${ALIGN_ALL} ${NO_ALIAS}")
set (GEOS_Fortran_NoVect_FPE_Flags "${common_Fortran_fpe_flags} ${ARCH_CONSISTENCY}")

# NOTE It was found that the Vectorizing Flags gave better performance with the same results in testing.
#      But in case they are needed, we keep the older flags available

# GEOS Vectorize
# --------------
set (GEOS_Fortran_Vect_Flags "${FOPT3} ${DEBINFO} ${COREAVX2_FLAG} -fma -qopt-report0 ${FTZ} ${ALIGN_ALL} ${NO_ALIAS} -align array32byte")
set (GEOS_Fortran_Vect_FPE_Flags "${FPE3} ${FP_MODEL_CONSISTENT} ${NOOLD_MAXMINLOC}")

# GEOS Release
# ------------
set (GEOS_Fortran_Release_Flags  "${GEOS_Fortran_Vect_Flags}")
set (GEOS_Fortran_Release_FPE_Flags "${GEOS_Fortran_Vect_FPE_Flags}")

# GEOS Aggressive
# ---------------
set (GEOS_Fortran_Aggressive_Flags "${FOPT3} ${DEBINFO} ${COREAVX2_FLAG} -fma -qopt-report0 ${FTZ} ${ALIGN_ALL} ${NO_ALIAS} -align array32byte")
#set (GEOS_Fortran_Aggressive_Flags "${FOPT3} ${DEBINFO} -xSKYLAKE-AVX512 -qopt-zmm-usage=high -fma -qopt-report0 ${FTZ} ${ALIGN_ALL} ${NO_ALIAS} -align array64byte")
set (GEOS_Fortran_Aggressive_FPE_Flags "${FPE3} ${FP_MODEL_FAST2} ${USE_SVML} ${NOOLD_MAXMINLOC}")

# Common variables for every compiler
include(Generic_Fortran)
