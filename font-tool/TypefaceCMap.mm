#import "TypefaceCMap.h"
#import "TypefaceNames.h"
#import "CharEncoding.h"

#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_CID_H
#include FT_SFNT_NAMES_H
#include FT_TRUETYPE_IDS_H
#include FT_TRUETYPE_TABLES_H
#include FT_SIZES_H

#pragma mark ##### TypefaceGlyph #####
@implementation TypefaceGlyphcode

+(instancetype)glyphCodeWithGID:(NSUInteger)gid {
    TypefaceGlyphcode * gc = [[TypefaceGlyphcode alloc] init];
    gc.GID = gid;
    gc.isGID = YES;
    return gc;
}

+(instancetype)glyphCodeWithCharcode:(NSUInteger)charcode {
    TypefaceGlyphcode * gc = [[TypefaceGlyphcode alloc] init];
    gc.charcode = charcode;
    gc.isGID = NO;
    return gc;
}

@end


@interface TypefaceGlyphBlock ()
@property NSMutableArray<TypefaceGlyphcode*> * internalGlyphCodes;
@end

@implementation TypefaceGlyphBlock

- (id)init {
    if (self = [super init]) {
        self.internalGlyphCodes = [[NSMutableArray<TypefaceGlyphcode*> alloc] init];
    }
    return self;
}

