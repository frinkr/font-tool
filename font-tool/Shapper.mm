//
//  Shapper.m
//  tx-research
//
//  Created by Yuqing Jiang on 6/7/17.
//
//
#include <vector>
#import "Typeface.h"
#import "Shapper.h"
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_GLYPH_H
#include FT_OUTLINE_H
#include FT_TRUETYPE_IDS_H
#include FT_TRUETYPE_TABLES_H
#include FT_TRUETYPE_TAGS_H
#include FT_FONT_FORMATS_H
#include FT_SFNT_NAMES_H
#include FT_TRUETYPE_TABLES_H

#include <hb.h>
#include <hb-ft.h>
#include <hb-ot.h>

NSString * HarfbuzzVersion() {
    unsigned int major, minor, macro;
    hb_version(&major, &minor, &macro);
    return [NSString stringWithFormat:@"%d.%d.%d", major, minor, macro];
}

constexpr unsigned int LANGSYS_DEFAUL_INDEX = 0xFFFFu;
constexpr unsigned int LANGSYS_MISSING_INDEX = -2;
constexpr ot_tag_t OT_MERGED_GSUB_GPOS  = MAKE_TAG4('m', 'e', 'g', 'r'); // face

static hb_bool_t hb_buffer_message(hb_buffer_t *buffer,
                                   hb_font_t   *font,
                                   const char  *message,
                                   void        *user_data) {
    //NSLog(@"HBBUF MSG: %@", [NSString stringWithUTF8String:message]);
    return YES;
}

@interface OTFeature : OpenTypeFeatureTag
@property NSMutableArray<NSNumber*> * lookupIndexes;
@property NSUInteger index;
@end

@interface OTLangSys : NSObject<NSCopying>
@property TypefaceTag   * tag;
@property NSMutableArray<OTFeature*> * features;
@end

@interface OTScript : NSObject
@property TypefaceTag   * tag;
@property NSMutableArray<OTLangSys*>  * langs;
@end

@implementation OTFeature
- (instancetype)copyWithZone:(nullable NSZone *)zone {
    OTFeature * copy = [super copyWithZone:zone];
    copy.lookupIndexes = [[NSMutableArray<NSNumber*> allocWithZone:zone] initWithArray:self.lookupIndexes copyItems:YES];
    copy.index = self.index;
    return copy;
}
@end

@implementation OTLangSys
-(id)copyWithZone:(NSZone *)zone {
    OTLangSys * copy = [[[self class] allocWithZone:zone] init];
    copy.tag = [self.tag copyWithZone:zone];
    copy.features = [[NSMutableArray<OTFeature*> allocWithZone:zone] initWithArray:self.features copyItems:YES];
    return copy;
}
@end
@implementation OTScript
@end

@interface Shapper ()
{
    NSMutableSet<OpenTypeFeatureTag*> * allFeatures;
    
    hb_font_t * hbFont;
    hb_face_t * hbFace;
    hb_buffer_t * hbBuffer;
    hb_shape_plan_t * hbPlan;
    
    unsigned int  glyphCount;
    hb_glyph_info_t * glyphInfos;
    hb_glyph_position_t * glyphPositions;
    
    // mapping from script -> language -> features
    NSArray<OTScript*> * _mergedScripts;
    NSArray<OTScript*> * _gsubScripts;
    NSArray<OTScript*> * _gposScripts;
}

@end

@implementation Shapper

- (instancetype)initWithTypeface:(Typeface*)typeface {
    if (self = [super init]) {
        _typeface = typeface;
        FT_Face ftFace = (FT_Face)_typeface.nativeFace;
        
        // Create HB font and hb face
        hbFont = hb_ft_font_create(ftFace, NULL);
        hbFace = hb_font_get_face(hbFont);
        hb_ot_font_set_funcs(hbFont);
        unsigned int upem = hb_face_get_upem(hbFace);
        hb_font_set_scale(hbFont, upem, upem);
        
        // hb buffer
        hbBuffer = hb_buffer_create();
        
        //unsigned int major, minor, micro;
        //hb_version(&major, &minor, &micro);
    }
    return self;
}

