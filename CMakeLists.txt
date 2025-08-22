cmake_minimum_required(VERSION 3.16)
project(loslibc C)

# ==========================================
# Options
# ==========================================
option(LOSLIBC_BUILD_STATIC "Build loslibc as a static library" ON)
option(LOSLIBC_WARNINGS_AS_ERRORS "Treat warnings as errors" OFF)
option(LOSLIBC_STRICT_FREESTANDING "Add freestanding/no-host flags" ON)

# Allow toolchain prefix to be specified (e.g., x86_64-elf-)
set(CROSS_PREFIX "" CACHE STRING "Cross compiler prefix (e.g., x86_64-elf-)")

# ==========================================
# Source Collection
# ==========================================
file(GLOB_RECURSE LOSLIBC_SOURCES CONFIGURE_DEPENDS
    src/*.c
)

# Error checking to make sure files exist in src/
if(LOSLIBC_SOURCES STREQUAL "")
    message(FATAL_ERROR "No sources found under src/.")
endif()

# ==========================================
# Library Target
# ==========================================
if(LOSLIBC_BUILD_STATIC)
    add_library(loslibc STATIC ${LOSLIBC_SOURCES})
else()
    add_library(loslibc SHARED ${LOSLIBC_SOURCES})
endif()

# Export public headers to consumers and for install
target_include_directories(loslibc PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

# Produce libc.a as output name to match expectations when linking the OS
set_target_properties(loslibc PROPERTIES
    OUTPUT_NAME "c"
    POSITION_INDEPENDENT_CODE ON
)

# ==========================================
# Compile/Link Flags for Freestanding Libc
# ==========================================
set(_freestanding_cflags
    -ffreestanding
    -fno-builtin
    -fno-stack-protector
)

if(LOSLIBC_STRICT_FREESTANDING)
    target_compile_options(loslibc PRIVATE ${_freestanding_cflags})
endif()

set(_general_cflags
    -pipe
    -m64
    -march=x86-64
    -mgeneral-regs-only
    -mcmodel=large
)

target_compile_options(loslibc PRIVATE ${_general_cflags})

if(LOSLIBC_WARNINGS_AS_ERRORS)
    if (CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
        target_compile_options(loslibc PRIVATE -Wall -Wextra -Werror)
    endif()
endif()

# ==========================================
# Default optimization/debug flags
# ==========================================
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING
        "Build type (Debug, Release, RelWithDebInfo, MinSizeRel)" FORCE)
endif()

if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    set(CMAKE_C_FLAGS_DEBUG          "-O0 -g" CACHE STRING "" FORCE)
    set(CMAKE_C_FLAGS_RELEASE        "-O2 -DNDEBUG" CACHE STRING "" FORCE)
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g" CACHE STRING "" FORCE)
    set(CMAKE_C_FLAGS_MINSIZEREL     "-Os -DNDEBUG" CACHE STRING "" FORCE)
endif()

# ==========================================
# Sanity Check: ensure we’re using the cross compiler (x86_64-elf)
# ==========================================
execute_process(
    COMMAND ${CMAKE_C_COMPILER} -dumpmachine
    OUTPUT_VARIABLE _dumpmachine
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)

if(_dumpmachine)
    string(FIND "${_dumpmachine}" "x86_64-elf" _idx)
    if(_idx EQUAL -1)
        message(WARNING "Compiler target (${_dumpmachine}) does not look like x86_64-elf.\n"
                        "If you are building for LearnOS, configure with: \n"
                        "  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_CURRENT_SOURCE_DIR}/cmake/toolchains/x86_64-elf-gcc.cmake\n"
                        "and ensure CROSS_PREFIX=x86_64-elf- is on PATH.")
    endif()
endif()

# ==========================================
# Install Rules
# ==========================================
include(GNUInstallDirs)

install(TARGETS loslibc
    EXPORT loslibcTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(EXPORT loslibcTargets
    NAMESPACE los::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/loslibc
)

include(CMakePackageConfigHelpers)
set(LOSLIBC_CONFIG_DEST ${CMAKE_INSTALL_LIBDIR}/cmake/loslibc)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/loslibc-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/loslibc-config.cmake
    INSTALL_DESTINATION ${LOSLIBC_CONFIG_DEST}
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/loslibc-config.cmake
        DESTINATION ${LOSLIBC_CONFIG_DEST})

