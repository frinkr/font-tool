//
//  TypefaceNames.h
//  tx-research
//
//  Created by Yuqing Jiang on 5/31/17.
//
//
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_TRUETYPE_IDS_H
#include FT_SFNT_NAMES_H
#include FT_FONT_FORMATS_H
#include FT_CID_H

#import <Foundation/Foundation.h>
#import "Common.h"

FT_BEGIN_DECLS

extern NSDate *   FTDateTime(NSInteger value);
extern NSString * FTDateTimeToString(NSInteger value);
extern NSString * FTGetUnicodeString(FT_UShort platformId, FT_UShort encodingId, void * string, uint32_t stringLen);

extern NSString * FTGetPlatformName(FT_UShort platformId);
extern NSString * FTGetPlatformEncodingName(FT_UShort platformId, FT_UShort encodingId);
extern NSString * FTGetPlatformLanguageName(FT_UShort platformId, FT_UShort encodingId);

extern NSString * SFNTNameGetName(FT_SfntName * sfntName); //
extern NSString * SFNTNameGetValue(FT_SfntName * sfntName); //
extern NSString * SFNTNameGetPlatform(FT_SfntName * sfntName);
extern NSString * SFNTNameGetLanguage(FT_SfntName *sfntName, FT_Face face); // language id

extern BOOL       SFNTNameGetFromId(FT_Face face, NSUInteger nameId, FT_SfntName * sfnt);
extern NSString * SFNTNameGetValueFromId(FT_Face face, NSUInteger nameId);

extern NSString * SFNTTagName(FT_ULong tagValue);
extern FT_ULong * SFNTTagValue(NSString * tagName);

extern NSString * HeadGetFlagFullDescription(uint16_t flag);
extern NSString * HeadGetMacStyleDescription(uint16_t flag);

extern NSString * OS2GetWeightClassName(uint16_t value);
extern NSString * OS2GetWidthClassName(uint16_t value);
extern NSString * OS2GetFsTypeDescription(uint16_t value);

extern NSString * OS2GetFamilyClassName(uint16_t value);
extern NSString * OS2GetSubFamilyClassName(uint16_t value);
extern NSString * OS2GetFamilyClassFullName(uint16_t value);

extern NSString * OS2GetPanoseFamilyType(uint8_t value);
extern NSString * OS2GetPanoseSerifType(uint8_t value);
extern NSString * OS2GetPanoseWeight(uint8_t value);
extern NSString * OS2GetPanoseProportion(uint8_t value);
extern NSString * OS2GetPanoseContrast(uint8_t value);
extern NSString * OS2GetPanoseStrokeVariation(uint8_t value);
extern NSString * OS2GetPanoseArmStyle(uint8_t value);
extern NSString * OS2GetPanoseLetterform(uint8_t value);
extern NSString * OS2GetPanoseMidline(uint8_t value);
extern NSString * OS2GetPanoseXHeight(uint8_t value);

extern NSString * OS2GetFsSelectionDescription(uint16_t value);

extern NSString * OTGetScriptFullName(NSString * script);
extern NSString * OTGetLanguageFullName(NSString * language);
extern NSString * OTGetFeatureFullName(NSString * feature);

extern NSString * OTGetGSUBLookupName(NSUInteger lookupType);
extern NSString * OTGetGPOSLookupName(NSUInteger lookupType);
extern NSString * OTGetLookupFlagDescription(uint16_t flag);

extern NSString * PostGetMacintoshGlyphName(NSUInteger index);

@class UnicodeBlock;

extern NSArray<UnicodeBlock*> * OS2GetUnicodeRanges(uint32_t range1, uint32_t range2, uint32_t range3, uint32_t range4);

extern NSArray<NSString *> * OS2GetCodePageRanges(uint32_t range1, uint32_t range2);

FT_END_DECLS
