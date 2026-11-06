# MissingButtons -- nine tiny utility plug-ins, one CMake build.
#
# macOS (universal arm64 + x86_64, runs on macOS 10.13 and newer):
#   cmake -S . -B build-mac -G Xcode          # Xcode project for development
#   cmake --build build-mac --config Release
#   scripts/makedist-mac.sh                   # release build + signed, notarized installer
#
# Windows (x64):
#   cmake -S . -B build-win -G "Visual Studio 17 2022" -A x64
#   cmake --build build-win --config Release
#   (see installer/MissingButtons.iss)
#
# Built bundles land in <build>/out (multi-config generators: <build>/out/<Config>).
# -DIPLUG_DEPLOY_PLUGINS=ON also copies every build into the user plug-in folders.
#
# The version, IDs and names live in common/config-common.h and <Plugin>/config.h;
# the Info.plists are generated from them (cmake/MissingButtons.cmake).

cmake_minimum_required(VERSION 3.21)

set(MB_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
file(STRINGS "${MB_ROOT}/common/config-common.h" _mb_version_line REGEX "^#define PLUG_VERSION_STR ")
string(REGEX REPLACE "^.*\"([0-9.]+)\".*$" "\\1" MB_VERSION "${_mb_version_line}")

# Before project(): the compiler checks must already see these.
if(CMAKE_HOST_APPLE)
  set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "Minimum macOS version")
  set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "Build architectures")
  set(IPLUG2_UNIVERSAL ON CACHE BOOL "Build universal binaries (arm64 + x86_64)")
endif()
set(IPLUG_DEPLOY_PLUGINS OFF CACHE BOOL "Copy built plug-ins into the user plug-in folders")

project(MissingButtons VERSION ${MB_VERSION} LANGUAGES C CXX)

if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

set(IPLUG2_DIR "${MB_ROOT}/.." CACHE PATH "iPlug2 root directory")
include(${IPLUG2_DIR}/iPlug2.cmake)
find_package(iPlug2 REQUIRED)

# Smaller binaries: drop unreferenced code; in Release also the local symbols.
if(APPLE)
  add_link_options(-Wl,-dead_strip "$<$<CONFIG:Release,MinSizeRel>:-Wl,-x>")
endif()

set(MB_FORMATS AU VST3 CLAP AAX CACHE STRING "Plug-in formats to build (AU is macOS only)")
set(MB_PLUGINS Flip FlipRight Left Right Mono MidSide Side Swap SideChainer)

include(${MB_ROOT}/cmake/MissingButtons.cmake)

foreach(_p ${MB_PLUGINS})
  add_subdirectory(${_p})
endforeach()

message(STATUS "MissingButtons ${MB_VERSION}: ${MB_PLUGINS}")
message(STATUS "  formats: ${MB_FORMATS}   macOS min: ${CMAKE_OSX_DEPLOYMENT_TARGET}   archs: ${CMAKE_OSX_ARCHITECTURES}")
