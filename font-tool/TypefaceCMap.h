#import <Cocoa/Cocoa.h>

#define ALL_GLYPHS_BLOCK_INDEX 0

@interface TypefaceGlyphcode : NSObject
@property NSUInteger charcode;
@property NSUInteger GID;
@property BOOL       isGID;  // image loaded by charcode or glyphIndex

+(instancetype)glyphCodeWithGID:(NSUInteger)gid;
+(instancetype)glyphCodeWithCharcode:(NSUInteger)charcode;
@end

@interface TypefaceGlyphBlock : NSObject
- (NSString *) name;
- (NSUInteger) numOfGlyphs;
- (TypefaceGlyphcode*)glyphCodeAtIndex:(NSUInteger)index;
@end


@interface TypefaceGlyphRangeBlock : TypefaceGlyphBlock
@property NSUInteger from;
@property NSUInteger to;
@property (strong) NSString * blockName;
@property BOOL isGID;

- (id)initWithFrom: (NSUInteger) from to:(NSUInteger)to isGID:(BOOL)isGID name:(NSString*)name;
@end


@interface TypefaceCMap : NSObject
@property NSUInteger platformId;
@property NSUInteger encodingId;
@property NSUInteger numOfGlyphs;
@property (readonly, strong) NSString * name;
@property (readonly, getter=glyphBlocks) NSArray<TypefaceGlyphBlock*> * glyphBlocks;

- (id)initWithPlatformId:(NSUInteger)platform encodingId:(NSUInteger)encoding numOfGlyphs:(NSUInteger)nrGlyphs;

- (BOOL)isUnicode;
@end
