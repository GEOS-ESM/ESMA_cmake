function(append_globbed_directories VAR)
	cmake_parse_arguments(ARGS
		"" 
		""
		"PATTERNS;PATHS" 
		${ARGN}
	)
	set(MATCHED_LIST "")
	foreach(PREFIX ${ARGS_PATHS})
        foreach(PATTERN ${ARGS_PATTERNS})
            if(IS_ABSOLUTE ${PREFIX})
                file(GLOB MATCHED ${PREFIX}/${PATTERN})
            else()
                file(GLOB MATCHED ${CMAKE_BINARY_DIR}/${PREFIX}/${PATTERN})
            endif()
            foreach(MATCHED_FILE ${MATCHED})
                get_filename_component(MATCHED_DIR ${MATCHED_FILE} DIRECTORY)
                list(APPEND MATCHED_LIST ${MATCHED_DIR})
            endforeach()
		endforeach()
    endforeach()
    if("${MATCHED_LIST}")
        list(REMOVE_DUPLICATES MATCHED_LIST)
	endif()
	list(APPEND ${VAR} ${MATCHED_LIST})
	set(${VAR} ${${VAR}} PARENT_SCOPE)
endfunction()

# Add globbed directories to CMAKE_PREFIX_PATH for upcoming find_paths
append_globbed_directories(CMAKE_PREFIX_PATH
	PATTERNS
		mod/mod*/*.*.*.*.*/esmf.mod
		lib/lib*/*.*.*.*.*/libesmf.a
	PATHS
		${CMAKE_PREFIX_PATH}
)

# Find the installed ESMF files
find_path(ESMF_HEADERS_DIR
	ESMC.h
	DOC "The path to the directory containing \"ESMC.h\"."
	PATH_SUFFIXES "include"
)

find_path(ESMF_MOD_DIR
	esmf.mod
	DOC "The path to the directory containing \"esmf.mod\"."
	PATH_SUFFIXES "mod" "include"
)

set(FIND_ESMF_LIBRARY_SEARCH_NAMES "esmf;esmf_fullylinked" CACHE STRING "ESMF library names that are searched for.")
find_library(ESMF_LIBRARY
	NAMES ${FIND_ESMF_LIBRARY_SEARCH_NAMES}
	DOC "The path to the ESMF library."
	PATH_SUFFIXES "lib"
)

# Get ESMF's versions number
if(EXISTS ${ESMF_HEADERS_DIR}/ESMC_Macros.h)
	file(READ ${ESMF_HEADERS_DIR}/ESMC_Macros.h ESMC_MACROS)
	if("${ESMC_MACROS}" MATCHES "#define[ \t]+ESMF_VERSION_MAJOR[ \t]+([0-9]+)")
		set(ESMF_VERSION_MAJOR "${CMAKE_MATCH_1}")
	endif()
	if("${ESMC_MACROS}" MATCHES "#define[ \t]+ESMF_VERSION_MINOR[ \t]+([0-9]+)")
		set(ESMF_VERSION_MINOR "${CMAKE_MATCH_1}")
	endif()
	if("${ESMC_MACROS}" MATCHES "#define[ \t]+ESMF_VERSION_REVISION[ \t]+([0-9]+)")
		set(ESMF_VERSION_REVISION "${CMAKE_MATCH_1}")
	endif()
	set(ESMF_VERSION "${ESMF_VERSION_MAJOR}.${ESMF_VERSION_MINOR}.${ESMF_VERSION_REVISION}")
else()
	set(ESMF_VERSION "NOTFOUND")
endif()

# Throw an error if anything went wrong
find_package_handle_standard_args(ESMF 
	REQUIRED_VARS 
		ESMF_HEADERS_DIR 
		ESMF_MOD_DIR 
		ESMF_LIBRARY
	VERSION_VAR ESMF_VERSION
	FAIL_MESSAGE "${ESMF_ERRMSG}"
)

# Specify the other libraries that need to be linked for ESMF
find_package(NetCDF REQUIRED)
find_package(MPI REQUIRED)

set(ESMF_REQUIRED_CPP_STD_LIBRARIES "")
if (APPLE)
  execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libstdc++.dylib OUTPUT_VARIABLE stdcxx OUTPUT_STRIP_TRAILING_WHITESPACE)
  list(APPEND ESMF_REQUIRED_CPP_STD_LIBRARIES ${stdcxx})
  if (NOT "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
	execute_process (COMMAND ${CMAKE_C_COMPILER} --print-file-name=libgcc.a OUTPUT_VARIABLE libgcc OUTPUT_STRIP_TRAILING_WHITESPACE)
    list(APPEND ESMF_REQUIRED_CPP_STD_LIBRARIES ${libgcc})
  endif ()
else ()
  execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libstdc++.so OUTPUT_VARIABLE stdcxx OUTPUT_STRIP_TRAILING_WHITESPACE)
  list(APPEND ESMF_REQUIRED_CPP_STD_LIBRARIES ${stdcxx})
endif ()

set(ESMF_LIBRARIES ${ESMF_LIBRARY} ${NETCDF_LIBRARIES} MPI::MPI_Fortran MPI::MPI_CXX rt ${ESMF_REQUIRED_CPP_STD_LIBRARIES})
set(ESMF_INCLUDE_DIRS ${ESMF_HEADERS_DIR} ${ESMF_MOD_DIR})

# Make an imported target for ESMF
if(NOT TARGET ESMF)
	add_library(ESMF STATIC IMPORTED)
	set_target_properties(ESMF PROPERTIES
		IMPORTED_LOCATION ${ESMF_LIBRARY}
	)
	target_link_libraries(ESMF 
		INTERFACE 
			${NETCDF_LIBRARIES} 
			MPI::MPI_Fortran MPI::MPI_CXX rt ${ESMF_REQUIRED_CPP_STD_LIBRARIES}
	)
	target_include_directories(ESMF INTERFACE ${ESMF_INCLUDE_DIRS} ${NETCDF_INCLUDE_DIRS})
endif()
