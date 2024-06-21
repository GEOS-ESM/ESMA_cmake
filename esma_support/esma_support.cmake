# CMake code that supports ESMA

include (esma_check_if_debug)
include (esma_set_this)
include (esma_add_subdirectories)
include (esma_mepo_style)
include (esma_add_library)
include (esma_generate_automatic_code)
include (esma_create_stub_component)
include (esma_fortran_generator_list)
include (esma_add_fortran_submodules)

# Testing
include (esma_enable_tests)
