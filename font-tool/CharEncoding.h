//
//  CharEncoding.h
//  tx-research
//
//  Created by Yuqing Jiang on 6/9/17.
//
//

#import <Foundation/Foundation.h>


#define INVALID_CODE_POINT (0x110000)

extern NSString * UNI_CODEPOINT_REGEX;
extern NSString * UNI_CODEPOINT_LOOKUP_REGEX;
extern NSString * GLYPH_INDEX_LOOKUP_REGEX;
extern NSString * UNDEFINED_UNICODE_CODEPOINT;

@interface CharEncoding : NSObject
// return nil if charcode outof unicode range
+(NSString*)hexForCharcode:(NSUInteger)charcode unicodeFlavor:(BOOL)unicode;

+(NSArray<NSNumber*>*)utf8ForUnicode:(NSUInteger)unicode;
+(NSArray<NSNumber*>*)utf16ForUnicode:(NSUInteger)unicode;
+(NSString*)utf8HexStringForUnicode:(NSUInteger)unicode;
+(NSString*)utf16HexStringForUnicode:(NSUInteger)unicode;

// support U+BBBBBB, u+BBBBBB \uBBBBBB, \UBBBBBB, 0XBBBBBB, 0xBBBBBB,
// 12345 in Dec or one character, return INVALID_CODE_POINT if not valid.
// Matching with UNI_CODEPOINT_LOOKUP_REGEX
+(NSUInteger)charcodeOfString:(NSString*)str;
+(NSUInteger)unicodeOfString:(NSString*)str; // alias of charcodeOfString

//support \g12345, matching with GLYPH_INDEX_LOOKUP_REGEX
+(NSInteger)gidOfString:(NSString*)str;


+(NSInteger)integerOfString:(NSString*)str; // 12345 only


+(NSString*)infoLinkOfUnicode:(NSUInteger)unicode;
+(NSString*)infoLinkOfUnicodeHex:(NSString*)unicodeHex;

// input mix of U+ notation and chars, ABCU+AFFEF.
+(NSString*)decodeUnicodeMixed:(NSString*)string;
@end


@interface UnicodeBlock : NSObject
@property NSUInteger from;
@property NSUInteger to;
@property (copy) NSString * name;

- (BOOL)isEqual:(id)other;
- (NSUInteger)hash;
- (NSString *)description;

@property (readonly, getter=codepointCount) NSUInteger codepointCount;
@property (readonly, getter=isFullRange) BOOL isFullRange;

-(id) initWithName:(NSString*)name from:(NSUInteger)from to:(NSUInteger)to;
-(BOOL)containsUnicode:(uint32_t)unicode;
@end

typedef UnicodeBlock UnicodeScriptBlock;
typedef UnicodeBlock UnicodeDerivedAgeBlock;
typedef UnicodeBlock UnicodePropListBlock;

@interface UnicodeGeneralCategory : NSObject
@property (strong) NSString* abbreviation;
@property (strong) NSString* fullDescription;

+ (UnicodeGeneralCategory*)categoryByAbbreviation:(NSString*)abbr;
@end


@interface UnicodeCharCoreAttributes : NSObject
@property uint32_t codepoint;
@property (strong) NSString * name;
@property (strong) UnicodeGeneralCategory * generalCategory;
@property (strong) NSString * decomposition;
@property NSUInteger simpleUppercase;
@property NSUInteger simpleLowercase;
@property NSUInteger simpleTitlecase;
@end


// http://www.unicode.org/Public/UNIDATA/
@interface UnicodeDatabase : NSObject
@property (readonly, strong) NSString * rootDirectory;
@property (readonly, strong) NSArray<UnicodeBlock*>* unicodeBlocks;
@property (readonly, strong) NSArray<UnicodeScriptBlock*> * scriptBlocks;
@property (readonly, strong) NSArray<UnicodeDerivedAgeBlock*> * derivedAgeBlocks;
@property (readonly, strong) NSArray<UnicodePropListBlock*> * propListBlocks;

@property (readonly, strong) NSDictionary<NSNumber*, UnicodeCharCoreAttributes*>* coreAttributesDictionary;

- (instancetype)initWithRootDirectory:(NSString*)rootDirectory;
+ (instancetype)standardDatabase;

- (UnicodeBlock*)unicodeBlockWithName:(NSString*)blockName;


- (UnicodeCharCoreAttributes*)coreAttributesOfChar:(uint32_t)unicode;
- (UnicodeBlock*)blockOfChar:(uint32_t)unicode;
- (NSString*)scriptOfChar:(uint32_t)unicode;
- (NSString*)derivedAgeOfChar:(uint32_t)unicode;
- (NSString*)propListOfChar:(uint32_t)unicode;
- (BOOL)isPUA:(uint32_t)unicode;

- (uint32_t)codepointFromName:(NSString*)charName;

@end



@interface UnicodeData : NSObject
@end