- (OpaqueHBFace)nativeFace {
    return hbFace;
}

- (void)dealloc {
    if (hbBuffer)
        hb_buffer_destroy(hbBuffer);
    
    hb_font_destroy(hbFont);
}

#pragma mark **** Shapping ****

- (void)shapeText:(NSString*)text withDirection:(ShapingDirection)direction script:(TypefaceTag*)script language:(TypefaceTag*)language features:(NSArray<OpenTypeFeatureTag*>*)features{
    
    if (hbBuffer)
        hb_buffer_destroy(hbBuffer);
    
    // setup the buffer
    hbBuffer = hb_buffer_create();
    hb_buffer_set_message_func(hbBuffer, &hb_buffer_message, NULL, NULL);
    
    hb_buffer_set_direction(hbBuffer, (hb_direction_t)direction);
    hb_buffer_set_script(hbBuffer, (hb_script_t)(script.code - 0x20000000)); // first char to upper case

    char utf8Text[1024] = {0};
    [text getCString:utf8Text maxLength:1024 encoding:NSUTF8StringEncoding];
    hb_buffer_add_utf8(hbBuffer, utf8Text, strlen(utf8Text), 0, strlen(utf8Text));
    
    hb_buffer_set_language(hbBuffer, hb_ot_tag_to_language(language.code));
    
    hb_segment_properties_t segment_props;
    hb_buffer_guess_segment_properties(hbBuffer);
    hb_buffer_get_segment_properties(hbBuffer, &segment_props);
    
    
    // features. Harfbuzz has enabled some features by default, we need to turn them off
    NSMutableSet<OpenTypeFeatureTag*> * offFeatures = [self.allFeatures mutableCopy];
    [offFeatures minusSet:[NSSet setWithArray:features]];
    std::vector<hb_feature_t> featuresVec;
    
    for (OpenTypeFeatureTag * tag in features) {
        hb_feature_t f {tag.code, 1/*on*/, 0, (unsigned int)-1};
        featuresVec.push_back(f);
    }
    for (OpenTypeFeatureTag * tag in offFeatures) {
        hb_feature_t f {tag.code, 0/*off*/, 0, (unsigned int)-1};
        featuresVec.push_back(f);
    }

    
    // shape
    
    const char * shappers[] = {"ot", nullptr};//hb_shape_list_shapers();
    
    hbPlan = hb_shape_plan_create_cached(hbFace,
                                         &segment_props,
                                         &featuresVec[0],
                                         featuresVec.size(),
                                         shappers);
    
    hb_shape_plan_execute(hbPlan,
                          hbFont,
                          hbBuffer,
                          &featuresVec[0],
                          featuresVec.size());
    
    
    glyphInfos = hb_buffer_get_glyph_infos(hbBuffer, &glyphCount);
    glyphPositions = hb_buffer_get_glyph_positions(hbBuffer, &glyphCount);
}

- (NSUInteger)numberOfGlyphs {
    return glyphCount;
}

- (NSInteger)glyphAtIndex:(NSUInteger)index {
    return glyphInfos[index].codepoint;
}

// Advance anf offset in font units
- (CGVector)glyphAdvanceAtIndex:(NSUInteger)index {
    return CGVectorMake(glyphPositions[index].x_advance, glyphPositions[index].y_advance);
}

- (CGVector)glyphOffsetAtIndex:(NSUInteger)index {
    return CGVectorMake(glyphPositions[index].x_offset, glyphPositions[index].y_offset);
}

#pragma mark ***** OpenType features ****
- (NSArray<TypefaceTag*> *)scripts {
    return [self scriptsInTable:OT_MERGED_GSUB_GPOS];
}

- (NSArray<TypefaceTag*> *) languagesOfScript:(TypefaceTag*)script {
    return [self languagesOfScript:script inTable:OT_MERGED_GSUB_GPOS];
}

