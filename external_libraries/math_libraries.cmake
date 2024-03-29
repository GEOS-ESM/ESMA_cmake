# Detection of MKL, BLAS, LAPACK, ...

if (APPLE)
    set (MKL_Fortran True)
endif ()
find_package(MKL)
if (MKL_FOUND)
   ecbuild_info("Found MKL:")
   ecbuild_info("  MKL_INCLUDE_DIRS: ${MKL_INCLUDE_DIRS}")
   ecbuild_info("  MKL_LIBRARIES: ${MKL_LIBRARIES}")

   set(BLA_VENDOR Intel10_64lp_seq)
endif ()

find_package(LAPACK)
if (LAPACK_FOUND)
   ecbuild_info("Found LAPACK:")
   ecbuild_info("  LAPACK_LINKER_FLAGS: ${LAPACK_LINKER_FLAGS}")
   ecbuild_info("  LAPACK_LIBRARIES: ${LAPACK_LIBRARIES}")
   if (LAPACK95_FOUND)
      ecbuild_info("Found LAPACK95:")
      ecbuild_info("  LAPACK95_LIBRARIES: ${LAPACK95_LIBRARIES}")
   endif ()
endif ()

find_package(BLAS)
if (BLAS_FOUND)
   ecbuild_info("Found BLAS:")
   ecbuild_info("  BLAS_LINKER_FLAGS: ${BLAS_LINKER_FLAGS}")
   ecbuild_info("  BLAS_LIBRARIES: ${BLAS_LIBRARIES}")
   if (BLAS95_FOUND)
      ecbuild_info("Found BLAS95:")
      ecbuild_info("  BLAS95_LIBRARIES: ${BLAS95_LIBRARIES}")
   endif ()
endif ()
