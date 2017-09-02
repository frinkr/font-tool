
#import <Cocoa/Cocoa.h>

#if !__has_feature(objc_arc)
#error "Stone age ape no ARC?"
#endif

#import "TypefaceCMap.h"

typedef uint32_t ot_tag_t;
#define MAKE_TAG4(a, b, c, d) ((ot_tag_t)((((uint8_t)(a))<<24)|(((uint8_t)(b))<<16)|(((uint8_t)(c))<<8)|((uint8_t)(d))))

#define MAKE_TAG(t) ((t) & 0xFFFFFFFF)
#define MAKE_CT_TAG(type, selector) ((uint32_t((type) & 0xFFFF) << 16) + uint32_t((selector) & 0xFFFF))

#define OT_TAG_GSUB MAKE_TAG4('G', 'S', 'U', 'B')
#define OT_TAG_GPOS MAKE_TAG4('G', 'P', 'O', 'S')

#define OT_TAG_SCRIPT_DEFAULT MAKE_TAG4('D', 'L', 'F', 'T')
#define OT_TAG_LANGSYS_DEFAULT MAKE_TAG4('d', 'l', 'f', 't')
#define OT_TAG_KERN MAKE_TAG4('k', 'e', 'r', 'n')
#define OT_TAG_LIGA MAKE_TAG4('l', 'i', 'g', 'a')


#define INVALID_FACE_INDEX -1


typedef NS_ENUM(NSInteger, GlyphLookupType) {
    GlyphLookupByCharcode,
    GlyphLookupByGlyphIndex,
    GlyphLookupByName,
};

@interface GlyphLookupRequest : NSObject
@property GlyphLookupType lookupType;
@property id lookupValue;
@property NSUInteger preferedBlock;

+(instancetype)createRequestWithCharcode:(NSUInteger)charcode preferedBlock:(NSUInteger)preferedBlock;
+(instancetype)createRequestWithId:(NSUInteger)gid preferedBlock:(NSUInteger)preferedBlock;
+(instancetype)createRequestWithName:(NSString*)name preferedBlock:(NSUInteger)preferedBlock;

// Expression, see [CharEncoding charcodeOfString] and [CharEncoding gidOfString]
+(instancetype)createRequestWithExpression:(NSString*)expression preferedBlock:(NSUInteger)preferedBlock;
@end

typedef void * OpaqueFTLibrary;

extern NSString * const TypefaceErrorDomain;

@class Typeface;

@interface TypefaceTag : NSObject<NSCopying>
@property (readonly) uint32_t code;
@property (readonly, strong) NSString * text;

- (instancetype)initWithCode:(uint32_t)code;
- (instancetype)initWithText:(NSString*)text;
- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToTag:(TypefaceTag*)other;
- (NSUInteger)hash;
- (NSString *)description;
- (NSComparisonResult)compare:(TypefaceTag*)other;

+ (NSString*)codeToText:(NSUInteger)tag;
+ (NSUInteger)textToCode:(NSString*)text;
+ (TypefaceTag*)tagFromCode:(uint32_t)code;

@end

@interface OpenTypeFeatureTag : TypefaceTag<NSCopying>
@property BOOL isRequired;
+(OpenTypeFeatureTag*)tagFromCode:(uint32_t)code;
@end



@interface TypefaceGlyph : NSObject
@property NSUInteger          charcode;     // the requested charcode, usually the first element in charcodes
@property NSArray<NSNumber*> *charcodes;    // multiple charcodes may map to same glyph
@property NSUInteger          GID;
@property (strong) NSString * name;

@property (strong) NSImage  * image;
@property NSInteger           imageOffsetX;
@property NSInteger           imageOffsetY;
@property CGFloat             imageFontSize;       // the font size used when rendering the image

// metrics in font unit
@property NSInteger           width;
@property NSInteger           height;
@property NSInteger           horiBearingX;
@property NSInteger           horiBearingY;
@property NSInteger           horiAdvance;
@property NSInteger           vertBearingX;
@property NSInteger           vertBearingY;
@property NSInteger           vertAdvance;

@property (weak) Typeface   * typeface;

@property NSDictionary<TypefaceTag *, NSNumber *> * variants;

- (NSString*)charcodeHex;

@end

@interface TypefaceDescriptor : NSObject<NSCopying>
@property (strong) NSURL    * fileURL;
@property (atomic) NSInteger  faceIndex;

@property (strong) NSString * family;
@property (strong) NSString * style;

- (BOOL)isFileDescriptor;
- (BOOL)isNameDescriptor;

- (id)copyWithZone:(nullable NSZone *)zone;

- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToDescriptor:(TypefaceDescriptor*)other;
- (NSUInteger)hash;
- (NSString *)description;
- (NSComparisonResult)compare:(TypefaceDescriptor*)other;

+ (instancetype) descriptorWithFamily:(NSString*)family style:(NSString*)style;
+ (instancetype) descriptorWithFileURL:(NSURL*)fileURL faceIndex:(NSUInteger)index;
+ (instancetype) descriptorWithFilePath:(NSString*)filePath faceIndex:(NSUInteger)index;

@end

typedef NS_ENUM(NSInteger, TypefaceSerifStyle) {
    TypefaceSerifStyleUndefined,
    TypefaceSerifStyleSerif,
    TypefaceSerifStyleSansSerif,
};


typedef NS_ENUM(NSInteger, TypefaceFormat) {
    TypefaceFormatTrueType,
    TypefaceFormatCFF,
    TypefaceFormatOther,
};


