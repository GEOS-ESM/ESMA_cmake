# FindISSM.cmake
# Find the ISSM (Ice Sheet System Model) libraries
#
# This module defines:
#  ISSM_FOUND - True if ISSM libraries are found
#  ISSM_INCLUDE_DIRS - Include directories for ISSM (if available)
#  ISSM_LIBRARIES - List of ISSM libraries to link against
#  ISSM_LIBRARY_DIRS - Directories containing ISSM libraries
#  ISSM_<component>_FOUND - True if specific component is found
#
# Individual library targets (if found):
#  ISSM::Core - ISSMCore library
#  ISSM::Modules - ISSMModules library
#  ISSM::Overload - ISSMOverload library
#
# Usage:
#  find_package(ISSM REQUIRED)                        # Find all components (prefer shared)
#  find_package(ISSM REQUIRED COMPONENTS Core)        # Find only Core (prefer shared)
#  find_package(ISSM REQUIRED COMPONENTS Core STATIC) # Find only Core (static only)
#  find_package(ISSM REQUIRED COMPONENTS Core SHARED) # Find only Core (shared only)
#
# You can set these variables to help guide the search:
#  ISSM_ROOT_DIR - Root directory of ISSM installation
#  ISSM_LIBRARY_DIR - Directory containing ISSM libraries
#  ISSM_INCLUDE_DIR - Directory containing ISSM headers (optional)

# Define available components
set(ISSM_KNOWN_COMPONENTS Core Modules Overload)

# Parse library type preference from components
set(ISSM_LIBRARY_TYPE "")
set(ISSM_ACTUAL_COMPONENTS)

# Check if STATIC or SHARED was specified in COMPONENTS
if("STATIC" IN_LIST ISSM_FIND_COMPONENTS)
    set(ISSM_LIBRARY_TYPE "STATIC")
    list(REMOVE_ITEM ISSM_FIND_COMPONENTS "STATIC")
elseif("SHARED" IN_LIST ISSM_FIND_COMPONENTS)
    set(ISSM_LIBRARY_TYPE "SHARED")
    list(REMOVE_ITEM ISSM_FIND_COMPONENTS "SHARED")
endif()

# Default behavior: prefer shared libraries
if(NOT ISSM_LIBRARY_TYPE)
    set(ISSM_LIBRARY_TYPE "PREFER_SHARED")
endif()

set(ISSM_ACTUAL_COMPONENTS ${ISSM_FIND_COMPONENTS})

# If no components specified, find all
if(NOT ISSM_ACTUAL_COMPONENTS)
    set(ISSM_ACTUAL_COMPONENTS ${ISSM_KNOWN_COMPONENTS})
endif()

# Find the library directory
find_path(ISSM_LIBRARY_DIR
    NAMES libISSMCore.so libISSMCore.a
    HINTS
        ${ISSM_ROOT_DIR}/lib
        ${ISSM_LIBRARY_DIR}
        ENV ISSM_ROOT_DIR
    PATH_SUFFIXES
        lib
        lib64
    DOC "Directory containing ISSM libraries"
)

# Find the include directory (optional - only if headers exist)
find_path(ISSM_INCLUDE_DIR
    NAMES issm.h ISSM.h ISSMCore.h # Adjust these header names as needed
    HINTS
        ${ISSM_ROOT_DIR}/include
        ${ISSM_ROOT_DIR}/src
        ${ISSM_INCLUDE_DIR}
        ENV ISSM_ROOT_DIR
    PATH_SUFFIXES
        include
        src
        headers
    DOC "Directory containing ISSM headers (optional)"
)

# Set up include directories (only if found)
if(ISSM_INCLUDE_DIR)
    set(ISSM_INCLUDE_DIRS ${ISSM_INCLUDE_DIR})
else()
    set(ISSM_INCLUDE_DIRS)
endif()

set(ISSM_LIBRARY_DIRS ${ISSM_LIBRARY_DIR})

# Helper function to find library with type preference
function(_issm_find_library var_name lib_name)
    unset(${var_name} CACHE)

    if(ISSM_LIBRARY_TYPE STREQUAL "STATIC")
        # Force static library search
        set(_lib_path "${ISSM_LIBRARY_DIR}/lib${lib_name}.a")
        if(EXISTS "${_lib_path}")
            set(${var_name} "${_lib_path}" CACHE FILEPATH "ISSM ${lib_name} static library" FORCE)
        endif()

    elseif(ISSM_LIBRARY_TYPE STREQUAL "SHARED")
        # Force shared library search
        set(_lib_path "${ISSM_LIBRARY_DIR}/lib${lib_name}.so")
        if(EXISTS "${_lib_path}")
            set(${var_name} "${_lib_path}" CACHE FILEPATH "ISSM ${lib_name} shared library" FORCE)
        endif()

    else()
        # Default: use find_library (prefers shared)
        find_library(${var_name}
            NAMES ${lib_name}
            HINTS ${ISSM_LIBRARY_DIR}
        )
    endif()

    # Propagate to parent scope
    set(${var_name} ${${var_name}} PARENT_SCOPE)
endfunction()

# Find individual libraries based on requested components
set(ISSM_LIBRARIES)
set(_ISSM_REQUIRED_VARS ISSM_LIBRARY_DIR)

