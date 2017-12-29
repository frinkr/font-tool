cmake_minimum_required(VERSION 3.2)
project(font-tool)

if(NOT CMAKE_GENERATOR MATCHES Xcode)
  message(FATAL_ERROR "Only Xcode generator is supported.")
endif()

option(BUILD_FREETYPE_HARFBUZZ "Enable building of Freetype and harfbuzz" OFF)

#set(CMAKE_OSX_SYSROOT macosx10.11)
#set(CMAKE_OSX_DEPLOYMENT_TARGET "10.11")

if(BUILD_FREETYPE_HARFBUZZ)
  set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${CMAKE_SOURCE_DIR}/pkgconfig")
  option(WITH_PNG "Freetype: Build with PNG" OFF)
  add_compile_options("-DFT_DEBUG_LEVEL_TRACE")
  add_subdirectory(harfbuzz-icu-freetype)
endif()

# font-tool
add_subdirectory(font-tool)
