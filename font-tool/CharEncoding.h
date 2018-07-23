//
//  CharEncoding.h
//  tx-research
//
//  Created by Yuqing Jiang on 6/9/17.
//
//

#import <Foundation/Foundation.h>
#import "Common.h"

extern NSString * UNI_CODEPOINT_REGEX;
extern NSString * UNI_CODEPOINT_LOOKUP_REGEX;
extern NSString * GLYPH_INDEX_LOOKUP_REGEX;
extern NSString * UNDEFINED_UNICODE_CODEPOINT;

FT_BEGIN_DECLS
NSString * RegexReplace(NSString * string,
                        NSString * regexStr,
                        NSString * (^handler)(NSRange range, BOOL * stop));
FT_END_DECLS

@interface CharEncoding : NSObject
// return nil if charcode outof unicode range
+(NSString*)hexForCharcode:(codepoint_t)charcode unicodeFlavor:(BOOL)unicode;

+(NSUInteger)utf8ForUnicode:(codepoint_t)unicode outUTF8:(unsigned char*)utf8;
+(NSUInteger)utf16ForUnicode:(codepoint_t)unicode outUTF16:(uint16_t*)utf16;
+(NSString*)utf8HexStringForUnicode:(codepoint_t)unicode;
+(NSString*)utf16HexStringForUnicode:(codepoint_t)unicode;

// support U+BBBBBB, u+BBBBBB \uBBBBBB, \UBBBBBB, 0XBBBBBB, 0xBBBBBB,
// 12345 in Dec or one character, return INVALID_CODE_POINT if not valid.
// Matching with UNI_CODEPOINT_LOOKUP_REGEX
+(codepoint_t)codepointOfString:(NSString*)str;
+(codepoint_t)unicodeOfString:(NSString*)str; // alias of charcodeOfString
+(NSString*)NSStringFromUnicode:(codepoint_t)unicode;

//support \g12345, matching with GLYPH_INDEX_LOOKUP_REGEX
+(NSInteger)gidOfString:(NSString*)str;


+(NSInteger)integerOfString:(NSString*)str; // 12345 only


+(NSString*)infoLinkOfUnicode:(codepoint_t)unicode;
+(NSString*)infoLinkOfUnicodeHex:(NSString*)unicodeHex;

+(NSString*)gotoLinkOfUnicode:(codepoint_t)unicode;
+(NSString*)gotoLinkOfUnicodeHex:(NSString*)unicodeHex;

// input mix of U+ notation and chars, ABCU+AFFEF.
+(NSString*)decodeUnicodeMixed:(NSString*)string;

+(NSString*)bitsStringOfNumber:(NSUInteger)value count:(NSUInteger)count;

@end


@interface UnicodeBlock : NSObject
@property codepoint_t from;
@property codepoint_t to;
@property (copy) NSString * name;

- (BOOL)isEqual:(id)other;
- (NSUInteger)hash;
- (NSString *)description;

@property (readonly, getter=codepointCount) NSUInteger codepointCount;
@property (readonly, getter=isFullRange) BOOL isFullRange;

-(id) initWithName:(NSString*)name from:(codepoint_t)from to:(codepoint_t)to;
-(BOOL)containsUnicode:(codepoint_t)unicode;
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
@property codepoint_t codepoint;
@property (strong) NSString * name;
@property (strong) UnicodeGeneralCategory * generalCategory;
@property (strong) NSString * decomposition;
@property codepoint_t simpleUppercase;
@property codepoint_t simpleLowercase;
@property codepoint_t simpleTitlecase;
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


- (UnicodeCharCoreAttributes*)coreAttributesOfChar:(codepoint_t)unicode;
- (UnicodeBlock*)blockOfChar:(codepoint_t)unicode;
- (NSString*)scriptOfChar:(codepoint_t)unicode;
- (NSString*)derivedAgeOfChar:(codepoint_t)unicode;
- (NSString*)propListOfChar:(codepoint_t)unicode;
- (BOOL)isPUA:(codepoint_t)unicode;
- (BOOL)isAssigned:(codepoint_t)unicode;
- (BOOL)isControl:(codepoint_t)unicode;
- (BOOL)isPrintable:(codepoint_t)unicode;

- (codepoint_t)codepointFromName:(NSString*)charName;

@end



@interface UnicodeData : NSObject
@end

FT_BEGIN_DECLS
NSString * ICUVersion();
NSString * ICUDataVersion();
FT_END_DECLS
