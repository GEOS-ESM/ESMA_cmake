function(file_glob_directories VAR)
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
	set(${VAR} ${MATCHED_LIST} PARENT_SCOPE)
endfunction()


find_path(ESMF_HEADERS_DIR
	ESMC.h
	HINTS 
		$ENV{ESMF_ROOT}
		$ENV{ESMF_ROOT}/DEFAULTINSTALLDIR
	DOC "The path to the directory containing \"ESMC.h\"."
	PATH_SUFFIXES "include"
)

file_glob_directories(GLOBBED_MODDIRS
	PATTERNS
		mod/mod*/*.*.*.*.*/esmf.mod
	PATHS
		${CMAKE_PREFIX_PATH}
		$ENV{ESMF_ROOT}
		$ENV{ESMF_ROOT}/DEFAULTINSTALLDIR
)
find_path(ESMF_MOD_DIR
	esmf.mod
	HINTS
		${GLOBBED_MODDIRS}
		$ENV{ESMF_ROOT}
		$ENV{ESMF_ROOT}/DEFAULTINSTALLDIR
	DOC "The path to the directory containing \"esmf.mod\"."
	PATH_SUFFIXES 
		"mod"
		"include"
)

file_glob_directories(GLOBBED_MODDIRS
	PATTERNS
		lib/lib*/*.*.*.*.*/libesmf.a
	PATHS
		${CMAKE_PREFIX_PATH}
		$ENV{ESMF_ROOT}
		$ENV{ESMF_ROOT}/DEFAULTINSTALLDIR
)
find_library(ESMF_LIBRARY
	libesmf.a
	HINTS
		${GLOBBED_MODDIRS}
		$ENV{ESMF_ROOT}
		$ENV{ESMF_ROOT}/DEFAULTINSTALLDIR
	DOC "The path to the directory containing \"libesmf.a\"."
	PATH_SUFFIXES
		"lib"
)

set(ESMF_ERRMSG "\nCounldn't find one or more of ESMF's files! The following files/directories weren't found:")
if(NOT ESMF_HEADERS_DIR)
	set(ESMF_ERRMSG "${ESMF_ERRMSG}
    ESMF_HEADERS_DIR:  Directory with ESMF's \".h\" files   (e.g. \"ESMC.h\")")
endif()
if(NOT ESMF_MOD_DIR)
	set(ESMF_ERRMSG "${ESMF_ERRMSG}
    ESMF_MOD_DIR:      Directory with ESMF's \".mod\" files (e.g. \"esmf.mod\")")
endif()
if(NOT ESMF_LIBRARY)
	set(ESMF_ERRMSG "${ESMF_ERRMSG}
    ESMF_LIBRARY:    Path to \"libesmf.a\"")
endif()
set(ESMF_ERRMSG "${ESMF_ERRMSG}\nFind the directories/files that are listed above. Specify the directories you want CMake to search with the CMAKE_PREFIX_PATH variable (or the ESMF_ROOT environment variable).\n")

if(EXISTS ${ESMF_HEADERS_DIR}/ESMC_Macros.h)
	file(READ ${ESMF_HEADERS_DIR}/ESMC_Macros.h ESMC_MACROS)
	if("${ESMC_MACROS}" MATCHES "#define[ \t\r\n]+ESMF_VERSION_MAJOR[ \t\r\n]+([0-9]+)")
		set(ESMF_VERSION_MAJOR "${CMAKE_MATCH_1}")
	endif()
	if("${ESMC_MACROS}" MATCHES "#define[ \t\r\n]+ESMF_VERSION_MINOR[ \t\r\n]+([0-9]+)")
		set(ESMF_VERSION_MINOR "${CMAKE_MATCH_1}")
	endif()
	if("${ESMC_MACROS}" MATCHES "#define[ \t\r\n]+ESMF_VERSION_REVISION[ \t\r\n]+([0-9]+)")
		set(ESMF_VERSION_REVISION "${CMAKE_MATCH_1}")
	endif()
	set(ESMF_VERSION "${ESMF_VERSION_MAJOR}.${ESMF_VERSION_MINOR}.${ESMF_VERSION_REVISION}")
else()
	set(ESMF_VERSION "NOTFOUND")
endif()

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
execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libstdc++.so OUTPUT_VARIABLE stdcxx OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process (COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=libgcc.a OUTPUT_VARIABLE libgcc OUTPUT_STRIP_TRAILING_WHITESPACE)

set(ESMF_LIBRARIES ${ESMF_LIBRARY} ${NETCDF_LIBRARIES} ${MPI_Fortran_LIBRARIES} ${MPI_CXX_LIBRARIES} rt ${stdcxx} ${libgcc})