- (TypefaceGlyphcode*)glyphCodeAtIndex:(NSUInteger)index {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (NSUInteger)numOfGlyphs {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return 0;
}

- (NSString*)name {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return 0;
}

@end


@implementation TypefaceGlyphRangeBlock

- (id)initWithFrom: (NSUInteger) from to:(NSUInteger)to isGID:(BOOL)isGID name:(NSString*)name {
    if (self = [super init]) {
        self.from = from;
        self.to = to;
        self.isGID = isGID;
        self.blockName = name;
    }
    return self;
}

- (NSString*)name {
    return self.blockName;
}

- (NSUInteger)numOfGlyphs {
    return self.to - self.from + 1;
}

-(TypefaceGlyphcode*)glyphCodeAtIndex:(NSUInteger)index {
    TypefaceGlyphcode * gc = [[TypefaceGlyphcode alloc] init];
    NSUInteger code = self.from + index;
    if (self.isGID)
        gc.GID = code;
    else
        gc.charcode = code;
    gc.isGID = self.isGID;
    return gc;
}


@end



#pragma mark  ###### TypefaceCMap ######

@interface TypefaceCMapPlatform : NSObject {
    NSMutableArray<TypefaceGlyphBlock*> * _unicodeBlocks;
    NSMutableDictionary<NSNumber*, NSArray<TypefaceGlyphBlock*>* > *_encodingBlocksCache;
}
@property (readonly) NSUInteger platformId;
@property (readonly, strong) NSString * platformName;

- (id) initWithPlatformId:(NSUInteger)platformId;
- (NSString*)cmapNameOfEncoding:(NSUInteger)encoding;
- (NSArray<TypefaceGlyphBlock*>*) glyphBlocksOfEncoding:(NSUInteger)encoding;

+ (TypefaceCMapPlatform*)platformById:(NSUInteger)platformId;
+ (NSString*)cmapNameOfPlatform:(NSUInteger)platformId encodong:(NSUInteger)encodingId;

@end

@interface TypefaceCMap () {
    NSMutableArray<TypefaceGlyphBlock*> * _blocks;
}
@end

static NSMutableArray<TypefaceCMapPlatform*> * _allCMapPlatforms;
@implementation TypefaceCMapPlatform
- (id)initWithPlatformId:(NSUInteger)platformId {
    if (self = [super init]) {
        _encodingBlocksCache = [[NSMutableDictionary<NSNumber*, NSArray<TypefaceGlyphBlock*>* > alloc] init];
        _platformId = platformId;
    }
    return self;
}

- (NSString*)cmapNameOfEncoding:(NSUInteger)encoding {
    return FTGetPlatformEncodingName(self.platformId, encoding);
}

#pragma mark **** GlyphBlock ****
- (NSArray<TypefaceGlyphBlock*>*)glyphBlocksOfEncoding:(NSUInteger)encoding {
    NSArray<TypefaceGlyphBlock*>* blocks = [_encodingBlocksCache objectForKey:[NSNumber numberWithUnsignedInteger:encoding]];
    if (blocks)
        return blocks;
    
    switch(_platformId) {
        case TT_PLATFORM_APPLE_UNICODE: blocks = [self loadUnicodeGlyphBlocksOfEncoding:encoding]; break;
        case TT_PLATFORM_MACINTOSH: blocks = [self loadMacintoshGlyphBlocksOfEncoding:encoding]; break;
        case TT_PLATFORM_ISO: blocks =  [self loadISOGlyphBlocksOfEncoding:encoding]; break;
        case TT_PLATFORM_MICROSOFT: blocks =  [self loadMicrosoftGlyphBlocksOfEncoding:encoding]; break;
        case TT_PLATFORM_ADOBE: blocks =  [self loadAdobeGlyphBlocksOfEncoding:encoding]; break;
        default:
            blocks = nil;
    }
    if (!blocks) {
        NSLog(@"Encoding blocks for cmap %@ not found!", [self cmapNameOfEncoding:encoding]);
        blocks = [[NSArray<TypefaceGlyphBlock*> alloc] init];
    }
    [_encodingBlocksCache setObject:blocks forKey:[NSNumber numberWithUnsignedInteger:encoding]];
    return blocks;
}
- (NSArray<TypefaceGlyphBlock*>*) loadUnicodeGlyphBlocksOfEncoding:(NSUInteger)encoding {
    return [self loadUnicodeBlocksOfVersion:nil];
}

- (NSArray<TypefaceGlyphBlock*>*) loadMacintoshGlyphBlocksOfEncoding:(NSUInteger)encoding {
    switch(encoding) {
        case TT_MAC_ID_ROMAN:
            return @[ [[TypefaceGlyphRangeBlock alloc] initWithFrom:0 to:255 isGID:NO name:@"Mac Roman"] ];
        default: return nil;
    }
}

- (NSArray<TypefaceGlyphBlock*>*) loadMicrosoftGlyphBlocksOfEncoding:(NSUInteger)encoding {
    switch(encoding) {
        case TT_MS_ID_UNICODE_CS:
        case TT_MS_ID_UCS_4:
            return [self loadUnicodeGlyphBlocksOfEncoding:encoding];
        case TT_MS_ID_SYMBOL_CS:
            return @[ [[TypefaceGlyphRangeBlock alloc] initWithFrom:0xF020 to:0xF0FF isGID:NO name:@"Windows Symbol"] ];
        default:
            return nil;
    }
    
    return nil;
}

- (NSArray<TypefaceGlyphBlock*>*) loadISOGlyphBlocksOfEncoding:(NSUInteger)encoding {
    return nil;
}

- (NSArray<TypefaceGlyphBlock*>*) loadAdobeGlyphBlocksOfEncoding:(NSUInteger)encoding {
    switch(encoding) {
        case TT_ADOBE_ID_STANDARD:
            // https://www.compart.com/en/unicode/charsets/Adobe-Standard-Encoding
            return @[ [[TypefaceGlyphRangeBlock alloc] initWithFrom:0 to:255 isGID:NO name:@"Standard"] ];
        case TT_ADOBE_ID_EXPERT:
            return @[ [[TypefaceGlyphRangeBlock alloc] initWithFrom:0 to:255 isGID:NO name:@"Expert"] ];
        case TT_ADOBE_ID_CUSTOM:
            return @[ [[TypefaceGlyphRangeBlock alloc] initWithFrom:0 to:255 isGID:NO name:@"Custom"] ];
        case TT_ADOBE_ID_LATIN_1:
            return @[ [[TypefaceGlyphRangeBlock alloc] initWithFrom:0 to:255 isGID:NO name:@"Latin 1"] ];
        default:
            return nil;
    }
    return nil;
}


- (BOOL) isUnicodeEncoding:(NSUInteger)encoding {
    if (_platformId == TT_PLATFORM_APPLE_UNICODE)
        return YES;
    
    if (_platformId == TT_PLATFORM_MICROSOFT)
        return encoding == TT_MS_ID_UNICODE_CS || encoding == TT_MS_ID_UCS_4;
    
    return NO;
    
};

- (NSArray<TypefaceGlyphBlock*>*)loadUnicodeBlocksOfVersion:(NSString*)version {
    if (_unicodeBlocks)
        return _unicodeBlocks;
    
    _unicodeBlocks= [[NSMutableArray<TypefaceGlyphBlock*> alloc] init];
    
    NSArray<UnicodeBlock*> * uniBlocks = [UnicodeDatabase standardDatabase].unicodeBlocks;
    for (UnicodeBlock * block in uniBlocks) {
        TypefaceGlyphRangeBlock * b = [[TypefaceGlyphRangeBlock alloc] initWithFrom:block.from
                                                                                 to:block.to
                                                                              isGID:NO
                                                                               name:block.name];
        [_unicodeBlocks addObject:b];
    }
    
    return _unicodeBlocks;
}

+ (TypefaceCMapPlatform*)platformById:(NSUInteger)platformId {
    if (!_allCMapPlatforms) {
        _allCMapPlatforms = [[NSMutableArray<TypefaceCMapPlatform*> alloc] init];
        [_allCMapPlatforms addObject:[[TypefaceCMapPlatform alloc] initWithPlatformId:-1]]; // invalid platform
        [_allCMapPlatforms addObject:[[TypefaceCMapPlatform alloc] initWithPlatformId:TT_PLATFORM_APPLE_UNICODE]];
        [_allCMapPlatforms addObject:[[TypefaceCMapPlatform alloc] initWithPlatformId:TT_PLATFORM_MACINTOSH]];
        [_allCMapPlatforms addObject:[[TypefaceCMapPlatform alloc] initWithPlatformId:TT_PLATFORM_ISO]];
        [_allCMapPlatforms addObject:[[TypefaceCMapPlatform alloc] initWithPlatformId:TT_PLATFORM_MICROSOFT]];
        [_allCMapPlatforms addObject:[[TypefaceCMapPlatform alloc] initWithPlatformId:TT_PLATFORM_ADOBE]];
    }
    for (TypefaceCMapPlatform * p in _allCMapPlatforms) {
        if (p.platformId == platformId)
            return p;
    }
    return [TypefaceCMapPlatform platformById: -1];
}

+ (NSString*)cmapNameOfPlatform:(NSUInteger)platformId encodong:(NSUInteger)encodingId {
    return [[TypefaceCMapPlatform platformById:platformId] cmapNameOfEncoding:encodingId];
}

@end


@implementation TypefaceCMap

- (id)initWithPlatformId:(NSUInteger)platform encodingId:(NSUInteger)encoding numOfGlyphs:(NSUInteger)nrGlyphs{
    if (self = [super init]) {
        _platformId = platform;
        _encodingId = encoding;
        _numOfGlyphs = nrGlyphs;
        _name = [TypefaceCMapPlatform cmapNameOfPlatform:_platformId encodong:_encodingId];
        
    }
    return self;
}

- (NSArray<TypefaceGlyphBlock*> *)glyphBlocks {
    if (!_blocks)
        _blocks = [self loadGlyphBlocks];
    return _blocks;
}

- (NSMutableArray<TypefaceGlyphBlock*> *)loadGlyphBlocks {
    
    TypefaceCMapPlatform * cmapPlatform = [TypefaceCMapPlatform platformById:_platformId];
    
    NSMutableArray<TypefaceGlyphBlock*> * blocks = [[NSMutableArray<TypefaceGlyphBlock*> alloc] init];
    [blocks addObjectsFromArray:[cmapPlatform glyphBlocksOfEncoding:_encodingId]];
    [blocks insertObject:[self allGlyphsBlock] atIndex:ALL_GLYPHS_BLOCK_INDEX];
    
    return blocks;
}


- (TypefaceGlyphRangeBlock*) allGlyphsBlock {
    TypefaceGlyphRangeBlock * b = [[TypefaceGlyphRangeBlock alloc] initWithFrom:0
                                                                             to:self.numOfGlyphs
                                                                          isGID:YES
                                                                           name:@"All Glyphs"];
    return b;
}

- (BOOL)isUnicode {
    return _platformId == TT_PLATFORM_APPLE_UNICODE
    || (_platformId == TT_PLATFORM_MICROSOFT && ( _encodingId == TT_MS_ID_UNICODE_CS || _encodingId == TT_MS_ID_UCS_4))
    ;
}
@end

