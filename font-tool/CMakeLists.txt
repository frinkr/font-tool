cmake_minimum_required(VERSION 3.2)
set(APP_NAME font-tool)
project(font-tool)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-nullability-completeness")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-nullability-completeness")

option(BUILD_FREETYPE_HARFBUZZ "Enable building of Freetype and harfbuzz" ON)

if(BUILD_FREETYPE_HARFBUZZ)
  add_definitions(-DHAVE_HARFBUZZ_SOURCE=1 -DHAVE_OT -DHAVE_UCDN -DHB_NO_MT)
  find_package(PkgConfig)
  pkg_check_modules(PC_HBFT REQUIRED harfbuzz-icu-freetype)
  include_directories(AFTER ${PC_HBFT_INCLUDE_DIRS})
  list(APPEND THIRD_PARTY_LIBS ${PC_HBFT_LIBRARIES})
  
else()
  
  # Freeetype
  find_package(PkgConfig)
  pkg_check_modules(PC_FREETYPE2 QUIET freetype2)
  find_path(FREETYPE2_HEADER_DIR NAMES freetype.h HINTS ${PC_FREETYPE2_INCLUDE_DIRS} ${PC_FREETYPE2_INCLUDEDIR} $ENV{FREETYPE_DIR}/include PATH_SUFFIXES freetype)
  find_path(FREETYPE2_ROOT_INCLUDE_DIR NAMES freetype/freetype.h HINTS ${PC_FREETYPE2_INCLUDE_DIRS} ${PC_FREETYPE2_INCLUDEDIR} $ENV{FREETYPE_DIR}/include)
  if (CMAKE_BUILD_TYPE MATCHES Debug)
    set(FREETYPE2_LIBRARY_NAME freetyped)
  else ()
    set(FREETYPE2_LIBRARY_NAME freetype)
  endif ()
  find_library(FREETYPE2_LIBRARIES ${FREETYPE2_LIBRARY_NAME} HINTS ${PC_FREETYPE2_LIBDIR} ${PC_FREETYPE2_LIBRARY_DIRS} $ENV{FREETYPE_DIR}/lib)
  include_directories(AFTER ${FREETYPE2_HEADER_DIR} ${FREETYPE2_ROOT_INCLUDE_DIR})
  list(APPEND THIRD_PARTY_LIBS ${FREETYPE2_LIBRARIES})

  # Harfbuzz
  find_package(PkgConfig)  
  pkg_check_modules(PC_HARFBUZZ QUIET harfbuzz)
  find_path(HARFBUZZ_INCLUDE_DIR NAMES hb.h HINTS ${PC_HARFBUZZ_INCLUDE_DIRS} ${PC_HARFBUZZ_INCLUDEDIR})
  find_library(HARFBUZZ_LIBRARY NAMES harfbuzz HINTS ${PC_HARFBUZZ_LIBRARY_DIRS} ${PC_HARFBUZZ_LIBDIR})
  include_directories(${HARFBUZZ_INCLUDE_DIR})
  list(APPEND THIRD_PARTY_LIBS ${HARFBUZZ_LIBRARY}) 

  # icu
  find_package(PkgConfig)
  pkg_check_modules(PC_ICU QUIET icu-uc)
  find_path(ICU_INCLUDE_DIR NAMES unicode/utypes.h HINTS ${PC_ICU_INCLUDE_DIRS} ${PC_ICU_INCLUDEDIR})
  find_library(ICU_LIBRARY NAMES libicuuc cygicuuc cygicuuc32 icuuc HINTS ${PC_ICU_LIBRARY_DIRS} ${PC_ICU_LIBDIR})
  include_directories(${ICU_INCLUDE_DIR})
  list(APPEND THIRD_PARTY_LIBS ${ICU_LIBRARY})

endif()

file(GLOB HEADER_FILES "*.h")

set(SOURCE_FILES
  main.m
  AppDelegate.m
  CharEncoding.mm
  HtmlTableView.m
  GlyphImageView.m
  GlyphLookupWindowController.m
  GlyphCollectionViewController.m
  GlyphCollectionViewItem.m
  GlyphInfoViewController.m
  GlyphTableWindowController.m
  ShapingWindowController.m
  Shapper.mm
  Typeface.mm
  TypefaceManager.m
  TypefaceNames.m
  TypefaceDocument.m
  TypefaceDocumentController.m
  TypefaceInfoViewController.m
  TypefaceWindowController.m
  TypefaceStylesWindowController.m
  TypefaceListWindowController.m
  ToolBox.m
  )

if(BUILD_FREETYPE_HARFBUZZ)
  list(APPEND SOURCE_FILES HarfbuzzEx.cpp)
endif()

set(LEXYACC_FILES
  TypefaceListFilter.lm
  TypefaceListFilter.ym
  )

set(NIB_FILES
  Main.storyboard
  TypefaceListWindow.storyboard
  TypefaceStylesWindow.storyboard
  TypefaceInfoWindow.storyboard
  ShapingWindow.storyboard
  GlyphTableWindow.storyboard
  ToolBox.storyboard
  GlyphCollectionViewItem.xib
  TBColorConstantsViewItem.xib
  StandardCollectionViewItem.xib
)

set(RESOURCE_FILES
  Resources/Assets.xcassets
  Resources/AppIcon.icns
  Resources/DevLinks.plist
  Resources/UNIDATA)


add_executable(
    ${APP_NAME}
    MACOSX_BUNDLE
    ${HEADER_FILES}
    ${SOURCE_FILES}
    ${NIB_FILES}
    ${RESOURCE_FILES}
)

target_link_libraries(${APP_NAME}
  ${THIRD_PARTY_LIBS}
  )

set_target_properties(
    ${APP_NAME}
    PROPERTIES
    MACOSX_BUNDLE YES

    # bundle config
    MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_LIST_DIR}/plist.in
    MACOSX_BUNDLE_ICON_FILE "AppIcon"
    MACOSX_BUNDLE_BUNDLE_VERSION "1.2.0"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "1.2.0"
    MACOSX_BUNDLE_LONG_VERSION_STRING "1.2.0"
    MACOSX_BUNDLE_COPYRIGHT "Copyright © 2017 Yuqing Jiang. All rights reserved."
    
    XCODE_ATTRIBUTE_PRODUCT_NAME   "Font Tool"
    XCODE_ATTRIBUTE_BUNDLE_IDENTIFIER   "me.frinkr.fonttool"

    XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
    
    XCODE_ATTRIBUTE_INSTALL_PATH "${CMAKE_BINARY_DIR}/ProductRelease"

    XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
    XCODE_ATTRIBUTE_COMBINE_HIDPI_IMAGES "NO"
    RESOURCE "${NIB_FILES};${RESOURCE_FILES}"    
)

target_link_libraries(${APP_NAME}
    "-framework Cocoa"
    "-framework AppKit"
    "-framework CoreData"
    "-framework QuartzCore"
    "-framework Foundation"
    "-framework Webkit"
)
