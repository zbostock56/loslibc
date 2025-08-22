# x86_64-elf GCC cross toolchain for freestanding builds
# Usage:
# cmake -S . -B build \
# -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/x86_64-elf-gcc.cmake \
# -DCROSS_PREFIX=x86_64-elf-

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Encourage CMake to avoid running test executables on host
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# ----- Tool discovery -----
if(NOT DEFINED CROSS_PREFIX)
set(CROSS_PREFIX "x86_64-elf-")
endif()

# Allow CC/AR/RANLIB env overrides; else fall back to CROSS_PREFIX
if(NOT CMAKE_C_COMPILER)
if(DEFINED ENV{CC})
set(CMAKE_C_COMPILER $ENV{CC})
else()
set(CMAKE_C_COMPILER "${CROSS_PREFIX}gcc")
endif()
endif()

if(NOT CMAKE_AR)
if(DEFINED ENV{AR})
set(CMAKE_AR $ENV{AR})
else()
set(CMAKE_AR "${CROSS_PREFIX}ar")
endif()
endif()

if(NOT CMAKE_RANLIB)
if(DEFINED ENV{RANLIB})
set(CMAKE_RANLIB $ENV{RANLIB})
else()
set(CMAKE_RANLIB "${CROSS_PREFIX}ranlib")
endif()
endif()

# Don’t search host system paths for includes/libraries
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
