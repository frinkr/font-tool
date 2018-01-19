cmake_minimum_required(VERSION 3.2)
set(PROJECT_NAME font-tool)
project(${PROJECT_NAME})

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_compile_options("-Wno-nullability-completeness")

option(BUILD_FREETYPE_HARFBUZZ "Enable building of Freetype and harfbuzz" ON)
set(APP_VERSION "1.0.0" CACHE STRING "The version of the application")
set(APP_NAME "Font Tool")

find_package(PkgConfig)
set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:/usr/local/opt/icu4c/lib/pkgconfig")

if(BUILD_FREETYPE_HARFBUZZ)
  
  add_definitions(-DHAVE_HARFBUZZ_SOURCE=1)
  pkg_check_modules(PC_HBFT REQUIRED harfbuzz-icu-freetype)
  include_directories(AFTER ${PC_HBFT_INCLUDE_DIRS})
  list(APPEND THIRD_PARTY_LIBS ${PC_HBFT_LIBRARIES})
  
else()
  
  # Freeetype
  pkg_check_modules(FREETYPE REQUIRED freetype2)
  include_directories(${FREETYPE_INCLUDE_DIRS})
  list(APPEND THIRD_PARTY_LIBS ${FREETYPE_LDFLAGS})

  # Harfbuzz
  pkg_check_modules(HARFBUZZ REQUIRED harfbuzz)
  include_directories(${HARFBUZZ_INCLUDE_DIRS})
  list(APPEND THIRD_PARTY_LIBS ${HARFBUZZ_LDFLAGS}) 

  # icu
  pkg_check_modules(ICU REQUIRED icu-uc)
  include_directories(${ICU_INCLUDE_DIRS})
  list(APPEND THIRD_PARTY_LIBS ${ICU_LDFLAGS})

endif()

# Lua
pkg_check_modules(LUA REQUIRED lua)
include_directories(${LUA_INCLUDE_DIRS})
list(APPEND THIRD_PARTY_LIBS ${LUA_LDFLAGS})

include_directories(${CMAKE_SOURCE_DIR}/LuaBridge/Source)

file(GLOB HEADER_FILES "*.h")

set(SOURCE_FILES
  main.m
  AppDelegate.m
  CharEncoding.mm
  Common.m
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
  TypefaceCMap.mm
  TypefaceManager.m
  TypefaceNames.m
  TypefaceDocument.m
  TypefaceDocumentController.m
  TypefaceInfoViewController.m
  TypefaceWindowController.m
  TypefaceStylesWindowController.m
  TypefaceSelectorWindowController.m
  TypefaceVariationViewController.m
  ToolBox.m
  LuaScript.mm
  )

if(BUILD_FREETYPE_HARFBUZZ)
  # same compiler defines for HarfbuzzEx.cpp to avoid crashing
  set_property(SOURCE HarfbuzzEx.cpp APPEND_STRING PROPERTY COMPILE_FLAGS "-DHAVE_OT -DHAVE_UCDN -DHB_NO_MT")
  list(APPEND SOURCE_FILES HarfbuzzEx.cpp)
endif()

set(LEXYACC_FILES
  TypefaceListFilter.lm
  TypefaceListFilter.ym
  )

set(NIB_FILES
  Main.storyboard
  TypefaceSelectorWindow.storyboard
  TypefaceStylesWindow.storyboard
  TypefaceInfoWindow.storyboard
  TypefaceVariation.storyboard
  ShapingWindow.storyboard
  GlyphTableWindow.storyboard
  ToolBox.storyboard
  GlyphCollectionViewItem.xib
  GlyphCollectionViewHeader.xib
  TBColorConstantsViewItem.xib
  StandardCollectionViewItem.xib
)

set(RESOURCE_FILES
  Resources/Assets.xcassets
  Resources/AppIcon.icns
  Resources/DevLinks.plist
  Resources/UNIDATA)


add_executable(
    ${PROJECT_NAME}
    MACOSX_BUNDLE
    ${HEADER_FILES}
    ${SOURCE_FILES}
    ${NIB_FILES}
    ${RESOURCE_FILES}
)

target_link_libraries(${PROJECT_NAME}
  ${THIRD_PARTY_LIBS}
  )

set_target_properties(
    ${PROJECT_NAME}
    PROPERTIES
    MACOSX_BUNDLE YES

    # bundle config
    MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_LIST_DIR}/plist.in
    MACOSX_BUNDLE_ICON_FILE "AppIcon"
    MACOSX_BUNDLE_BUNDLE_VERSION ${APP_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${APP_VERSION}
    MACOSX_BUNDLE_LONG_VERSION_STRING ${APP_VERSION}
    MACOSX_BUNDLE_COPYRIGHT "Copyright © 2017 Yuqing Jiang. All rights reserved."
    
    XCODE_ATTRIBUTE_PRODUCT_NAME   ${APP_NAME}
    XCODE_ATTRIBUTE_BUNDLE_IDENTIFIER   "me.frinkr.fonttool"
    XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
    XCODE_ATTRIBUTE_INSTALL_PATH "${CMAKE_BINARY_DIR}/ProductRelease"
    XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
    XCODE_ATTRIBUTE_COMBINE_HIDPI_IMAGES "NO"

    XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET "10.11"
    
    RESOURCE "${NIB_FILES};${RESOURCE_FILES}"    
)

target_link_libraries(${PROJECT_NAME}
    "-framework Cocoa"
    "-framework AppKit"
    "-framework CoreData"
    "-framework QuartzCore"
    "-framework Foundation"
    "-framework Webkit"
)

if(NOT BUILD_FREETYPE_HARFBUZZ)
ADD_CUSTOM_COMMAND(TARGET ${PROJECT_NAME}
  POST_BUILD
  COMMAND /bin/bash ${CMAKE_CURRENT_SOURCE_DIR}/CopyLibs.sh "${CMAKE_CURRENT_BINARY_DIR}/\${CONFIGURATION}/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
  )
endif()
