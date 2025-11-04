if (CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 20)
  message(FATAL_ERROR "${CMAKE_Fortran_COMPILER_ID} version must be at least 20!")
endif()

set (FOPT0 "-O0")
set (FOPT1 "-O1")
set (FOPT2 "-O2")
set (FOPT3 "-O3")
set (FOPT4 "-O4")
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
set (UNUSED_DUMMY "")
set (PP    "-cpp")

#set (BIG_ENDIAN "-fconvert=swap") # This doesn't seem to work at the moment
#set (LITTLE_ENDIAN "") # Not sure
set (EXTENDED_SOURCE "-ffixed-line-length-132")
set (FIXED_SOURCE "-ffixed-form")
set (MCMODEL "")
set (TRACEBACK "")
set (NOOLD_MAXMINLOC "")
set (REALLOC_LHS "")
set (ARCH_CONSISTENCY "")
set (FTZ "")
set (ALIGN_ALL "")
set (NO_ALIAS "")

set (NO_RANGE_CHECK "")

cmake_host_system_information(RESULT proc_description QUERY PROCESSOR_DESCRIPTION)

# NOT SURE ABOUT ANY OF THIS...
if ( ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL aarch64 )
  set (FLANG_TARGET_ARCH "-mcpu=armv8.2-a+crypto+crc+fp16+rcpc+dotprod")
elseif (${proc_description} MATCHES "Apple M")
  set (FLANG_TARGET_ARCH "-mcpu=apple-m1")
elseif (${proc_description} MATCHES "EPYC")
  set (FLANG_TARGET_ARCH "-mcpu=znver2")
elseif (${proc_description} MATCHES "Intel|INTEL")
  set (FLANG_TARGET_ARCH "-mcpu=haswell")
elseif ( ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "x86_64" )
  message(WARNING "Unknown processor type. Defaulting to a generic x86_64 processor. Performance may be suboptimal.")
  set (FLANG_TARGET_ARCH "x86-64")
else ()
  message(FATAL_ERROR "Unknown processor. Please file an issue at https://github.com/GEOS-ESM/ESMA_cmake")
endif ()

# ...SO WE JUST TURN OFF FLANG_TARGET_ARCH FOR NOW
set (FLANG_TARGET_ARCH "")

####################################################

# Common Fortran Flags
# --------------------
set (common_Fortran_flags "${NO_RANGE_CHECK} ${TRACEBACK} ${UNUSED_DUMMY}" )
set (common_Fortran_fpe_flags "${TRACEBACK}")

# GEOS Debug
# ----------
set (GEOS_Fortran_Debug_Flags "${FOPT0} ${DEBINFO}")
set (GEOS_Fortran_Debug_FPE_Flags "${common_Fortran_fpe_flags}")

# GEOS Release
# ------------
set (GEOS_Fortran_Release_Flags "${FOPT3} ${FLANG_TARGET_ARCH} ${DEBINFO}")
set (GEOS_Fortran_Release_FPE_Flags "${common_Fortran_fpe_flags}")

# Create a NoVectorize version for consistency. No difference from Release for Flang

# GEOS NoVectorize
# ----------------
set (GEOS_Fortran_NoVect_Flags  "${GEOS_Fortran_Release_Flags}")
set (GEOS_Fortran_NoVect_FPE_Flags "${GEOS_Fortran_Release_FPE_Flags}")

# GEOS Vectorize
# --------------
# Until good options can be found, make vectorize equal common flags
set (GEOS_Fortran_Vect_Flags ${GEOS_Fortran_Release_Flags})
set (GEOS_Fortran_Vect_FPE_Flags ${GEOS_Fortran_Release_FPE_Flags})

# GEOS Aggressive
# ---------------
# Until good options can be found, make vectorize equal common flags
set (GEOS_Fortran_Aggressive_Flags ${GEOS_Fortran_Release_Flags})
set (GEOS_Fortran_Aggressive_FPE_Flags ${GEOS_Fortran_Release_FPE_Flags})

# Common variables for every compiler
include(Generic_Fortran)
