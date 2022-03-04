# CMake code involving LaTeX

find_package(ImageMagick)
if (NOT ImageMagick_FOUND)
   message(STATUS "NOTE: ImageMagick was not found. This will prevent using LaTeX and some postprocessing utilities from running, but does not affect the build")
endif ()

find_package(LATEX)
# These are all the bits of LaTeX that UseLATEX needs. As it's confusing
# how LATEX_FOUND from find_package(LATEX) is set, we test all the bits
# that UseLATEX requires
#
# Also, UseLATEX assumes ImageMagick is installed. While this is always
# nice (and technically required to generate plots with GEOS plotting 
# utilities, it's not necessary to *build*
if (LATEX_FOUND AND LATEX_PDFLATEX_FOUND AND LATEX_BIBTEX_FOUND AND LATEX_MAKEINDEX_FOUND AND ImageMagick_FOUND)
   # If they are all found, set LATEX_FOUND to TRUE...
   set (LATEX_FOUND TRUE)

   # ...and then set up for protex and UseLATEX
   include (UseProTeX)
   set (protex_flags -g -b -f)

   set (LATEX_COMPILER pdflatex)
   include (UseLATEX)
else ()
   set (LATEX_FOUND FALSE)
endif ()
