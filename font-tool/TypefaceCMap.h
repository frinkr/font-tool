#import <Cocoa/Cocoa.h>
#import "Common.h"

#define FULL_GLYPH_LIST_BLOCK_INDEX 0
#define UNICODE_COMPACT_REPERTOIRE 1
#define UNICODE_FULL_REPERTOIRE 2

@interface TypefaceGlyphcode : NSObject
@property NSUInteger charcode;
@property NSUInteger GID;
@property BOOL       isGID;  // image loaded by charcode or glyphIndex

+(instancetype)glyphCodeWithGID:(NSUInteger)gid;
+(instancetype)glyphCodeWithCharcode:(NSUInteger)charcode;
@end

@interface TypefaceGlyphSection : NSObject
- (NSString *) name;
- (NSUInteger) numOfGlyphs;
- (TypefaceGlyphcode*)glyphCodeAtIndex:(NSUInteger)index;
- (BOOL)containsCode:(NSUInteger)code outIndex:(NSUInteger*)outIndex;
@end


@interface TypefaceGlyphRangeSection : TypefaceGlyphSection
@property NSUInteger from;
@property NSUInteger to;
@property (strong) NSString * blockName;
@property BOOL isGID;

- (id)initWithFrom: (NSUInteger) from to:(NSUInteger)to isGID:(BOOL)isGID name:(NSString*)name;
- (BOOL)containsCode:(NSUInteger)code outIndex:(NSUInteger*)outIndex;
@end

@interface TypefaceGlyphArraySection : TypefaceGlyphSection
@property (strong) NSArray<NSNumber*> * glyphs;
@property (strong) NSString * blockName;
@property BOOL isGID;
- (instancetype)initWithGlyphs:(NSArray<NSNumber*>*)glyphs isGID:(BOOL)isGID name:(NSString*)name;
- (BOOL)containsCode:(NSUInteger)code outIndex:(NSUInteger*)outIndex;
@end

@interface TypefaceGlyphBlock: NSObject
@property NSString * name;
@property NSArray<TypefaceGlyphSection*> * sections;
- (instancetype)initWithName:(NSString*)name sections:(NSArray<TypefaceGlyphSection*> *)sections;
@end

@interface TypefaceCMap : NSObject
@property (readonly) NSUInteger index;
@property (readonly) NSUInteger platformId;
@property (readonly) NSUInteger encodingId;
@property (readonly) NSUInteger numOfGlyphs;
@property (readonly, strong) NSString * name;
@property (readonly, getter=blocks) NSArray<TypefaceGlyphBlock*> * blocks;

- (instancetype)initWithFace:(OpaqueFTFace)ftFace cmapIndex:(NSUInteger)index;

- (BOOL)isUnicode;

@end
