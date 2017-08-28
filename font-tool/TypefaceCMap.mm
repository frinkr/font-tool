#import "TypefaceCMap.h"
#import "TypefaceNames.h"
#import "CharEncoding.h"

#include <vector>
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

@interface TypefaceGlyphSection ()
@property NSMutableArray<TypefaceGlyphcode*> * internalGlyphCodes;
@end

@implementation TypefaceGlyphSection

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

- (BOOL)containsCode:(NSUInteger)code outIndex:(NSUInteger*)outIndex {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return NO;
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


@implementation TypefaceGlyphRangeSection

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

- (BOOL)containsCode:(NSUInteger)code  outIndex:(NSUInteger*)outIndex {
    *outIndex = code - self.from;
    return code >= self.from && code <= self.to;
}

@end

@implementation TypefaceGlyphArraySection

- (instancetype)initWithGlyphs:(NSArray<NSNumber *> *)glyphs isGID:(BOOL)isGID name:(NSString *)name {
    if (self = [super init]) {
        self.glyphs = glyphs;
        self.blockName = name;
        self.isGID = isGID;
    }
    return self;
}

- (NSString*)name {
    return self.blockName;
}

- (NSUInteger)numOfGlyphs {
    return self.glyphs.count;
}

-(TypefaceGlyphcode*)glyphCodeAtIndex:(NSUInteger)index {
    NSUInteger code = [[self.glyphs objectAtIndex:index] unsignedIntegerValue];
    TypefaceGlyphcode * gc = [[TypefaceGlyphcode alloc] init];

    if (self.isGID)
        gc.GID = code;
    else
        gc.charcode = code;
    gc.isGID = self.isGID;
    return gc;
}

- (BOOL)containsCode:(NSUInteger)code outIndex:(NSUInteger*)outIndex{
    *outIndex = [self.glyphs indexOfObject:@(code)];
    return [self.glyphs containsObject:@(code)];
}

@end

@implementation TypefaceGlyphBlock

- (instancetype)initWithName:(NSString*)name sections:(NSArray<TypefaceGlyphSection *> *)sections {
    if (self = [super init]) {
        self.name = name;
        self.sections = sections;
    }
    return self;
}

@end

#pragma mark  ###### TypefaceCMap ######

@interface TypefaceCMapPlatform : NSObject {
    NSMutableArray<TypefaceGlyphSection*> * _unicodeBlocks;
    NSMutableDictionary<NSNumber*, NSArray<TypefaceGlyphSection*>* > *_encodingBlocksCache;
}
@property (readonly) NSUInteger platformId;
@property (readonly, strong) NSString * platformName;

- (id) initWithPlatformId:(NSUInteger)platformId;
- (NSString*)cmapNameOfEncoding:(NSUInteger)encoding;
- (NSArray<TypefaceGlyphSection*>*) glyphBlocksOfEncoding:(NSUInteger)encoding;

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
        _encodingBlocksCache = [[NSMutableDictionary<NSNumber*, NSArray<TypefaceGlyphSection*>* > alloc] init];
        _platformId = platformId;
    }
    return self;
}

- (NSString*)cmapNameOfEncoding:(NSUInteger)encoding {
    return FTGetPlatformEncodingName(self.platformId, encoding);
}

#pragma mark **** GlyphBlock ****
- (NSArray<TypefaceGlyphSection*>*)glyphBlocksOfEncoding:(NSUInteger)encoding {
    NSArray<TypefaceGlyphSection*>* blocks = [_encodingBlocksCache objectForKey:[NSNumber numberWithUnsignedInteger:encoding]];
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
        blocks = [[NSArray<TypefaceGlyphSection*> alloc] init];
    }
    [_encodingBlocksCache setObject:blocks forKey:[NSNumber numberWithUnsignedInteger:encoding]];
    return blocks;
}
- (NSArray<TypefaceGlyphSection*>*) loadUnicodeGlyphBlocksOfEncoding:(NSUInteger)encoding {
    return [self loadUnicodeBlocksOfVersion:nil];
}

- (NSArray<TypefaceGlyphSection*>*) loadMacintoshGlyphBlocksOfEncoding:(NSUInteger)encoding {
    switch(encoding) {
        case TT_MAC_ID_ROMAN:
            return @[ [[TypefaceGlyphRangeSection alloc] initWithFrom:0 to:255 isGID:NO name:@"Mac Roman"] ];
        default: return nil;
    }
}

