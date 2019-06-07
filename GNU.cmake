if (CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 5.3)
  message(FATAL_ERROR "${CMAKE_Fortran_COMPILER_ID} version must be at least 5.3!")
endif()

set (FREAL8 "-fdefault-real-8 -fdefault-double-8")
set (FINT8 "-fdefault-integer-8")
set (PP    "-cpp")
set (MISMATCH "")
# This doesn't seem to work at the moment
#set (BIG_ENDIAN "-fconvert=swap")
set (EXTENDED_SOURCE "-ffixed-line-length-132")
set (FIXED_SOURCE "-ffixed-form")
set (DISABLE_FIELD_WIDTH_WARNING)
set (CRAY_POINTER "-fcray-pointer")
set (ALIGNCOM "-falign-commons")
set (BYTERECLEN "-frecord-marker=4")
set (NO_RANGE_CHECK "-fno-range-check")
set (TRACEBACK "-fbacktrace")

####################################################

add_definitions(-D__GFORTRAN__)

# Common Fortran Flags
# --------------------
set (common_Fortran_flags "-ffree-line-length-none ${NO_RANGE_CHECK} -Wno-missing-include-dirs ${TRACEBACK}")
set (common_Fortran_fpe_flags "-ffpe-trap=zero,overflow ${TRACEBACK}")

# GEOS Debug
# ----------
set (GEOS_Fortran_Debug_Flags "-O0 -g -fcheck=all,no-array-temps -finit-real=snan")
set (GEOS_Fortran_Debug_FPE_Flags "${common_Fortran_fpe_flags}")

# GEOS Release
# ------------
set (GEOS_Fortran_Release_Flags "-O3 -march=westmere -mtune=generic -funroll-loops -g")
set (GEOS_Fortran_Release_FPE_Flags "${common_Fortran_fpe_flags}")

# GEOS Vectorize
# --------------
# NOTE: gfortran does get a benefit from vectorization, but the resulting code
#       does not layout regress. Options kept here for testing purposes

# Options per Jerry DeLisle on GCC Fortran List
#set (GEOS_Fortran_Vect_Flags "-O2 -march=native -ffast-math -ftree-vectorize -funroll-loops --param max-unroll-times=4 -mprefer-avx128 -mno-fma")

# Options per Jerry DeLisle on GCC Fortran List with SVML
#set (GEOS_Fortran_Vect_Flags "-O2 -march=native -ffast-math -ftree-vectorize -funroll-loops --param max-unroll-times=4 -mprefer-avx128 -mno-fma -mveclibabi=svml")
#set (GEOS_Fortran_Vect_FPE_Flags "-g ${TRACEBACK}")

# Until good options can be found, make vectorize equal common flags
set (GEOS_Fortran_Vect_Flags ${GEOS_Fortran_Release_Flags})
set (GEOS_Fortran_Vect_FPE_Flags ${GEOS_Fortran_Release_FPE_Flags})

# Common variables for every compiler
include(GenericCompiler)
