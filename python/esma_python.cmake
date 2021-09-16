# CMake code involving Python

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/f2py2")
include (esma_find_python2_module)
include (esma_check_python2_module)
include (esma_add_f2py2_module)
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/f2py3")
include (esma_find_python3_module)
include (esma_check_python3_module)
include (esma_add_f2py3_module)

option(USE_F2PY "Turn on F2PY builds" ON)
