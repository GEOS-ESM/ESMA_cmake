if (CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 6.0)
  message(FATAL_ERROR "${CMAKE_Fortran_COMPILER_ID} version must be at least 6.0!")
endif()

set (FREAL8 "-r8")
set (FINT8 "-i8")
set (PP    "-fpp")
set (DUSTY "-dusty")
set (MISMATCH "-wmismatch=QSORTL,QSORTS,MPI_Recv,MPI_Send,MPI_Irecv,MPI_BCast,MPI_Allgather,MPI_Allgatherv,MPI_Allreduce,MPI_Scatterv,MPI_Gatherv,MPI_Sendrecv,MPI_File_write,MPI_File_read,MPI_File_Read_at_all,MPI_File_write_at_all,ESMF_UserCompSetInternalState,ESMF_UserCompGetInternalState")
set (DISABLE_FIELD_WIDTH_WARNING)
set (CRAY_POINTER "")
set (EXTENDED_SOURCE "-132 -w=x95" )
set (FIXED_SOURCE "-fixed")
set (SUPPRESS_UNUSED_DUMMY "-w=uda")
set (F2018 "-f2018")

if (APPLE)
  option (ESMF_HAS_ACHAR_BUG "ESMF Compatibility issue" ON)
endif ()

####################################################

# Common Fortran Flags
# --------------------
set (common_Fortran_flags "${F2018} ${MISMATCH}")
set (common_Fortran_fpe_flags "") # "${DUSTY}")
#set (common_Fortran_fpe_flags "")

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

# GEOS Aggressive
# ---------------
# Until good options can be found, make vectorize equal common flags
set (GEOS_Fortran_Aggressive_Flags ${GEOS_Fortran_Release_Flags})
set (GEOS_Fortran_Aggressive_FPE_Flags ${GEOS_Fortran_Release_FPE_Flags})

# Common variables for every compiler
include(Generic_Fortran)
