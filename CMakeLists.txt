cmake_minimum_required(VERSION 3.2)
project(tx-master)

option(BUILD_FREETYPE_HARFBUZZ "Enable building of Freetype and harfbuzz" ON)

if(BUILD_FREETYPE_HARFBUZZ)
  set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${CMAKE_SOURCE_DIR}/pkgconfig")
  add_subdirectory(harfbuzz-icu-freetype)
endif()

# font-tool
add_subdirectory(font-tool)
