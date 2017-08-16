cmake_minimum_required(VERSION 3.2.2)
project(tx-research)

set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${CMAKE_SOURCE_DIR}/pkgconfig")

set(HB_HAVE_FREETYPE ON CACHE BOOL "Enable building of Freetype")
set(HB_HAVE_ICU ON CACHE BOOL "Enable building of ICU")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#add_subdirectory(font-demo)
add_subdirectory(freetype)
#add_subdirectory(SDL2)
add_subdirectory(harfbuzz)
#add_subdirectory(fontconfig-2.12.3)
add_subdirectory(font-tool)
