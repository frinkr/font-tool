//
//  Shapper.h
//  tx-research
//
//  Created by Yuqing Jiang on 6/7/17.
//
//

#import <Foundation/Foundation.h>
#import "Typeface.h"

typedef void * OpaqueHBFace;

typedef NS_ENUM(NSInteger, ShapingDirection) {
    ShappingDirectionInvalid = 0,
    ShappingDirectionAuto,
    ShappingDirectionLTR = 4,
    ShappingDirectionRTL,
    ShappingDirectionTTB,
    ShappingDirectionBTT
};

FT_BEGIN_DECLS
NSString * HarfbuzzVersion();
FT_END_DECLS

@interface Shapper : NSObject
@property (strong, readonly) Typeface * typeface;

- (instancetype)initWithTypeface:(Typeface*)typeface;

- (OpaqueHBFace)nativeFace;

- (void)shapeText:(NSString*)text withDirection:(ShapingDirection)direction script:(TypefaceTag*)script language:(TypefaceTag*)language features:(NSArray<OpenTypeFeatureTag*>*)features;

- (NSUInteger)numberOfGlyphs;
- (NSInteger)glyphAtIndex:(NSUInteger)index;

// Advance anf offset in font units
- (CGVector)glyphAdvanceAtIndex:(NSUInteger)index;
- (CGVector)glyphOffsetAtIndex:(NSUInteger)index;

- (NSSet<OpenTypeFeatureTag*>*)allFeatures;
- (NSSet<TypefaceTag*>*) allScripts;
- (NSSet<TypefaceTag*>*) allLanguages;

// script-langauge-feature querying, merged
- (NSArray<TypefaceTag*> *) scripts;
- (NSArray<TypefaceTag*> *) languagesOfScript:(TypefaceTag*)script;
- (NSArray<OpenTypeFeatureTag*> *) featuresOfScript:(TypefaceTag*)script language:(TypefaceTag*)language;
- (NSArray<OpenTypeFeatureTag*> *) requiredFeaturesOfScript:(TypefaceTag*)script language:(TypefaceTag*)language;

- (NSArray<TypefaceTag*> *) scriptsInTable:(ot_tag_t)table;
- (NSArray<TypefaceTag*> *) languagesOfScript:(TypefaceTag*)script inTable:(ot_tag_t)table;
- (NSArray<OpenTypeFeatureTag*> *) featuresOfScript:(TypefaceTag*)script language:(TypefaceTag*)language inTable:(ot_tag_t)table;
- (NSArray<OpenTypeFeatureTag*> *) requiredFeaturesOfScript:(TypefaceTag*)script language:(TypefaceTag*)language inTable:(ot_tag_t)table;
- (NSArray<NSNumber*> *) lookupIndexesOfFeature:(OpenTypeFeatureTag*) feature script:(TypefaceTag*)script language:(TypefaceTag*)language inTable:(ot_tag_t)table;
- (NSUInteger) indexOfFeature:(OpenTypeFeatureTag*) feature script:(TypefaceTag*)script language:(TypefaceTag*)language inTable:(ot_tag_t)table;

@end

@interface Typeface (Shapper)
- (Shapper *)createShapper;
@end
