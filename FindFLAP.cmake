#[[ FindFLAP.cmake

    This module finds where FLAP is installed. It sets the following 
    variables:
        FLAP_INCLUDE_DIRS - FLAP's module directory
        FLAP_LIBRARIES - The full path to libFLAP.a
        
]]

find_path(FLAP_INCLUDE_DIRS
    flap.mod
    PATH_SUFFIXES "include" "modules"
)

find_library(FLAP_LIBRARIES
    libFLAP.a
    PATH_SUFFIXES "lib"
)

find_package_handle_standard_args(FLAP
    REQUIRED_VARS FLAP_INCLUDE_DIRS FLAP_LIBRARIES
)

# Make an imported target for FLAP
if(NOT TARGET FLAP)
	add_library(FLAP STATIC IMPORTED)
	set_target_properties(FLAP IMPORTED_LOCATION ${FLAP_LIBRARIES})
	target_include_directories(FLAP INTERFACE ${FLAP_INCLUDE_DIRS})
endif()