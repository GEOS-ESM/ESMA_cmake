if (CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 8.3)
  message(FATAL_ERROR "${CMAKE_Fortran_COMPILER_ID} version must be at least 8.3!")
endif()

set (FOPT0 "-O0")
set (FOPT1 "-O1")
set (FOPT2 "-O2")
set (FOPT3 "-O3")
set (FOPT4 "-O3")
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

####################################################

add_definitions(-D__GFORTRAN__)

# Common Fortran Flags
# --------------------
set (common_Fortran_flags "-ffree-line-length-none ${NO_RANGE_CHECK} -Wno-missing-include-dirs ${TRACEBACK}")
set (common_Fortran_fpe_flags "-ffpe-trap=zero,overflow ${TRACEBACK} ${MISMATCH} ${ALLOW_BOZ}")

# GEOS Debug
# ----------
set (GEOS_Fortran_Debug_Flags "${FOPT0} ${DEBINFO} -fcheck=all,no-array-temps -finit-real=snan")
set (GEOS_Fortran_Debug_FPE_Flags "${common_Fortran_fpe_flags}")

# GEOS Release
# ------------
set (GEOS_Fortran_Release_Flags "${FOPT3} -march=westmere -mtune=generic -funroll-loops ${DEBINFO}")
set (GEOS_Fortran_Release_FPE_Flags "${common_Fortran_fpe_flags}")

# GEOS Vectorize
# --------------
# NOTE: gfortran does get a benefit from vectorization, but the resulting code
#       does not layout regress. Options kept here for testing purposes

# Options per Jerry DeLisle on GCC Fortran List
#set (GEOS_Fortran_Vect_Flags "${FOPT2} -march=native -ffast-math -ftree-vectorize -funroll-loops --param max-unroll-times=4 -mprefer-avx128 -mno-fma")
#set (GEOS_Fortran_Vect_FPE_Flags "${DEBINFO} ${TRACEBACK}")

# Options per Jerry DeLisle on GCC Fortran List with SVML (does not seem to help)
#set (GEOS_Fortran_Vect_Flags "-O2 -march=native -ffast-math -ftree-vectorize -funroll-loops --param max-unroll-times=4 -mprefer-avx128 -mno-fma -mveclibabi=svml")
#set (GEOS_Fortran_Vect_FPE_Flags "${DEBINFO} ${TRACEBACK}")

# Until good options can be found, make vectorize equal common flags
set (GEOS_Fortran_Vect_Flags ${GEOS_Fortran_Release_Flags})
set (GEOS_Fortran_Vect_FPE_Flags ${GEOS_Fortran_Release_FPE_Flags})

# Common variables for every compiler
include(GenericCompiler)
