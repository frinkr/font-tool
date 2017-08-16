cmake_minimum_required(VERSION 2.6)
set(APP_NAME font-tool)
project(font-tool)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-nullability-completeness")

set(HARFBUZZ_BUILD_ICU ON CACHE BOOL "Enable building of ICU")
set(HARFBUZZ_BUILD_UCDN OFF CACHE BOOL "Enable building of UCDN")


include_directories(${CMAKE_SOURCE_DIR}/freetype/include)
include_directories(${CMAKE_SOURCE_DIR}/harfbuzz/src)
include_directories(${PROJECT_BINARY_DIR}/../harfbuzz/src)
include_directories(${CMAKE_SOURCE_DIR})

# icu
find_package(PkgConfig)
pkg_check_modules(PC_ICU QUIET icu-uc)
find_path(ICU_INCLUDE_DIR NAMES unicode/utypes.h HINTS ${PC_ICU_INCLUDE_DIRS} ${PC_ICU_INCLUDEDIR})
find_library(ICU_LIBRARY NAMES libicuuc cygicuuc cygicuuc32 icuuc HINTS ${PC_ICU_LIBRARY_DIRS} ${PC_ICU_LIBDIR})
include_directories(${ICU_INCLUDE_DIR})


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
  freetype
  harfbuzz
  ${ICU_LIBRARY}
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
