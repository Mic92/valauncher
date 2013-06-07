find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.12.0" MINIMUM)
include (ValaPrecompile)

vala_precompile (VALA_C
  history.vala
  completion.vala
  main.vala
PACKAGES
  gtk+-3.0
  gee-0.8
OPTIONS
--thread
)

find_package (PkgConfig)
pkg_check_modules (DEPS REQUIRED gtk+-3.0 gee-0.8 gthread-2.0)
set (CFLAGS ${DEPS_CFLAGS}
  ${DEPS_CFLAGS_OTHER})
set (LIB_PATHS ${DEPS_LIBRARY_DIRS})
link_directories (${LIB_PATHS})
add_definitions (${CFLAGS})

add_executable (valauncher ${VALA_C})

target_link_libraries (valauncher ${DEPS_LIBRARIES})

install (TARGETS valauncher
  RUNTIME DESTINATION bin)
