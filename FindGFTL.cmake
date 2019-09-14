#[[ FindGFTL.cmake

    This module finds where gFTL is installed. It sets the following 
    variables:
        GFTL_INCLUDE_DIRS - gFTL's include directory
        
]]

find_path(GFTL_INCLUDE_DIRS
    types/key_deferredLengthString.inc
    PATH_SUFFIXES "include"
)

find_package_handle_standard_args(GFTL
    REQUIRED_VARS GFTL_INCLUDE_DIRS
)

# Make an imported target for GFTL
if(NOT TARGET gftl)
	add_library(gftl INTERFACE)
    target_include_directories(gftl INTERFACE ${GFTL_INCLUDE_DIRS})
    install(TARGETS gftl EXPORT MAPL-targets)
endif()