cmake_minimum_required(VERSION 3.28)

project(c_template LANGUAGES C)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE
      Debug
      CACHE STRING "Choose build type" FORCE)
endif()

if(DEFINED ENV{C_STANDARD})
  set(CMAKE_C_STANDARD $ENV{C_STANDARD})
else()
  set(CMAKE_C_STANDARD 23)
endif()

set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Interface target for project-wide warning levels
add_library(project_warnings INTERFACE)
target_compile_options(
  project_warnings
  INTERFACE -Werror
            -Wall
            -Wextra
            -Wpedantic
            -Wconversion
            -Wsign-conversion
            -Wshadow
            -Wformat=2
            -Wundef
            -Wwrite-strings
            -Wcast-qual
            -Wswitch-default
            -Wswitch-enum
            -Wuninitialized
            -Wnull-dereference
            -Wimplicit-fallthrough
            -Wvla
            -Wfloat-equal
            -Wbad-function-cast
            -Wpointer-arith
            -Wredundant-decls
            -Wdouble-promotion
            -Wdate-time
            -Wmissing-prototypes
            $<$<CONFIG:Debug>:-fsanitize=address,undefined
            -fno-omit-frame-pointer
            -g>)

target_link_options(project_warnings INTERFACE
                    $<$<CONFIG:Debug>:-fsanitize=address,undefined>)

add_executable(c_app src/main.c)
target_link_libraries(c_app PRIVATE project_warnings)
