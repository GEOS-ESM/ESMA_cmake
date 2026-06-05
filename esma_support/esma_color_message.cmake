function(color_message COLOR MSG_TYPE MSG_STRING)
  # 1. Respect the standard NO_COLOR environment variable
  if(DEFINED ENV{NO_COLOR})
    message(${MSG_TYPE} "${MSG_STRING}")
    return()
  endif()

  # 2. Pass-through for non-STATUS messages
  if(NOT MSG_TYPE STREQUAL "STATUS")
    message(${MSG_TYPE} "${MSG_STRING}")
    return()
  endif()

  # 3. Define the full palette locally
  string(ASCII 27 ESC)
  set(RESET "${ESC}[0m")

  # Standard Colors
  set(RED     "${ESC}[31m")
  set(GREEN   "${ESC}[32m")
  set(YELLOW  "${ESC}[33m")
  set(BLUE    "${ESC}[34m")
  set(MAGENTA "${ESC}[35m")
  set(CYAN    "${ESC}[36m")
  set(WHITE   "${ESC}[37m")

  # Bold Standard Colors
  set(BOLD_RED     "${ESC}[1;31m")
  set(BOLD_GREEN   "${ESC}[1;32m")
  set(BOLD_YELLOW  "${ESC}[1;33m")
  set(BOLD_BLUE    "${ESC}[1;34m")
  set(BOLD_MAGENTA "${ESC}[1;35m")
  set(BOLD_CYAN    "${ESC}[1;36m")
  set(BOLD_WHITE   "${ESC}[1;37m")

  # Extended 256-Color Palette
  set(ORANGE       "${ESC}[1;38;5;214m")
  set(HOT_PINK     "${ESC}[1;38;5;198m")
  set(LIME         "${ESC}[1;38;5;154m")
  set(ELECTRIC_BLU "${ESC}[1;38;5;45m")
  set(LAVENDER     "${ESC}[1;38;5;147m")

  # 4. Define the list of explicitly supported colors
  set(SUPPORTED_COLORS
    RED GREEN YELLOW BLUE MAGENTA CYAN WHITE
    BOLD_RED BOLD_GREEN BOLD_YELLOW BOLD_BLUE BOLD_MAGENTA BOLD_CYAN BOLD_WHITE
    ORANGE HOT_PINK LIME ELECTRIC_BLU LAVENDER
  )

  # 5. Validate the requested color
  list(FIND SUPPORTED_COLORS "${COLOR}" COLOR_INDEX)

  if(COLOR_INDEX EQUAL -1)
    # The color is not in our list. Warn the developer and fallback to no color.
    message(AUTHOR_WARNING "color_message: Invalid color requested ('${COLOR}'). Supported colors are: ${SUPPORTED_COLORS}")
    set(ACTIVE_COLOR "")
  else()
    # The color is valid. Dynamically resolve its escape code.
    set(ACTIVE_COLOR "${${COLOR}}")
  endif()

  # 6. Print the formatted message
  message(STATUS "${ACTIVE_COLOR}${MSG_STRING}${RESET}")
endfunction()
