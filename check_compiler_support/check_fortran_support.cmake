include (try_fortran_compile)

try_fortran_compile(
  ${CMAKE_CURRENT_LIST_DIR}/assumed_type.F90
  FORTRAN_COMPILER_SUPPORTS_ASSUMED_TYPE
  )
try_fortran_compile(
  ${CMAKE_CURRENT_LIST_DIR}/findloc.F90
  FORTRAN_COMPILER_SUPPORTS_FINDLOC
  )
