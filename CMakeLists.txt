cmake_minimum_required(VERSION 3.2)
project(tx-master)

option(BUILD_FREETYPE_HARFBUZZ "Enable building of Freetype and harfbuzz" OFF)

if (BUILD_FREETYPE_HARFBUZZ) 
  set(FONT_TOOL_BUILD_FREETYPE ON CACHE BOOL "Enable building of freetype")
  set(FONT_TOOL_BUILD_HARFBUZZ ON CACHE BOOL "Enable building of harfbuzz")
else()
  set(FONT_TOOL_BUILD_FREETYPE OFF CACHE BOOL "Enable building of freetype")
  set(FONT_TOOL_BUILD_HARFBUZZ OFF CACHE BOOL "Enable building of harfbuzz")
endif()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# freetype
if(FONT_TOOL_BUILD_FREETYPE)
  add_subdirectory(freetype)
endif()

# harfbuzz
if(FONT_TOOL_BUILD_HARFBUZZ)
  set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${CMAKE_SOURCE_DIR}/pkgconfig")
  set(HB_HAVE_FREETYPE ON CACHE BOOL "Enable building of Freetype")
  set(HB_HAVE_ICU ON CACHE BOOL "Enable building of ICU")
  add_subdirectory(harfbuzz)
endif()

# font-tool
add_subdirectory(font-tool)