@interface TypefaceAttributes : NSObject

@property BOOL isOpenTypeVariation;
@property BOOL isAdobeMultiMaster;


@property TypefaceSerifStyle serifStyle;
@property (strong) NSSet<TypefaceTag*> * openTypeScripts;
@property (strong) NSSet<TypefaceTag*> * openTypeLanguages;
@property (strong) NSSet<OpenTypeFeatureTag*> * openTypeFeatures;
@property TypefaceFormat format;

// names
@property (strong) NSString * familyName;
@property (strong) NSString * styleName;
@property (strong) NSString * fullName;

@property (strong) NSString * preferedLocalizedFamilyName;
@property (strong) NSString * preferedLocalizedStyleName;
@property (strong) NSString * preferedLocalizedFullName;

// language to name maping
@property (strong) NSDictionary<NSString*, NSString*> * localizedFamilyNames;
@property (strong) NSDictionary<NSString*, NSString*> * localizedStyleNames;
@property (strong) NSDictionary<NSString*, NSString*> * localizedFullNames;

// lanuages
@property (strong) NSArray<NSString*> * designLanguages;

@property (strong) NSString * vender;
@end



@interface TypefaceAxis : NSObject
@property NSUInteger index;
@property NSString * name;
@property TypefaceTag * tag;
@property Fixed minValue;
@property Fixed maxValue;
@property Fixed defaultValue;
@end

@interface TypefaceVariation : NSObject
@property NSArray<NSNumber*> * coordinates; /*Fixed Number*/
-(BOOL)isEqualToVariation:(TypefaceVariation*)other;
@end

@interface TypefaceNamedVariation : TypefaceVariation
@property NSString * name;
@property NSString * psName;
@property NSUInteger index;
@property BOOL isDefault;
-(BOOL)isEqualToNamedVariation:(TypefaceNamedVariation*)other;
@end

@interface Typeface : NSObject

// variations
@property (readonly) BOOL isAdobeMM;
@property (readonly) BOOL isOpenTypeVariation;
@property (readonly) NSArray<TypefaceAxis*> * axises;
@property (readonly) NSArray<TypefaceNamedVariation*> * namedVariations;

// cmaps
@property (readonly) NSArray<TypefaceCMap*> * cmaps;
@property (readonly) TypefaceCMap* currentCMap;
@property (readonly) NSUInteger currentCMapIndex;
@property (readonly) BOOL currentCMapIsUnicode;
// size
@property (nonatomic, getter=fontSize, setter=setFontSize:) CGFloat fontSize;
@property (nonatomic, readonly) NSUInteger dpi;
@property (nonatomic, readonly, getter=getUPEM) NSUInteger upem;
@property (nonatomic, readonly, getter=getAscender) NSInteger ascender;
@property (nonatomic, readonly, getter=getDescender) NSInteger descender;
@property (nonatomic, readonly, getter=getBBox) CGRect bbox;
@property (nonatomic, readonly, getter=getNumberOfGlyphs) NSUInteger numberOfGlyphs;

// names
@property (readonly) NSString * familyName;
@property (readonly) NSString * styleName;
@property (readonly) NSURL    * fileURL;
@property (readonly) NSUInteger faceIndex;

@property (nonatomic, readonly, getter=getPreferedLocalizedFamilyName) NSString * preferedLocalizedFamilyName;
@property (nonatomic, readonly, getter=getPreferedLocalizedStyleName) NSString * preferedLocalizedStyleName;
@property (nonatomic, readonly, getter=getPreferedLocalizedFullName) NSString * preferedLocalizedFullName;

// attributes
@property (readonly, getter=getAttributes) TypefaceAttributes * attributes;
@property (readonly) NSArray<NSString*> * glyphNames;

-(id) initWithOpaqueFace:(OpaqueFTFace)opaqueFace;
-(id) initWithContentOfFile:(NSURL*)url faceIndex:(NSUInteger)index;
-(id) initWithDescriptor:(TypefaceDescriptor*)descriptor;

- (void)setPixelSize:(NSUInteger) px;

- (OpaqueFTFace)nativeFace; // return the native FT_Face

- (TypefaceVariation*)currentVariation; /** observerable */
- (void)selectVariation:(TypefaceVariation*)variation;

- (TypefaceCMap*)getCMapAtIndex:(NSUInteger)index;
- (TypefaceCMap*)selectCMap:(TypefaceCMap*)cmap;
- (TypefaceCMap*)selectCMapAtIndex:(NSUInteger)index;

- (TypefaceGlyph*)loadGlyph:(TypefaceGlyphcode*)code; // load with default font size, with cache
- (TypefaceGlyph*)loadGlyph:(TypefaceGlyphcode*)gc size:(CGFloat)fontSize; // no cache

- (void)lookupGlyph:(GlyphLookupRequest*) request completeHandler:(void (^)(NSUInteger blockIndex, NSUInteger sectionIndex, NSUInteger itemIndex, NSError *error))handler;

- (BOOL)hasCanonicalGlyphNames;
- (NSString*)canonicalNameOfGlyph:(NSUInteger)gid;
- (NSString*)composedNameOfGlyph:(NSUInteger)gid; //

// unit convertion with default DPI(72)
- (CGFloat)ptToPixel:(CGFloat)pt;
- (CGFloat)fontUnitToPixelWithDefaultFontSize:(NSInteger)u;
- (CGFloat)fontUnitToPixel:(NSInteger)u withFontSize:(CGFloat)fontSize;

@end



