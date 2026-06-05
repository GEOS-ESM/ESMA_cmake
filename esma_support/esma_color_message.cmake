function(color_message COLOR MSG_TYPE MSG_STRING)
  # 1. Respect the standard NO_COLOR environment variable
  if(DEFINED ENV{NO_COLOR})
    message(${MSG_TYPE} "${MSG_STRING}")
    return()
  endif()

  # 2. Pass-through for anything that isn't a STATUS message.
  # This preserves CMake's native formatting and stderr routing for errors.
  if(NOT MSG_TYPE STREQUAL "STATUS")
    message(${MSG_TYPE} "${MSG_STRING}")
    return()
  endif()

  # 3. Define the palette locally
  string(ASCII 27 ESC)
  set(RESET        "${ESC}[0m")
  set(RED          "${ESC}[31m")
  set(BOLD_RED     "${ESC}[1;31m")
  set(YELLOW       "${ESC}[33m")
  set(CYAN         "${ESC}[36m")
  set(ORANGE       "${ESC}[1;38;5;214m")
  set(LIME         "${ESC}[1;38;5;154m")
  set(ELECTRIC_BLU "${ESC}[1;38;5;45m")

  # 4. Dynamically resolve the color requested
  if(DEFINED ${COLOR})
    set(ACTIVE_COLOR "${${COLOR}}")
  else()
    set(ACTIVE_COLOR "") 
  endif()

  # 5. Print the formatted message (We hardcode STATUS here since we already checked)
  message(STATUS "${ACTIVE_COLOR}${MSG_STRING}${RESET}")
endfunction()
