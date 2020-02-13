set (GEOS_Fortran_FLAGS_DEBUG   "${GEOS_Fortran_Debug_Flags} ${common_Fortran_flags} ${GEOS_Fortran_Debug_FPE_Flags} ${ALIGNCOM}")
set (GEOS_Fortran_FLAGS_RELEASE "${GEOS_Fortran_Release_Flags} ${common_Fortran_flags} ${GEOS_Fortran_Release_FPE_Flags} ${ALIGNCOM}")
set (GEOS_Fortran_FLAGS_VECT    "${GEOS_Fortran_Vect_Flags} ${common_Fortran_flags} ${GEOS_Fortran_Vect_FPE_Flags} ${ALIGNCOM}")

# Use separate_arguments to split options into semicolon separated list
separate_arguments(GEOS_Fortran_FLAGS_RELEASE NATIVE_COMMAND ${GEOS_Fortran_FLAGS_RELEASE})
separate_arguments(GEOS_Fortran_FLAGS_DEBUG NATIVE_COMMAND ${GEOS_Fortran_FLAGS_DEBUG})
