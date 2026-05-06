if (CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 7.2)
  message(FATAL_ERROR "${CMAKE_Fortran_COMPILER_ID} version must be at least 7.2!")
endif()

set (FREAL8 "-r8")
set (FINT8 "-i8")
set (PP    "-fpp")
set (DUSTY "-dusty")
set (MISMATCH "-wmismatch=QSORTL,QSORTS,MPI_Recv,MPI_Send,MPI_Irecv,MPI_BCast,MPI_Gather,MPI_Allgather,MPI_Allgatherv,MPI_Allreduce,MPI_Scatter,MPI_Scatterv,MPI_Gatherv,MPI_Sendrecv,MPI_Alltoallv,MPI_File_write,MPI_File_read,MPI_File_Read_at_all,MPI_File_write_at_all,ESMF_UserCompSetInternalState,ESMF_UserCompGetInternalState")
set (DISABLE_FIELD_WIDTH_WARNING)
set (CRAY_POINTER "")
set (EXTENDED_SOURCE "-132 -w=x95" )
set (FIXED_SOURCE "-fixed")
set (SUPPRESS_UNUSED_DUMMY "-w=uda")
set (F2018 "-f2018")
# Add quiet flag
#        -quiet    Suppress the compiler banner and the summary line, so that only diagnostic messages will appear.
set (QUIET "-quiet")

if (APPLE)
  option (ESMF_HAS_ACHAR_BUG "ESMF Compatibility issue" OFF)
  # NAG Fortran doesn't understand Apple's -F framework flags
  # Tell CMake to use -I for all include directories (including frameworks) for Fortran
  set(CMAKE_INCLUDE_FLAG_Fortran "-I")
  set(CMAKE_INCLUDE_SYSTEM_FLAG_Fortran "-I")
  # Tell CMake not to add framework directories to Fortran implicit includes
  set(CMAKE_Fortran_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES "" CACHE STRING "")
endif ()

####################################################

# Common Fortran Flags
# --------------------
# On macOS, CMake may add -F framework flags that NAG doesn't understand
# We use -w=uep to suppress the specific unrecognised option error
if (APPLE)
  set (IGNORE_UNKNOWN_FLAGS "-w=uep")
else()
  set (IGNORE_UNKNOWN_FLAGS "")
endif()
set (common_Fortran_flags "${F2018} ${MISMATCH} ${QUIET} ${IGNORE_UNKNOWN_FLAGS}")
set (common_Fortran_fpe_flags "")

# GEOS Debug
# ----------
set (GEOS_Fortran_Debug_Flags "-O0 -g -C=all") # -C=undefined")
set (GEOS_Fortran_Debug_FPE_Flags "${common_Fortran_fpe_flags}")

# GEOS Release
# ------------
set (GEOS_Fortran_Release_Flags "-O3 -g")
set (GEOS_Fortran_Release_FPE_Flags "${common_Fortran_fpe_flags}")

# Create a NoVectorize version for consistency. No difference from Release for NAG

# GEOS NoVectorize
# ----------------
set (GEOS_Fortran_NoVect_Flags  "${GEOS_Fortran_Release_Flags}")
set (GEOS_Fortran_NoVect_FPE_Flags "${GEOS_Fortran_Release_FPE_Flags}")

# GEOS Vectorize
# --------------
# Until good options can be found, make vectorize equal common flags
set (GEOS_Fortran_Vect_Flags ${GEOS_Fortran_Release_Flags})
set (GEOS_Fortran_Vect_FPE_Flags ${GEOS_Fortran_Release_FPE_Flags})

# GEOS VectTrap
# --------------
# Until good options can be found, make vecttrap equal common flags
set (GEOS_Fortran_VectTrap_Flags ${GEOS_Fortran_Release_Flags})
set (GEOS_Fortran_VectTrap_FPE_Flags ${GEOS_Fortran_Release_FPE_Flags})

# GEOS Aggressive
# ---------------
# Until good options can be found, make vectorize equal common flags
set (GEOS_Fortran_Aggressive_Flags ${GEOS_Fortran_Release_Flags})
set (GEOS_Fortran_Aggressive_FPE_Flags ${GEOS_Fortran_Release_FPE_Flags})

# Common variables for every compiler
include(Generic_Fortran)
