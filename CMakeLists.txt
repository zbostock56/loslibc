cmake_minimum_required(VERSION 3.15)
project(loslibc LANGUAGES C)

# ------------------------------------------------------------------------------
# Toolchain setup
# ------------------------------------------------------------------------------

# Allow user to specify a cross compiler prefix
set(CROSS_PREFIX "x86_64-elf-" CACHE STRING "Cross compiler prefix (e.g., x86_64-elf-)")

# Detect compiler if not explicitly set
if(NOT CMAKE_C_COMPILER)
    find_program(CMAKE_C_COMPILER NAMES ${CROSS_PREFIX}gcc REQUIRED)
endif()
if(NOT CMAKE_AR)
    find_program(CMAKE_AR NAMES ${CROSS_PREFIX}ar REQUIRED)
endif()
if(NOT CMAKE_RANLIB)
    find_program(CMAKE_RANLIB NAMES ${CROSS_PREFIX}ranlib REQUIRED)
endif()

# Force static library builds for try_compile (important for cross)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# ------------------------------------------------------------------------------
# Build configuration
# ------------------------------------------------------------------------------

# Default build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif()

# Options for tuning
option(LOSLIBC_USE_PIC "Build libc with -fPIC" OFF)
option(LOSLIBC_USE_LARGE_MODEL "Use -mcmodel=large instead of -mcmodel=kernel" OFF)
option(LOSLIBC_DISABLE_SIMD "Force -mgeneral-regs-only to disable SIMD" ON)

# ------------------------------------------------------------------------------
# Sources
# ------------------------------------------------------------------------------
file(GLOB_RECURSE LIBC_SOURCES src/*.c)

add_library(loslibc STATIC ${LIBC_SOURCES})
target_include_directories(loslibc PUBLIC include)

# Apply freestanding + safety flags
target_compile_options(loslibc PRIVATE
    -ffreestanding
    -fno-builtin
    -Wall
    -Wextra
    -Werror
)

# PIC / no PIC
if(LOSLIBC_USE_PIC)
    set_target_properties(loslibc PROPERTIES POSITION_INDEPENDENT_CODE ON)
else()
    set_target_properties(loslibc PROPERTIES POSITION_INDEPENDENT_CODE OFF)
endif()

# Memory model
if(LOSLIBC_USE_LARGE_MODEL)
    target_compile_options(loslibc PRIVATE -mcmodel=large)
else()
    target_compile_options(loslibc PRIVATE -mcmodel=kernel)
endif()

# SIMD
if(LOSLIBC_DISABLE_SIMD)
    target_compile_options(loslibc PRIVATE -mgeneral-regs-only)
endif()