# +-----------------------------------------------------------------------------+
# |   Copyright (C) 2011-2015                                                   |
# |   Original by Marcel Loose (loose <at> astron.nl) 2011-2013                 |
# |   Modified by Chris Kerr (chris.kerr <at> mykolab.ch) 2013-2015             |
# |                                                                             |
# |   This program is free software; you can redistribute it and/or modify      |
# |   it under the terms of the GNU General Public License as published by      |
# |   the Free Software Foundation; either version 2 of the License, or         |
# |   (at your option) any later version.                                       |
# |                                                                             |
# |   This program is distributed in the hope that it will be useful,           |
# |   but WITHOUT ANY WARRANTY; without even the implied warranty of            |
# |   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             |
# |   GNU General Public License for more details.                              |
# |                                                                             |
# |   You should have received a copy of the GNU General Public License         |
# |   along with this program; if not, write to the                             |
# |   Free Software Foundation, Inc.,                                           |
# |   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 |
# +-----------------------------------------------------------------------------+

## -----------------------------------------------------------------------------
## Macro to generate a Python interface module from one or more Fortran sources
##
## Usage: add_f2py_module(<module-name> SOURCES <src1>..<srcN> DESTINATION <install-dir> ONLY <list>)
##
macro (add_f2py_module _name)

  # Parse arguments.
  set (options USE_MPI USE_OPENMP USE_NETCDF DOUBLE_PRECISION)
  set (oneValueArgs DESTINATION)
  set (multiValueArgs SOURCES ONLY LIBRARIES INCLUDEDIRS)
  cmake_parse_arguments(add_f2py_module "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  set(only_list ${add_f2py_module_ONLY})
  if (only_list)
     set(_only "only:")
     list(APPEND _only ${add_f2py_module_ONLY})
     list(APPEND _only ":")
  else ()
    set (_only "")
  endif()

  # Sanity checks.
  if(add_f2py_module_SOURCES MATCHES "^$")
    message(FATAL_ERROR "add_f2py_module: no source files specified")
  endif(add_f2py_module_SOURCES MATCHES "^$")

  # Set f2py compiler options: compiler vendor and path to Fortran77/90 compiler.

  set(F2PY_Fortran_FLAGS)

  ###########################################################################
  # # If you really want to pass in the flags used by the rest of the model #
  # # this is how. But I don't think we want to do this                     #
  # if (CMAKE_BUILD_TYPE MATCHES Release)                                   #
  #    set(F2PY_Fortran_FLAGS ${CMAKE_Fortran_FLAGS_RELEASE})               #
  # elseif(CMAKE_BUILD_TYPE MATCHES Debug)                                  #
  #    set(F2PY_Fortran_FLAGS ${CMAKE_Fortran_FLAGS_DEBUG})                 #
  # endif()                                                                 #
  # separate_arguments(F2PY_Fortran_FLAGS)                                  #
  ###########################################################################

  if (${add_f2py_module_USE_OPENMP})
     list(APPEND F2PY_Fortran_FLAGS ${OpenMP_Fortran_FLAGS})
  endif()

  if (${add_f2py_module_DOUBLE_PRECISION})
     string(REPLACE " " ";" tmp ${FREAL8})
     foreach (flag ${tmp})
        list(APPEND F2PY_Fortran_FLAGS ${tmp})
     endforeach ()
  endif()

  #message(STATUS "${_name} F2PY_Fortran_FLAGS ${F2PY_Fortran_FLAGS}")

  # NOTE: This style of calling f2py is only for distutils. If you are using
  #       Python 3.12, the backend is now meson and this will not work
  #       so we need to test the Python version and then call the correct
  #       f2py

  if (Python_VERSION VERSION_GREATER_EQUAL "3.12")
    set(F2PY_BACKEND "meson")
  else ()
    set(F2PY_BACKEND "distutils")
  endif ()

  #message(STATUS "Using F2PY_BACKEND: ${F2PY_BACKEND}")

  if (F2PY_BACKEND STREQUAL "distutils")
    set(_fcompiler_opts "--fcompiler=${F2PY_FCOMPILER}")
    list(APPEND _fcompiler_opts "--f77exec=${CMAKE_Fortran_COMPILER}" "--f77flags='${F2PY_Fortran_FLAGS}'")
    if(CMAKE_Fortran_COMPILER_SUPPORTS_F90)
      list(APPEND _fcompiler_opts "--f90exec=${CMAKE_Fortran_COMPILER}" "--f90flags='${F2PY_Fortran_FLAGS}'")
    endif(CMAKE_Fortran_COMPILER_SUPPORTS_F90)
  else ()
    set(_fcompiler_opts "")
    list(APPEND _fcompiler_opts "--f77flags='${F2PY_Fortran_FLAGS}'")
    if(CMAKE_Fortran_COMPILER_SUPPORTS_F90)
      list(APPEND _fcompiler_opts "--f90flags='${F2PY_Fortran_FLAGS}'")
    endif(CMAKE_Fortran_COMPILER_SUPPORTS_F90)
  endif ()

  # Make the source filenames absolute.
  set(_abs_srcs)
  foreach(_src ${add_f2py_module_SOURCES})
    get_filename_component(_abs_src ${_src} ABSOLUTE)
    list(APPEND _abs_srcs ${_abs_src})
  endforeach(_src ${add_f2py_module_SOURCES})

  # Let's also get all directories that the sources are in
  set(_src_inc_dirs)
  foreach(_src ${_abs_srcs})
    get_filename_component(_dir ${_src} DIRECTORY)
    list(APPEND _src_inc_dirs ${_dir})
  endforeach(_src ${_abs_srcs})

  # Get a list of the include directories.
  # The f2py --include_paths option, used when generating a signature file,
  # needs a colon-separated list. The f2py -I option, used when compiling
  # the sources, must be repeated for every include directory.
  #get_directory_property(_inc_dirs INCLUDE_DIRECTORIES)

  set(_inc_opts)
  set(_lib_opts)
  set(_inc_dirs)
  foreach(_dir ${add_f2py_module_INCLUDEDIRS})
    list(APPEND _inc_opts "-I${_dir}")
    list(APPEND _lib_opts "-L${_dir}")
    list(APPEND _inc_dirs "${_dir}")
  endforeach(_dir)
  string(REPLACE ";" ":" _inc_paths "${_inc_dirs}")

  # We also want to include the directory where the
  # sources are located as well into _inc_opts
  foreach(_dir ${_src_inc_dirs})
    list(APPEND _inc_opts "-I${_dir}")
  endforeach(_dir)

  set(_libs_opts)
  foreach(_lib ${add_f2py_module_LIBRARIES})
     # MAT This is hacky, but so is this whole code
     #     On darwin, esmf is a full path libesmf.a and
     #     not esmf_fullylinked. For now, if libesmf.a
     #     is passed down, replace with esmf
     if (_lib MATCHES "esmf\.a")
        set (_lib esmf)
     endif ()

     # For some reason, -pthread screws up f2py, but it's not defined on
     # all systems (macOS + GCC at least), so, if it is set and it's passed in, skip
     #
     # NOTE: This can't be done in one a-and-b test because CMake will not do:
     #         if( foo MATCHES )
     #       where the matches regex is blank
     if (CMAKE_THREAD_LIBS_INIT)
       if (_lib STREQUAL "${CMAKE_THREAD_LIBS_INIT}")
         continue()
       endif ()
     endif ()

     # It also seems like f2py cannot handle XCode Frameworks
     if (NOT _lib MATCHES "^.*framework$")
       list(APPEND _lib_opts "-l${_lib}")
     endif ()

     # Tests on Calculon showed that the wrong libssl (from python)
     # was being linked to This code tries to insert in the system SSL
     # path. Might not always work but it seems to
     if(NOT APPLE)
       if(_lib STREQUAL "ssl")
          find_package(OpenSSL REQUIRED)
          if(OPENSSL_FOUND)
             get_filename_component(OPENSSL_LIBRARY_DIR "${OPENSSL_SSL_LIBRARY}" DIRECTORY)
             list(APPEND _lib_opts "-L${OPENSSL_LIBRARY_DIR}")
          else()
             message(FATAL_ERROR "SSL REQUIRED for but not found")
          endif()
       endif()
     endif()

  endforeach(_lib)

  if ( ${add_f2py_module_USE_MPI})
     foreach (lib ${MPI_Fortran_LIBRARIES})
        get_filename_component(lib_dir ${lib} DIRECTORY)
        list(APPEND _lib_opts "-L${lib_dir}")

        get_filename_component(lib_name ${lib} NAME)
        string(REGEX MATCH "lib(.*)(${CMAKE_SHARED_LIBRARY_SUFFIX}|${CMAKE_STATIC_LIBRARY_SUFFIX})" BOBO ${lib_name})
        set(short_lib_name "${CMAKE_MATCH_1}")
        list(APPEND _lib_opts "-l${short_lib_name}")
     endforeach ()
  endif ()

  if ( ${add_f2py_module_USE_OPENMP})
     foreach (lib ${OpenMP_Fortran_LIBRARIES})
        get_filename_component(lib_dir ${lib} DIRECTORY)
        list(APPEND _lib_opts "-L${lib_dir}")

        get_filename_component(lib_name ${lib} NAME)
        string(REGEX MATCH "lib(.*)(${CMAKE_SHARED_LIBRARY_SUFFIX}|${CMAKE_STATIC_LIBRARY_SUFFIX})" BOBO ${lib_name})
        set(short_lib_name "${CMAKE_MATCH_1}")
        list(APPEND _lib_opts "-l${short_lib_name}")
     endforeach()
  endif ()

  if ( ${add_f2py_module_USE_NETCDF})
    if (Baselibs_FOUND)

      # include dirs
      foreach(_dir ${NETCDF_INCLUDE_DIRS})
        list(APPEND _inc_opts "-I${_dir}")
      endforeach()

      # libraries
      list(APPEND _lib_opts "-L${BASEDIR}/lib")
      foreach(_lib ${NETCDF_LIBRARIES})

        # Need to handle -pthread as we do above
        if (CMAKE_THREAD_LIBS_INIT)
          if (_lib STREQUAL "${CMAKE_THREAD_LIBS_INIT}")
            continue()
          endif ()
        endif ()
        list(APPEND _lib_opts "-l${_lib}")

      endforeach()

    else()

      foreach(_dir ${NetCDF_Fortran_INCLUDE_DIRS})
        list(APPEND _inc_opts "-I${_dir}")
      endforeach()

      list(APPEND _lib_opts "${NetCDF_Fortran_LIBRARY}")

    endif()
  endif ()

  # This is an ugly hack but the MAM optics f2py required it. The
  # fortran is compiled -r8 but python doesn't know that. Thus, you have
  # to let python know that "real" is actually "double". The way to do
  # this according to the internet is to add a dotfile with this junk in
  # it to allow for this. It's possible it's not correct, but it seem to
  # let things run
  if(${add_f2py_module_DOUBLE_PRECISION})
     file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/.f2py_f2cmap "{'real':{'':'double'},'integer':{'':'long'},'real*8':{'':'double'},'complex':{'':'complex_double'}}")
  endif()

  # Debugging f2py is a lot easier if you don't quiet it, but we do not
  # want all the f2py output when building normally as it is *very*
  # verbose. So this turns out the f2py verboseness when building for Debug
  if (NOT CMAKE_BUILD_TYPE MATCHES Debug)
    set (F2PY_QUIET "--quiet")
    # Note: Need to use a "list" like this because of CMake. If it
    #       was a single string, CMake would add a backslash between
    #       them: "&>\ /dev/null"
    set (REDIRECT_TO_DEV_NULL "&>" "/dev/null")
  endif ()

  # Define the command to generate the Fortran to Python interface module. The
  # output will be a shared library that can be imported by python.
  # We also need to set FC in the environment to the fortran compiler
  #message(STATUS "add_f2py_module_SOURCES: ${add_f2py_module_SOURCES}")
  #message(STATUS "_inc_opts: ${_inc_opts}")
  if ( F2PY_BACKEND STREQUAL "meson")
    if(IFORT_HAS_DEPRECATION_WARNING)
      set(MESON_F2PY_FCOMPILER "ifort -diag-disable=10448")
    else()
      set(MESON_F2PY_FCOMPILER "${CMAKE_Fortran_COMPILER}")
    endif()
    add_custom_command(OUTPUT "${_name}${F2PY_SUFFIX}"
      COMMAND ${CMAKE_COMMAND} -E env "FC=${MESON_F2PY_FCOMPILER}"
              ${F2PY_EXECUTABLE} ${F2PY_QUIET} -m ${_name}
              --build-dir "${CMAKE_CURRENT_BINARY_DIR}/f2py-${_name}"
              ${_fcompiler_opts} ${_inc_opts} ${_lib_opts} -c ${_abs_srcs} ${REDIRECT_TO_DEV_NULL}
      DEPENDS ${add_f2py_module_SOURCES}
      COMMENT "[F2PY] Building Fortran to Python interface module ${_name}")
  else ()
    if ( "${add_f2py_module_SOURCES}" MATCHES "^[^;]*\\.pyf;" )
      add_custom_command(OUTPUT "${_name}${F2PY_SUFFIX}"
        COMMAND ${F2PY_EXECUTABLE} ${F2PY_QUIET} -m ${_name}
                --build-dir "${CMAKE_CURRENT_BINARY_DIR}/f2py-${_name}"
                ${_fcompiler_opts} ${_inc_opts} -c ${_abs_srcs} ${REDIRECT_TO_DEV_NULL}
        DEPENDS ${add_f2py_module_SOURCES}
        COMMENT "[F2PY] Building Fortran to Python interface module ${_name}")
    else ( "${add_f2py_module_SOURCES}" MATCHES "^[^;]*\\.pyf;" )
      add_custom_command(OUTPUT "${_name}${F2PY_SUFFIX}"
        COMMAND ${F2PY_EXECUTABLE} ${F2PY_QUIET} -m ${_name} -h ${_name}.pyf
                --build-dir "${CMAKE_CURRENT_BINARY_DIR}/f2py-${_name}"
                --include-paths ${_inc_paths} --overwrite-signature ${_abs_srcs} ${REDIRECT_TO_DEV_NULL}
        COMMAND ${F2PY_EXECUTABLE} ${F2PY_QUIET} -m ${_name}
                --build-dir "${CMAKE_CURRENT_BINARY_DIR}/f2py-${_name}"
                -c "${CMAKE_CURRENT_BINARY_DIR}/f2py-${_name}/${_name}.pyf"
                ${_fcompiler_opts} ${_inc_opts} ${_lib_opts} ${_abs_srcs} ${_lib_opts} ${_only} ${REDIRECT_TO_DEV_NULL}
        DEPENDS ${add_f2py_module_SOURCES}
        COMMENT "[F2PY] Building Fortran to Python interface module ${_name}")
    endif ( "${add_f2py_module_SOURCES}" MATCHES "^[^;]*\\.pyf;" )
  endif ()



  # Add a custom target <name> to trigger the generation of the python module.
  add_custom_target(${_name} ALL DEPENDS "${_name}${F2PY_SUFFIX}")

  if(NOT (add_f2py_module_DESTINATION MATCHES "^$" OR add_f2py_module_DESTINATION MATCHES ";"))
    # Install the python module
    install(PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/${_name}${F2PY_SUFFIX}"
            DESTINATION ${add_f2py_module_DESTINATION})
  endif(NOT (add_f2py_module_DESTINATION MATCHES "^$" OR add_f2py_module_DESTINATION MATCHES ";"))


endmacro (add_f2py_module)