- (NSArray<TypefaceGlyphSection*>*) loadMicrosoftGlyphBlocksOfEncoding:(NSUInteger)encoding {
    switch(encoding) {
        case TT_MS_ID_UNICODE_CS:
        case TT_MS_ID_UCS_4:
            return [self loadUnicodeGlyphBlocksOfEncoding:encoding];
        case TT_MS_ID_SYMBOL_CS:
            return @[ [[TypefaceGlyphRangeSection alloc] initWithFrom:0xF020 to:0xF0FF isGID:NO name:@"Windows Symbol"] ];
        default:
            return nil;
    }
    
    return nil;
}

- (NSArray<TypefaceGlyphSection*>*) loadISOGlyphBlocksOfEncoding:(NSUInteger)encoding {
    return nil;
}

- (NSArray<TypefaceGlyphSection*>*) loadAdobeGlyphBlocksOfEncoding:(NSUInteger)encoding {
    switch(encoding) {
        case TT_ADOBE_ID_STANDARD:
            // https://www.compart.com/en/unicode/charsets/Adobe-Standard-Encoding
            return @[ [[TypefaceGlyphRangeSection alloc] initWithFrom:0 to:255 isGID:NO name:@"Standard"] ];
        case TT_ADOBE_ID_EXPERT:
            return @[ [[TypefaceGlyphRangeSection alloc] initWithFrom:0 to:255 isGID:NO name:@"Expert"] ];
        case TT_ADOBE_ID_CUSTOM:
            return @[ [[TypefaceGlyphRangeSection alloc] initWithFrom:0 to:255 isGID:NO name:@"Custom"] ];
        case TT_ADOBE_ID_LATIN_1:
            return @[ [[TypefaceGlyphRangeSection alloc] initWithFrom:0 to:255 isGID:NO name:@"Latin 1"] ];
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

- (NSArray<TypefaceGlyphSection*>*)loadUnicodeBlocksOfVersion:(NSString*)version {
    if (_unicodeBlocks)
        return _unicodeBlocks;
    
    _unicodeBlocks= [[NSMutableArray<TypefaceGlyphSection*> alloc] init];
    
    // Full Repertorire block
    [_unicodeBlocks addObject:[self unicodeFullRepertoireBlock]];
    
    // Add each Unicode block
    NSArray<UnicodeBlock*> * uniBlocks = [UnicodeDatabase standardDatabase].unicodeBlocks;
    for (UnicodeBlock * block in uniBlocks) {
        TypefaceGlyphRangeSection * b = [[TypefaceGlyphRangeSection alloc] initWithFrom:block.from
                                                                                 to:block.to
                                                                              isGID:NO
                                                                               name:block.name];
        [_unicodeBlocks addObject:b];
    }
    
    return _unicodeBlocks;
}

- (TypefaceGlyphRangeSection*) unicodeFullRepertoireBlock {
    return [[TypefaceGlyphRangeSection alloc] initWithFrom:0
                                                      to:0x10FFFF
                                                   isGID:NO
                                                    name:@"Unicode Full Repertoire" ];
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

@interface TypefaceCMap ()
{
    FT_Face                    _ftFace;
    TypefaceGlyphBlock *  _unicodeFullRepertoireCompactBlock;
}
@end

@implementation TypefaceCMap

- (instancetype)initWithFace:(OpaqueFTFace)ftFace cmapIndex:(NSUInteger)index {
    if (self == [super init]) {
        _index = index;
        _ftFace = ftFace;
        FT_Reference_Face(_ftFace);
        
        FT_CharMap cm = _ftFace->charmaps[index];
        _platformId = cm->platform_id;
        _encodingId = cm->encoding_id;
        _numOfGlyphs = _ftFace->num_glyphs;
        
        _name = [TypefaceCMapPlatform cmapNameOfPlatform:_platformId encodong:_encodingId];
    }
    return self;
}


- (void)dealloc {
    FT_Done_Face(_ftFace);
}

- (NSArray<TypefaceGlyphBlock*> *)blocks {
    if (!_blocks)
        _blocks = [self loadSuperBlocks];
    return _blocks;
}

- (NSMutableArray<TypefaceGlyphBlock*> *)loadSuperBlocks {
    NSMutableArray<TypefaceGlyphBlock*> * superBlocks = [[NSMutableArray<TypefaceGlyphBlock*> alloc] init];
    
    TypefaceCMapPlatform * cmapPlatform = [TypefaceCMapPlatform platformById:_platformId];
    for (TypefaceGlyphSection * subBlock in [cmapPlatform glyphBlocksOfEncoding:_encodingId])
        [superBlocks addObject:[self subBlockToSuperBlock:subBlock]];
    
    if (self.isUnicode) {
        [self loadUnicodeFullRepertoireCompactBlock];
        [superBlocks insertObject:_unicodeFullRepertoireCompactBlock
                          atIndex:1];
    }
    [superBlocks insertObject:[self subBlockToSuperBlock: [self allGlyphsBlock]]
                      atIndex:ALL_GLYPHS_BLOCK_INDEX];
    
    return superBlocks;
}

- (TypefaceGlyphBlock*)subBlockToSuperBlock:(TypefaceGlyphSection*)block {
    return [[TypefaceGlyphBlock alloc] initWithName:block.name sections:@[block]];
}

- (void)loadUnicodeFullRepertoireCompactBlock {
    FT_Int oldIndex = FT_Get_Charmap_Index(_ftFace->charmap);
    [self selectCharMapByIndex:self.index];
    
    NSArray<UnicodeBlock*> * uniBlocks = [[UnicodeDatabase standardDatabase] unicodeBlocks];
    
    FT_ULong  charcode;
    FT_UInt   gindex;
    
    std::vector<bool> gidSet(_ftFace->num_glyphs);
        
    NSUInteger currUniBlockIndex = 0;
    NSMutableArray<NSNumber*> * currArray = [[NSMutableArray<NSNumber*> alloc] init];
    
    NSMutableArray<TypefaceGlyphArraySection*> * blocks = [[NSMutableArray<TypefaceGlyphArraySection*> alloc] init];
    
    // sorted by charcode
    charcode = FT_Get_First_Char(_ftFace, &gindex);
    while (gindex) {
        
        gidSet[gindex] = true;
        UnicodeBlock * currUniBlock = [uniBlocks objectAtIndex:currUniBlockIndex];
        
        if ([currUniBlock containsUnicode:charcode]) {
            [currArray addObject:@(charcode)];
        }
        else {
            if (currArray.count) {
                TypefaceGlyphArraySection * block = [[TypefaceGlyphArraySection alloc] initWithGlyphs:currArray
                                                                                            isGID:NO
                                                                                             name:currUniBlock.name];
                
                [blocks addObject:block];
            }
            
            // find next Unicode block
            NSUInteger uniBlockIndex = currUniBlockIndex + 1;
            if (uniBlockIndex < uniBlocks.count &&
                ![[uniBlocks objectAtIndex:uniBlockIndex] containsUnicode:charcode]) {
                ++ uniBlockIndex;
            }
            
            // can't find next block
            if (uniBlockIndex == uniBlocks.count)
                break;
            
            // start new block
            currArray = [[NSMutableArray<NSNumber*> alloc] init];
            [currArray addObject:@(charcode)];
            currUniBlockIndex = uniBlockIndex;
        }
        
        charcode = FT_Get_Next_Char(_ftFace, charcode, &gindex);
    }
    
    if (currUniBlockIndex < uniBlocks.count && currArray.count) {
        UnicodeBlock * currUniBlock = [uniBlocks objectAtIndex:currUniBlockIndex];
        TypefaceGlyphArraySection * block = [[TypefaceGlyphArraySection alloc] initWithGlyphs:currArray
                                                                                    isGID:NO
                                                                                     name:currUniBlock.name];
        
        [blocks addObject:block];
    }
    
    // incase gid is not found by FT_Get_First_Char / FT_Get_Next_Char
    currArray = [[NSMutableArray<NSNumber*> alloc] init];
    for (size_t gid = 0; gid < gidSet.size(); ++ gid) {
        if (!gidSet[gid]) {
            [currArray addObject:@(gid)];
        }
    }
    if (currArray.count) {
        TypefaceGlyphArraySection * block = [[TypefaceGlyphArraySection alloc] initWithGlyphs:currArray
                                                                                    isGID:YES
                                                                                     name:@"Unassigned"];
        
        [blocks addObject:block];
    }
    
    _unicodeFullRepertoireCompactBlock = [[TypefaceGlyphBlock alloc] initWithName:@"Unicode Compact" sections:blocks];
    
    [self selectCharMapByIndex: oldIndex];

}

- (TypefaceGlyphRangeSection*) allGlyphsBlock {
    return [[TypefaceGlyphRangeSection alloc] initWithFrom:0
                                                      to:self.numOfGlyphs
                                                   isGID:YES
                                                    name:@"All Glyphs"];
}

- (BOOL)isUnicode {
    return _platformId == TT_PLATFORM_APPLE_UNICODE
    || (_platformId == TT_PLATFORM_MICROSOFT && ( _encodingId == TT_MS_ID_UNICODE_CS || _encodingId == TT_MS_ID_UCS_4))
    ;
}

- (void)selectCharMapByIndex:(NSUInteger)index {
    for (FT_Int i = 0; i < _ftFace->num_charmaps; ++ i) {
        if (index == i) {
            FT_CharMap cm = _ftFace->charmaps[i];
            FT_Set_Charmap(_ftFace, cm);
        }
    }
}
@end