- (NSArray<OpenTypeFeatureTag*> *) featuresOfScript:(TypefaceTag*)script language:(TypefaceTag*)language {
    return [self featuresOfScript:script language:language inTable:OT_MERGED_GSUB_GPOS];
}

- (NSArray<OpenTypeFeatureTag*>*)requiredFeaturesOfScript:(TypefaceTag *)script language:(TypefaceTag *)language {
    return [self requiredFeaturesOfScript:script language:language inTable:OT_MERGED_GSUB_GPOS];
}

- (NSArray<TypefaceTag*> *) scriptsInTable:(ot_tag_t)table {
    return [self scriptsOfMasterList:[self mastScriptsOfTable:table]];
}

- (NSArray<TypefaceTag*> *) languagesOfScript:(TypefaceTag*)script inTable:(ot_tag_t)table {
    return [self languagesOfScript:script ofMasterList:[self mastScriptsOfTable:table]];
}

- (NSArray<OpenTypeFeatureTag*> *) featuresOfScript:(TypefaceTag*)script language:(TypefaceTag*)language inTable:(ot_tag_t)table {
    return [self featuresOfScript:script language:language ofMasterList:[self mastScriptsOfTable:table]];
}

- (NSArray<OpenTypeFeatureTag*> *) requiredFeaturesOfScript:(TypefaceTag*)script language:(TypefaceTag*)language inTable:(ot_tag_t)table {
    return [self requiredFeaturesOfScript:script language:language ofMasterList:[self mastScriptsOfTable:table]];
}

- (NSArray<OTScript*>*)mastScriptsOfTable:(ot_tag_t)table {
    if (table == OT_TAG_GPOS)
        return [self gposScripts];
    if (table == OT_TAG_GSUB)
        return [self gsubScripts];
    if (table == OT_MERGED_GSUB_GPOS)
        return [self mergedScripts];
    return nil;
}

- (NSArray<TypefaceTag*> *)scriptsOfMasterList:(NSArray<OTScript*>*)masterScripts {
    NSMutableArray<TypefaceTag*> * scripts = [[NSMutableArray<TypefaceTag*> alloc] init];
    for (OTScript* s in masterScripts)
        [scripts addObject:s.tag];
    return scripts;
}

- (NSArray<TypefaceTag*> *) languagesOfScript:(TypefaceTag*)script ofMasterList:(NSArray<OTScript*>*)masterScripts {
    NSMutableArray<TypefaceTag*> * languages = [[NSMutableArray<TypefaceTag*> alloc] init];
    for (OTScript* s in masterScripts) {
        if ([s.tag isEqual:script]) {
            for (OTLangSys * langSys in s.langs) {
                [languages addObject:langSys.tag];
            }
        }
    }
    return languages;
}

- (NSArray<OpenTypeFeatureTag*> *) featuresOfScript:(TypefaceTag*)script language:(TypefaceTag*)language ofMasterList:(NSArray<OTScript*>*)masterScripts {
    for (OTScript* s in masterScripts) {
        if ([s.tag isEqual:script]) {
            for (OTLangSys * langSys in s.langs) {
                if ([langSys.tag isEqual:language])
                    return langSys.features;
            }
        }
    }
    return nil;
}

