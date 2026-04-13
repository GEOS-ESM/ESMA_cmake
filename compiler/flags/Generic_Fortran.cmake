set (GEOS_Fortran_FLAGS_DEBUG       "${GEOS_Fortran_Debug_Flags} ${common_Fortran_flags} ${GEOS_Fortran_Debug_FPE_Flags} ${ALIGNCOM}")
set (GEOS_Fortran_FLAGS_RELEASE     "${GEOS_Fortran_Release_Flags} ${common_Fortran_flags} ${GEOS_Fortran_Release_FPE_Flags} ${ALIGNCOM}")
set (GEOS_Fortran_FLAGS_VECT        "${GEOS_Fortran_Vect_Flags} ${common_Fortran_flags} ${GEOS_Fortran_Vect_FPE_Flags} ${ALIGNCOM}")
set (GEOS_Fortran_FLAGS_NOVECT      "${GEOS_Fortran_NoVect_Flags} ${common_Fortran_flags} ${GEOS_Fortran_NoVect_FPE_Flags} ${ALIGNCOM}")
set (GEOS_Fortran_FLAGS_AGGRESSIVE  "${GEOS_Fortran_Aggressive_Flags} ${common_Fortran_flags} ${GEOS_Fortran_Aggressive_FPE_Flags} ${ALIGNCOM}")

set (CMAKE_Fortran_FLAGS_DEBUG      "${GEOS_Fortran_FLAGS_DEBUG}"      CACHE STRING "Debug Fortran flags"      FORCE )
set (CMAKE_Fortran_FLAGS_RELEASE    "${GEOS_Fortran_FLAGS_RELEASE}"    CACHE STRING "Release Fortran flags"    FORCE )
set (CMAKE_Fortran_FLAGS_AGGRESSIVE "${GEOS_Fortran_FLAGS_AGGRESSIVE}" CACHE STRING "Aggressive Fortran flags" FORCE )

# Coverage build type: gcov/lcov instrumentation.
# --coverage is a GCC-specific flag (shorthand for -fprofile-arcs -ftest-coverage).
# Only set the Coverage flags and linker flags when using GNU compilers; other
# compilers (Intel ifort/ifx, NAG, NVHPC) do not support --coverage and would
# produce a link error if these flags were applied.
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  set (GEOS_Fortran_FLAGS_COVERAGE "${GEOS_Fortran_Coverage_Flags} ${common_Fortran_flags} ${GEOS_Fortran_Coverage_FPE_Flags} ${ALIGNCOM}")
  set (CMAKE_Fortran_FLAGS_COVERAGE   "${GEOS_Fortran_FLAGS_COVERAGE}" CACHE STRING "Coverage Fortran flags" FORCE)
  set (CMAKE_EXE_LINKER_FLAGS_COVERAGE    "--coverage" CACHE STRING "Coverage linker flags for executables" FORCE)
  set (CMAKE_SHARED_LINKER_FLAGS_COVERAGE "--coverage" CACHE STRING "Coverage linker flags for shared libs"  FORCE)
endif()