foreach(component IN LISTS ISSM_ACTUAL_COMPONENTS)
    if(component STREQUAL "Core")
        _issm_find_library(ISSM_CORE_LIBRARY ISSMCore)

        if(ISSM_CORE_LIBRARY)
            list(APPEND ISSM_LIBRARIES ${ISSM_CORE_LIBRARY})
            set(ISSM_Core_FOUND TRUE)
        else()
            set(ISSM_Core_FOUND FALSE)
        endif()

        if(ISSM_FIND_REQUIRED_Core OR (ISSM_FIND_REQUIRED AND "Core" IN_LIST ISSM_ACTUAL_COMPONENTS))
            list(APPEND _ISSM_REQUIRED_VARS ISSM_CORE_LIBRARY)
        endif()

    elseif(component STREQUAL "Modules")
        _issm_find_library(ISSM_MODULES_LIBRARY ISSMModules)

        if(ISSM_MODULES_LIBRARY)
            list(APPEND ISSM_LIBRARIES ${ISSM_MODULES_LIBRARY})
            set(ISSM_Modules_FOUND TRUE)
        else()
            set(ISSM_Modules_FOUND FALSE)
        endif()

        if(ISSM_FIND_REQUIRED_Modules OR (ISSM_FIND_REQUIRED AND "Modules" IN_LIST ISSM_ACTUAL_COMPONENTS))
            list(APPEND _ISSM_REQUIRED_VARS ISSM_MODULES_LIBRARY)
        endif()

    elseif(component STREQUAL "Overload")
        _issm_find_library(ISSM_OVERLOAD_LIBRARY ISSMOverload)

        if(ISSM_OVERLOAD_LIBRARY)
            list(APPEND ISSM_LIBRARIES ${ISSM_OVERLOAD_LIBRARY})
            set(ISSM_Overload_FOUND TRUE)
        else()
            set(ISSM_Overload_FOUND FALSE)
        endif()

        if(ISSM_FIND_REQUIRED_Overload OR (ISSM_FIND_REQUIRED AND "Overload" IN_LIST ISSM_ACTUAL_COMPONENTS))
            list(APPEND _ISSM_REQUIRED_VARS ISSM_OVERLOAD_LIBRARY)
        endif()

    else()
        message(WARNING "Unknown ISSM component: ${component}")
    endif()
endforeach()

# Handle standard arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ISSM
    FOUND_VAR ISSM_FOUND
    REQUIRED_VARS ${_ISSM_REQUIRED_VARS}
    HANDLE_COMPONENTS
)

# Helper function to determine library type for imported target
function(_issm_get_library_type lib_path out_var)
    if(lib_path MATCHES "\\.(a|lib)$")
        set(${out_var} "STATIC" PARENT_SCOPE)
    elseif(lib_path MATCHES "\\.(so|dylib|dll)$")
        set(${out_var} "SHARED" PARENT_SCOPE)
    else()
        set(${out_var} "UNKNOWN" PARENT_SCOPE)
    endif()
endfunction()

# Create imported targets if found
if(ISSM_FOUND)
    # Core library
    if(ISSM_CORE_LIBRARY AND NOT TARGET ISSM::Core)
        _issm_get_library_type(${ISSM_CORE_LIBRARY} _core_type)
        add_library(ISSM::Core ${_core_type} IMPORTED)
        set_target_properties(ISSM::Core PROPERTIES
            IMPORTED_LOCATION "${ISSM_CORE_LIBRARY}"
        )
        if(ISSM_INCLUDE_DIRS)
            set_target_properties(ISSM::Core PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${ISSM_INCLUDE_DIRS}"
            )
        endif()
    endif()

    # Modules library
    if(ISSM_MODULES_LIBRARY AND NOT TARGET ISSM::Modules)
        _issm_get_library_type(${ISSM_MODULES_LIBRARY} _modules_type)
        add_library(ISSM::Modules ${_modules_type} IMPORTED)
        set_target_properties(ISSM::Modules PROPERTIES
            IMPORTED_LOCATION "${ISSM_MODULES_LIBRARY}"
        )
        if(ISSM_INCLUDE_DIRS)
            set_target_properties(ISSM::Modules PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${ISSM_INCLUDE_DIRS}"
            )
        endif()
    endif()

    # Overload library
    if(ISSM_OVERLOAD_LIBRARY AND NOT TARGET ISSM::Overload)
        _issm_get_library_type(${ISSM_OVERLOAD_LIBRARY} _overload_type)
        add_library(ISSM::Overload ${_overload_type} IMPORTED)
        set_target_properties(ISSM::Overload PROPERTIES
            IMPORTED_LOCATION "${ISSM_OVERLOAD_LIBRARY}"
        )
        if(ISSM_INCLUDE_DIRS)
            set_target_properties(ISSM::Overload PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${ISSM_INCLUDE_DIRS}"
            )
        endif()
    endif()

    # Create a convenience target that includes all found libraries
    if(ISSM_LIBRARIES AND NOT TARGET ISSM::ISSM)
        add_library(ISSM::ISSM INTERFACE IMPORTED)

        # Build the list of targets to link
        set(_issm_targets)
        if(TARGET ISSM::Core)
            list(APPEND _issm_targets ISSM::Core)
        endif()
        if(TARGET ISSM::Modules)
            list(APPEND _issm_targets ISSM::Modules)
        endif()
        if(TARGET ISSM::Overload)
            list(APPEND _issm_targets ISSM::Overload)
        endif()

        if(_issm_targets)
            set_target_properties(ISSM::ISSM PROPERTIES
                INTERFACE_LINK_LIBRARIES "${_issm_targets}"
            )
            if(ISSM_INCLUDE_DIRS)
                set_target_properties(ISSM::ISSM PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES "${ISSM_INCLUDE_DIRS}"
                )
            endif()
        endif()
    endif()
endif()

# Mark variables as advanced
mark_as_advanced(
    ISSM_INCLUDE_DIR
    ISSM_LIBRARY_DIR
    ISSM_CORE_LIBRARY
    ISSM_MODULES_LIBRARY
    ISSM_OVERLOAD_LIBRARY
)