- (NSArray<OpenTypeFeatureTag*>*)requiredFeaturesOfScript:(TypefaceTag *)script language:(TypefaceTag *)language ofMasterList:(NSArray<OTScript*>*)masterScripts {
    for (OTScript* s in masterScripts) {
        if ([s.tag isEqual:script]) {
            for (OTLangSys * langSys in s.langs) {
                if ([langSys.tag isEqual:language])
                    return [langSys.features filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isRequired == YES"]];
            }
        }
    }
    return nil;
}

- (NSArray<NSNumber*> *) lookupIndexesOfFeature:(OpenTypeFeatureTag*) feature script:(TypefaceTag*)script language:(TypefaceTag*)language inTable:(ot_tag_t)table {
    NSArray<OpenTypeFeatureTag *> * features = [self featuresOfScript:script language:language inTable:table];
    for (OpenTypeFeatureTag * f in features) {
        if ([feature isEqual:f]) {
            return ((OTFeature*)f).lookupIndexes;
        }
    }
    return nil;
}

- (NSUInteger) indexOfFeature:(OpenTypeFeatureTag*) feature script:(TypefaceTag*)script language:(TypefaceTag*)language inTable:(ot_tag_t)table {
    NSArray<OpenTypeFeatureTag *> * features = [self featuresOfScript:script language:language inTable:table];
    for (OpenTypeFeatureTag * f in features) {
        if ([feature isEqual:f]) {
            return ((OTFeature*)f).index;
        }
    }
    return NSNotFound;
}

- (NSArray<OTScript*>*)mergedScripts {
    if (!_mergedScripts)
        [self loadScripts];
    return _mergedScripts;
}

- (NSArray<OTScript*>*)gsubScripts {
    if (!_gsubScripts)
        [self loadScripts];
    return _gsubScripts;
}

- (NSArray<OTScript*>*)gposScripts {
    if (!_gposScripts)
        [self loadScripts];
    return _gposScripts;
}

- (void)loadScripts {
    if (_gposScripts && _gsubScripts && _mergedScripts)
        return;
    
    NSMutableArray<OTScript*> * gsubScripts =  [[NSMutableArray<OTScript*> alloc] init];
    NSMutableArray<OTScript*> * gposScripts =  [[NSMutableArray<OTScript*> alloc] init];
    
    hb_tag_t tables [] = {OT_TAG_GSUB, OT_TAG_GPOS,};
    for (hb_tag_t table : tables) {
        NSMutableArray<OTScript*> * tableScripts = nil;
        
        if (table == OT_TAG_GSUB)
            tableScripts = gsubScripts;
        else
            tableScripts = gposScripts;
        
        // find all scripts
        unsigned int script_count = hb_ot_layout_table_get_script_tags(hbFace, table, 0, nullptr, nullptr);
        std::vector<hb_tag_t> script_tags(script_count);
        hb_ot_layout_table_get_script_tags(hbFace, table, 0, &script_count, &script_tags[0]);
        
        for (hb_tag_t script_tag: script_tags) {
            unsigned int script_index = 0;
            if (!hb_ot_layout_table_find_script(hbFace, table, script_tag, &script_index))
                continue;
            
            OTScript * script = nil;
            script = [[OTScript alloc] init];
            script.tag = [TypefaceTag tagFromCode:script_tag];
            script.langs = [[NSMutableArray<OTLangSys*> alloc] init];
            
            NSMutableArray<OTLangSys*>* langs = script.langs;
            
            // language tags
            unsigned int language_count = hb_ot_layout_script_get_language_tags(hbFace, table, script_index, 0, nullptr, nullptr);
            std::vector<hb_tag_t> language_tags(language_count);
            hb_ot_layout_script_get_language_tags(hbFace, table, script_index, 0, &language_count, &language_tags[0]);
            
            std::vector<unsigned int> language_indexes;
            
            for (hb_tag_t language_tag : language_tags) {
                unsigned int language_index = LANGSYS_MISSING_INDEX;
                if (!hb_ot_layout_script_find_language(hbFace, table, script_index, language_tag, &language_index))
                    language_index = -2;
                language_indexes.push_back(language_index);
            }
            
            // add the default language system
            language_tags.insert(language_tags.begin(), OT_TAG_LANGSYS_DEFAULT);
            language_indexes.insert(language_indexes.begin(), LANGSYS_DEFAUL_INDEX);
            
            for (size_t index = 0; index < language_tags.size(); ++ index) {
                hb_tag_t language_tag = language_tags[index];
                
                unsigned int language_index = language_indexes[index];
                if (language_index == LANGSYS_MISSING_INDEX) // not found
                    continue;
                
                // features
                unsigned int feature_count = hb_ot_layout_language_get_feature_tags(hbFace, table, script_index, language_index, 0, nullptr, nullptr);
                std::vector<hb_tag_t> feature_tags(feature_count);
                std::vector<unsigned int> feature_indexes(feature_count);
                hb_ot_layout_language_get_feature_tags(hbFace, table, script_index, language_index, 0, &feature_count, &feature_tags[0]);
                hb_ot_layout_language_get_feature_indexes(hbFace, table, script_index, language_index, 0, &feature_count, &feature_indexes[0]);
                
                unsigned int  required_feature_index = 0xFFFF;
                hb_tag_t required_feature_tag = 0xFFFF;
                if (!hb_ot_layout_language_get_required_feature(hbFace, table, script_index, language_index, &required_feature_index, &required_feature_tag))
                    required_feature_index = 0xFFFF;
                
                std::vector<hb_tag_t> required_feature_tags = {OT_TAG_KERN, OT_TAG_LIGA, required_feature_tag};
                NSMutableArray<OTFeature*> * langFeatures = [[NSMutableArray<OTFeature*> alloc] init];
                for (size_t index = 0; index < feature_count; ++ index) {
                    hb_tag_t feature_tag = feature_tags[index];
                    unsigned int feature_index = feature_indexes[index];
                    
                    // Lookups
                    unsigned int lookup_count = hb_ot_layout_feature_get_lookups(hbFace, table, feature_index, 0, nullptr, nullptr);
                    std::vector<unsigned int> lookups(lookup_count);
                    hb_ot_layout_feature_get_lookups(hbFace, table, feature_index, 0, &lookup_count, &lookups[0]);
                    
                    NSMutableArray<NSNumber*> * lookupsArray = [[ NSMutableArray<NSNumber*> alloc] init];
                    for (unsigned int lookup : lookups)
                        [lookupsArray addObject:[NSNumber numberWithUnsignedInteger:lookup]];
                    
                    
                    OTFeature * tag = [[OTFeature alloc] initWithCode:feature_tag];
                    tag.isRequired = (std::find(required_feature_tags.begin(), required_feature_tags.end(), feature_tag) != required_feature_tags.end());
                    tag.lookupIndexes = lookupsArray;
                    tag.index = feature_index;
                    
                    [langFeatures addObject:tag];
                }
                
                OTLangSys * lang = nil;
                lang = [[OTLangSys alloc] init];
                lang.tag = [TypefaceTag tagFromCode:language_tag];
                lang.features = langFeatures;
                [langs addObject:lang];
            }
            
            [tableScripts addObject:script];
        }
    }
    
    // if 'dlft' is the only langsys in this table, but there is other langsys in previous table
    // copy all features from the 'dlft' langsys
    NSMutableArray<OTScript*> * allScripts = [[NSMutableArray<OTScript*> alloc] init]; {
        NSMutableArray<NSString*> * allScriptNames = [[NSMutableArray<NSString*> alloc] init];
        
        for (OTScript * script in gsubScripts) {
            if (NSNotFound == [allScriptNames indexOfObject:script.tag.text])
                [allScriptNames addObject:script.tag.text];
        }
        for (OTScript * script in gposScripts) {
            if (NSNotFound == [allScriptNames indexOfObject:script.tag.text])
                [allScriptNames addObject:script.tag.text];
        }
        
        OTScript * (^getScriptByName)(NSArray *, NSString *) = ^(NSArray* array, NSString * name) {
            for (OTScript * script in array) {
                if ([script.tag.text isEqualToString:name])
                    return script;
            }
            return (OTScript*)nil;
        };
        
        OTLangSys* (^getDFLTOnlyLangSys)(OTScript *) = ^(OTScript * script) {
            if ( (script.langs.count == 1) && ([script.langs objectAtIndex:0].tag.code == OT_TAG_LANGSYS_DEFAULT))
                return [script.langs objectAtIndex:0];
            return (OTLangSys*)nil;
        };
        
        NSMutableArray * (^mergeFeaturesArray)(NSArray *, NSArray *) = ^(NSArray * arr1, NSArray * arr2) {
            NSMutableArray * ret = [[NSMutableArray alloc] initWithArray:arr1 copyItems:YES];
            [ret addObjectsFromArray:[[NSMutableArray alloc] initWithArray:arr2 copyItems:YES]];
            return ret;
        };
        
        for (NSString * scriptName in allScriptNames) {
            
            OTScript * gsubScript = getScriptByName(gsubScripts, scriptName);
            OTScript * gposScript = getScriptByName(gposScripts, scriptName);
            
            OTScript * newScript = [[OTScript alloc] init];
            newScript.tag = [gsubScript?gsubScript.tag:gposScript.tag copy];
            newScript.langs = [[NSMutableArray<OTLangSys*> alloc] init];
            
            OTLangSys * gsubDflt = getDFLTOnlyLangSys(gsubScript);
            OTLangSys * gposDflt = getDFLTOnlyLangSys(gposScript);
            
            if (gsubDflt) {
                // gsub has default only, gpos may have languages
                for (OTLangSys * langSys in gposScript.langs) {
                    OTLangSys * newLangSys = [langSys copy];
                    newLangSys.features = mergeFeaturesArray(langSys.features, gsubDflt.features);
                    [newScript.langs addObject:newLangSys];
                }
            }
            else if (gposDflt) {
                // gpos has default only, gsub may have languages
                for (OTLangSys * langSys in gsubScript.langs) {
                    OTLangSys * newLangSys = [langSys copy];
                    newLangSys.features = mergeFeaturesArray(langSys.features, gposDflt.features);
                    [newScript.langs addObject:newLangSys];
                }
            }
            else {
                // both has multiple languages
                for (OTLangSys * langSys in gposScript.langs) {
                    OTLangSys * langSys2 = nil;
                    for (OTLangSys * lang in gsubScript.langs) {
                        if ([lang.tag isEqualToTag:langSys.tag]) {
                            langSys2 = lang;
                            break;
                        }
                    }
                    OTLangSys * newLangSys = [langSys copy];
                    if (langSys.features)
                        newLangSys.features = mergeFeaturesArray(langSys.features, langSys2.features);
                    
                    [newScript.langs addObject:newLangSys];
                }
            }
            
            [allScripts addObject:newScript];
        }
    }
    _mergedScripts = allScripts;
    _gposScripts = gposScripts;
    _gsubScripts = gsubScripts;
    
}

- (NSSet<OpenTypeFeatureTag*>*)allFeatures {
    if (!allFeatures)
    {
        allFeatures = [[NSMutableSet<OpenTypeFeatureTag*> alloc] init];
        hb_tag_t tables [] = {OT_TAG_GSUB, OT_TAG_GPOS};
        for (hb_tag_t table : tables) {
            unsigned int feature_count = hb_ot_layout_table_get_feature_tags(hbFace, table, 0, nullptr, nullptr);
            std::vector<hb_tag_t> feature_tags(feature_count);
            hb_ot_layout_table_get_feature_tags(hbFace, table, 0, &feature_count, &feature_tags[0]);
            
            for (hb_tag_t feature_tag : feature_tags)
                [allFeatures addObject:[[OpenTypeFeatureTag alloc] initWithCode:feature_tag]];
        }
    }
    
    return allFeatures;
}

- (NSSet<TypefaceTag*>*)allScripts {
    return [NSSet<TypefaceTag*> setWithArray:[self scripts]];
}

- (NSSet<TypefaceTag*>*)allLanguages {
    NSMutableArray<TypefaceTag*> * languages = [[NSMutableArray<TypefaceTag*> alloc] init];
    for (TypefaceTag * script in [self scripts])
        [languages addObjectsFromArray:[self languagesOfScript:script]];
    
    return [NSSet<TypefaceTag*> setWithArray:languages];
}

@end


@implementation Typeface(Shapper)

- (Shapper *)createShapper {
    return [[Shapper alloc] initWithTypeface:self];
}

@end

