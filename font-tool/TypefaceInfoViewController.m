//
//  FontInfoViewController.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/15/17.
//
//
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_TRUETYPE_IDS_H
#include FT_SFNT_NAMES_H
#include FT_FONT_FORMATS_H
#include FT_TYPE1_TABLES_H
#include FT_TRUETYPE_TABLES_H
#include FT_CID_H
#include FT_MULTIPLE_MASTERS_H

#include <hb.h>
#include <hb-ft.h>
#include <hb-ot.h>

#import "CharEncoding.h"
#import "TypefaceDocument.h"
#import "TypefaceNames.h"
#import "TypefaceInfoViewController.h"
#import "Shapper.h"
#include "HarfbuzzEx.h"

#define TF_TABLE_BASIC   'basc'
#define TF_TABLE_FACE    'face'
#define TF_TABLE_TABLES  'tbls'
#define TF_TABLE_HEAD    'head'
#define TF_TABLE_HHEA    'hhea'
#define TF_TABLE_HMTX    'hmtx'
#define TF_TABLE_MAXP    'maxp'
#define TF_TABLE_NAME    'name'
#define TF_TABLE_OS2     'OS/2'
#define TF_TABLE_POST    'post'
#define TF_TABLE_GSUB    'GSUB'
#define TF_TABLE_GPOS    'GPOS'



#define SWAP_ENDIAN_16(u) ((((u) & 0xFF) << 8) + (((u) & 0xFF00) >> 8))

#define SWAP_ENDIAN_32(u) ((((u) & 0xFF) << 24) + (((u) & 0xFF00) << 8) + (((u) & 0xFF0000) >> 8) + (((u) & 0xFF000000) >> 24))



static NSSet<NSNumber*> * HBSet2NSSet(hb_set_t *set) {
    NSMutableSet<NSNumber*>* newSet = [[NSMutableSet<NSNumber*> alloc] init];
    hb_codepoint_t c = HB_SET_VALUE_INVALID;
    while (hb_set_next(set, &c)) {
        [newSet addObject:[NSNumber numberWithUnsignedInteger:c]];
    }
    return newSet;
}

static NSString* FixedArrayToString(NSArray<NSNumber*> * array) {
    NSMutableArray<NSNumber*> * converted = [[NSMutableArray<NSNumber*> alloc] init];
    for (NSNumber* n in array) {
        [converted addObject:@(FixedToFloat([n intValue]))];
    }
    return [converted componentsJoinedByString:@", "];
}

static BOOL isDarkMode() {
    NSAppearance *appearance = NSAppearance.currentAppearance;
    if (@available(*, macOS 10.14))
        return appearance.name == NSAppearanceNameDarkAqua;
        return NO;
}
@interface TypefaceInfoWindowController()

@end

@interface TypefaceInfoViewController ()
@property (assign) IBOutlet NSSegmentedControl *infoSegments;
@property (strong) HtmlTableView *tableView;

@property (assign) NSUInteger currrentTable;

@property (strong) NSMutableDictionary<NSNumber*, HtmlTableRows* > * tfDict;

@end

@implementation TypefaceInfoWindowController
+ (instancetype)togglePanelWithDocument:(TypefaceDocument*)document masterWindow:(NSWindow*)masterWindow sender:(id)sender {
    for (NSWindowController * wc in document.windowControllers) {
        if ([wc isKindOfClass:[TypefaceInfoWindowController class]]) {
            if (wc.window.isVisible) {
                [wc.window orderOut:sender];
            }
            else
            {
                [wc showWindow:sender];
                [masterWindow addChildWindow:wc.window ordered:NSWindowAbove];
            }
            return (TypefaceInfoWindowController*)wc;
        }
    }
    
    TypefaceInfoWindowController * wc = (TypefaceInfoWindowController*) [[NSStoryboard storyboardWithName:@"TypefaceInfoWindow" bundle:nil] instantiateControllerWithIdentifier:@"typefaceInfoWindowController"] ;
    
    [document addWindowController:wc];
    [masterWindow addChildWindow:wc.window ordered:NSWindowAbove];
    [wc showWindow:sender];
    [wc.window setRepresentedURL:document.typeface.fileURL];
    [wc.window setTitle:@"Attributes"];
    return wc;
}

- (BOOL)windowShouldClose:(id)sender {
    [self.window orderOut:sender];
    return NO;
}


@end


@implementation TypefaceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.typeface addObserver:self forKeyPath:@"currentVariation" options:NSKeyValueObservingOptionNew context:nil];
    
    [self loadCurrentTypefaceDictionary];
    
    self.tableView = [[HtmlTableView alloc] initWithFrame:CGRectMake(0, 0, 400, 600)];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView positioned:NSWindowBelow relativeTo:self.infoSegments];
    
    NSDictionary<NSString*, id> * views = @{@"tableView": self.tableView,
                                            @"segments": self.infoSegments};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[tableView]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[segments]-8-[tableView]-0-|" options:0 metrics:nil views:views]];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self doChangeCurrentSegment:self];
}

- (void)dealloc {
    @try {
        [self.typeface removeObserver:self forKeyPath:@"currentVariation"];
    }
    @catch(...) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentVariation"]) {
        [self reloadCurrentTypefaceDictionary];
        [self.tableView reloadData];
    }
}

- (Typeface*)typeface {
    TypefaceDocument * tfDoc = (TypefaceDocument*)[[NSDocumentController sharedDocumentController] currentDocument];
    return tfDoc.typeface;
}

#pragma mark **** Table loading ****
- (void)loadCurrentTypefaceDictionary {
    Typeface * face = [self typeface];
    FT_Face ftFace = face.nativeFace;
    self.tfDict = [[NSMutableDictionary<NSNumber*, HtmlTableRows* > alloc] init];
    
    [self.tfDict setObject:[self loadBasicTableOfFace:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_BASIC]];
    
    [self.tfDict setObject:[self loadFaceOfFace:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_FACE]];
    
    [self.tfDict setObject:[self loadHeadOfTypeface:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_HEAD]];
    
    [self.tfDict setObject:[self loadHheaOfTypeface:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_HHEA]];
    
    [self.tfDict setObject:[self loadHmtxOfTypeface:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_HMTX]];
    
    [self.tfDict setObject:[self loadMaxpOfTypeface:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_MAXP]];
    
    [self.tfDict setObject:[self loadOS2OfTypeface:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_OS2]];
    
    [self.tfDict setObject:[self loadNameTableOfFace:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_NAME]];
    
    [self.tfDict setObject:[self loadPostTableOfFace:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_POST]];
    
    [self.tfDict setObject:[self loadGSUBTableOfFace:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_GSUB]];
    
    [self.tfDict setObject:[self loadGPOSTableOfFace:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_GPOS]];
}

- (void)reloadCurrentTypefaceDictionary {
    Typeface * face = [self typeface];
    FT_Face ftFace = face.nativeFace;
    [self.tfDict setObject:[self loadBasicTableOfFace:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_BASIC]];
    
    [self.tfDict setObject:[self loadFaceOfFace:face ftFace:ftFace]
                    forKey:[NSNumber numberWithUnsignedInteger:TF_TABLE_FACE]];
}

- (HtmlTableRows*)loadBasicTableOfFace:(Typeface*)face ftFace:(FT_Face)ftFace {
    FT_Error error = 0;
    
    TypefaceAttributes * attributes = face.attributes;
    
    HtmlTableRows * items = [[HtmlTableRows alloc] init];
    [items addRowWithKey:@"Family" stringValue:face.attributes.familyName];
    [items addRowWithKey:@"Style"  stringValue:face.attributes.styleName];
    [items addRowWithKey:@"Localized Family Name" stringValue:face.preferedLocalizedFamilyName];
    [items addRowWithKey:@"Localized Style Name"  stringValue:face.preferedLocalizedStyleName];
    [items addRowWithKey:@"Postscript Name" stringValue:face.attributes.postscriptName];
    [items addRowWithKey:@"File"   stringValue:face.fileURL.path];
    
    
    TT_Header * head = FT_Get_Sfnt_Table(ftFace, FT_SFNT_HEAD);
    TT_OS2 * os2 = FT_Get_Sfnt_Table(ftFace, FT_SFNT_OS2);
    
    
    FT_Bool isCID = false;
    error = FT_Get_CID_Is_Internally_CID_Keyed(ftFace, &isCID);
    
    if (isCID)
    { // CID
        NSString * ROS = @"Unknown ROS";
        if (!error && isCID) {
            const char * registry = nil, *ordering = nil;
            FT_Int supplement = 0;
            error = FT_Get_CID_Registry_Ordering_Supplement(ftFace, &registry, &ordering, &supplement);
            if (error) {
                registry = "unknown";
                ordering = "unknown";
            }
            ROS = [NSString stringWithFormat:@"%@-%@-%d",
                   [NSString stringWithUTF8String:registry],
                   [NSString stringWithUTF8String:ordering],
                   supplement];
        }
        [items addRowWithKey:@"Format" stringValue:[NSString stringWithFormat:@"%@ (CID-Keyed, %@)",
                                                 [NSString stringWithUTF8String:FT_Get_Font_Format(ftFace)],
                                                 ROS]];
        
        
    }
    else {
        [items addRowWithKey:@"Format" stringValue:[NSString stringWithUTF8String:FT_Get_Font_Format(ftFace)]];
    }
    
    // Version and copyright
    FT_UInt nameCount = FT_Get_Sfnt_Name_Count(ftFace);
    NSString * version = nil;
    NSString * copyright = nil;
    for (FT_UInt i = 0; i < nameCount; ++ i) {
        FT_SfntName sfntName;
        error = FT_Get_Sfnt_Name(ftFace, i, &sfntName);
        if (sfntName.name_id == TT_NAME_ID_COPYRIGHT && !copyright) {
            copyright = SFNTNameGetValue(&sfntName);
        }
        if (sfntName.name_id == TT_NAME_ID_VERSION_STRING && !version) {
            version = SFNTNameGetValue(&sfntName);
        }
    }
    if (!version) version = @"Unknown";
    if (!copyright) copyright = @"Unknown";
    [items addRowWithKey:@"Version" stringValue:version];
    [items addRowWithKey:@"Copyright" stringValue:copyright];
    
    // Vender
    if (os2)
        [items addRowWithKey:@"Vender" stringValue:[NSString stringWithFormat:@"<a href=https://www.microsoft.com/typography/links/vendorlist.aspx>%@</a>", [[NSString alloc] initWithBytes:os2->achVendID length:4 encoding:NSASCIIStringEncoding]]];
    else
        [items addRowWithKey:@"Vender" stringValue:@"Unknown"];
    
    
    // Created and modified
    if (head) {
        NSInteger created = ((head->Created[0] & 0xFFFFFFFF) << 32) + (head->Created[1] & 0xFFFFFFFF);
        NSInteger modified = ((head->Modified[0] & 0xFFFFFFFF) << 32) + (head->Modified[1] & 0xFFFFFFFF);
        [items addRowWithKey:@"Created" stringValue:FTDateTimeToString(created)];
        [items addRowWithKey:@"Modified" stringValue:FTDateTimeToString(modified)];
    }
    else {
        [items addRowWithKey:@"Created" stringValue:@"Undefined"];
        [items addRowWithKey:@"Modified" stringValue:@"Undefined"];
    }
    
    [items addRowWithKey:@"Design Languages" stringValue:[face.attributes.designLanguages componentsJoinedByString:@", "]];
    
    // Unicode range
    if (os2) {
        [items addRowWithKey:@"Unicode Ranges" stringValue:[OS2GetUnicodeRanges(os2->ulUnicodeRange1,
                                                                             os2->ulUnicodeRange2,
                                                                             os2->ulUnicodeRange3,
                                                                             os2->ulUnicodeRange4) componentsJoinedByString:@"<br>"]];
    }
    else {
        [items addRowWithKey:@"Unicode Ranges" stringValue:@"Undefined"];
    }
    
    // Serif
    NSString * serifStr = nil;
    if (attributes.serifStyle == TypefaceSerifStyleSerif)
        serifStr = @"Serif";
    else if (attributes.serifStyle == TypefaceSerifStyleSansSerif)
        serifStr = @"Sans Serif";
    else
        serifStr = @"Undefined";
    [items addRowWithKey:@"Serif Style" stringValue: serifStr];
    
    // OT features
    NSMutableArray<NSString*> * sorted = [attributes.openTypeFeatures.allObjects mutableCopy];
    [sorted sortUsingComparator:^NSComparisonResult(id   obj1, id   obj2) {
        return [[obj1 text] compare:[obj2 text]];
    }];
    
    [items addRowWithKey:@"OpenType Features" stringValue: [sorted componentsJoinedByString:@", "]];
    
    [items addRowWithKey:@"Number Glyphs" unsignedIntegerValue:ftFace->num_glyphs];
    [items addRowWithKey:@"Units per EM" unsignedIntegerValue:ftFace->units_per_EM];
    
    // tables size
    if (FT_IS_SFNT(ftFace)) {
        NSMutableArray<NSString*> * tableNames = [[NSMutableArray<NSString*> alloc] init];
        FT_UInt tableIndex = 0;
        while (error != FT_Err_Table_Missing) {
            FT_ULong length = 0, tag = 0;
            error = FT_Sfnt_Table_Info(ftFace, tableIndex, &tag, &length);
            ++ tableIndex;
            if (!error) {
                // add tag
                //[items addRowWithKey:SFNTTagName(tag) unsignedIntegerValue:length];
                [tableNames addObject:[NSString stringWithFormat:@"%@ (%ld)", SFNTTagName(tag), length]];
            }
        }
        [items addRowWithKey:@"Tables (bytes)" stringValue:[tableNames componentsJoinedByString:@", "]];
    }
    
    return items;
}

- (HtmlTableRows*)loadFaceOfFace:(Typeface*)face ftFace:(FT_Face)ftFace {
    FT_Error error = 0;
    
    HtmlTableRows * items = [[HtmlTableRows alloc] init];
    [items addRowWithKey:@"Family" stringValue:face.attributes.familyName];
    [items addRowWithKey:@"Style"  stringValue:face.attributes.styleName];
    [items addRowWithKey:@"Postscript Name" stringValue:face.attributes.postscriptName];

    [items addRowWithKey:@"Face Index" unsignedIntegerValue: face.faceIndex];
    
    // Flags
    NSMutableArray<NSString*> * faceFlagsStr = [[NSMutableArray<NSString*> alloc] init]; {
        [faceFlagsStr addObject:[CharEncoding bitsStringOfNumber: ftFace->face_flags
                                                       count:15]];
        
        NSDictionary<NSNumber*, NSString*> * flagNumbers = @{
                                                             @(FT_FACE_FLAG_SCALABLE): @"SCALABLE",
                                                             @(FT_FACE_FLAG_FIXED_SIZES): @"FIXED_SIZES",
                                                             @(FT_FACE_FLAG_FIXED_WIDTH): @"FIXED_WIDTH",
                                                             @(FT_FACE_FLAG_SFNT): @"SFNT",
                                                             @(FT_FACE_FLAG_HORIZONTAL): @"HORIZONTAL",
                                                             @(FT_FACE_FLAG_VERTICAL): @"VERTICAL",
                                                             @(FT_FACE_FLAG_KERNING): @"KERNING",
                                                             @(FT_FACE_FLAG_FAST_GLYPHS): @"FAST_GLYPHS",
                                                             @(FT_FACE_FLAG_MULTIPLE_MASTERS): @"MULTIPLE_MASTERS",
                                                             @(FT_FACE_FLAG_GLYPH_NAMES): @"GLYPH_NAMES",
                                                             @(FT_FACE_FLAG_EXTERNAL_STREAM): @"EXTERNAL_STREAM",
                                                             @(FT_FACE_FLAG_HINTER): @"HINTER",
                                                             @(FT_FACE_FLAG_CID_KEYED): @"CID_KEYED",
                                                             @(FT_FACE_FLAG_TRICKY): @"TRICKY",
                                                             @(FT_FACE_FLAG_COLOR): @"COLOR",
                                                             };
        for (NSNumber * n in flagNumbers) {
            if (ftFace->face_flags & n.unsignedIntegerValue)
                [faceFlagsStr addObject:[NSString stringWithFormat:@"- %@", [flagNumbers objectForKey:n]]];
        }
        [items addRowWithKey:@"Face Flags" stringValue:[faceFlagsStr componentsJoinedByString:@"<br>"]];
    }
    NSMutableArray<NSString*> * styleFlagsStr = [[NSMutableArray<NSString*> alloc] init]; {
        [styleFlagsStr addObject:[CharEncoding bitsStringOfNumber: ftFace->style_flags
                                                           count:2]];
        
        NSDictionary<NSNumber*, NSString*> * flagNumbers = @{
                                                             @(FT_STYLE_FLAG_ITALIC): @"ITALIC",
                                                             @(FT_STYLE_FLAG_BOLD): @"BOLD",
                                                             };
        for (NSNumber * n in flagNumbers) {
            if (ftFace->style_flags & n.unsignedIntegerValue)
                [styleFlagsStr addObject:[NSString stringWithFormat:@"- %@", [flagNumbers objectForKey:n]]];
        }
        [items addRowWithKey:@"Style Flags" stringValue:[styleFlagsStr componentsJoinedByString:@"<br>"]];
    }
    
    [items addRowWithKey:@"File"   stringValue:face.fileURL.path];
    [items addRowWithKey:@"Format" stringValue:[NSString stringWithUTF8String:FT_Get_Font_Format(ftFace)]];
    { // CID
        FT_Bool isCID = false;
        error = FT_Get_CID_Is_Internally_CID_Keyed(ftFace, &isCID);
        [items addRowWithKey:@"CID-Keyed" boolValue:isCID];
        
        if (!error && isCID) {
            const char * registry = nil, *ordering = nil;
            FT_Int supplement = 0;
            error = FT_Get_CID_Registry_Ordering_Supplement(ftFace, &registry, &ordering, &supplement);
            if (error) {
                registry = "unknown";
                ordering = "unknown";
            }
            [items addRowWithKey:@"ROS" stringValue: [NSString stringWithFormat:@"%@-%@-%d",
                                                   [NSString stringWithUTF8String:registry],
                                                   [NSString stringWithUTF8String:ordering],
                                                   supplement]];
        }
    }
    
    // Multiple master/ font variation
    if (face.isOpenTypeVariation)
    {
        for (TypefaceAxis * axis in face.axises) {
            NSString * str = [NSString stringWithFormat:@"TAG: '%@'<br> Name: %@<br> Min:%f<br> Max:%f<br> Default:%f",
                              axis.tag,
                              axis.name,
                              FixedToFloat(axis.minValue),
                              FixedToFloat(axis.maxValue),
                              FixedToFloat(axis.defaultValue)];
            
            [items addRowWithKey:[NSString stringWithFormat:@"MM Axis %lu", (unsigned long)axis.index]
                     stringValue:str];
        }
        
        TypefaceVariation * currentVariation = face.currentVariation;
        if ([currentVariation isKindOfClass:[TypefaceNamedVariation class]]) {
            TypefaceNamedVariation * variation = (TypefaceNamedVariation*)currentVariation;
            NSString * str = [NSString stringWithFormat:@"Index: %lu<br> Name : %@<br> PS Name: %@<br> Coords: %@",
                              (unsigned long)variation.index,
                              variation.name,
                              variation.psName,
                              FixedArrayToString(variation.coordinates)];
            
            [items addRowWithKey:@"MM Current Variation" stringValue:str];
        }
        else {
            NSString * str = [NSString stringWithFormat:@"Coords: %@",
                              [currentVariation.coordinates componentsJoinedByString:@", "]];
            
            [items addRowWithKey:@"MM Current Variatoin" stringValue:str];
        }
        
        for (TypefaceNamedVariation * variation in face.namedVariations) {
            if (variation.isArtificial)
                continue;
            
            NSString * str = [NSString stringWithFormat:@"Name : %@<br> PS Name: %@<br> Coords: %@",
                              variation.name,
                              variation.psName,
                              FixedArrayToString(variation.coordinates)];
            
            [items addRowWithKey:[NSString stringWithFormat:@"MM Named Variation %lu", (unsigned long)variation.index]
                     stringValue:str];
        }
    }
    
    
    TypefaceCMap * cmap = face.currentCMap;
    [items addRowWithKey:@"Current CMap" stringValue: cmap.name];
    [items addRowWithKey:@"CMap Index" unsignedIntegerValue:face.currentCMapIndex];
    [items addRowWithKey:@"CMap Format" integerValue:FT_Get_CMap_Format(ftFace->charmap)];
    
    
    [items addRowWithKey:@"Has Glyph Names" boolValue: FT_HAS_GLYPH_NAMES(ftFace)];
    
    [items addRowWithKey:@"Number Faces" unsignedIntegerValue:ftFace->num_faces];
    [items addRowWithKey:@"Number Glyphs" unsignedIntegerValue:ftFace->num_glyphs];
    [items addRowWithKey:@"Units per EM" unsignedIntegerValue:ftFace->units_per_EM];
    [items addRowWithKey:@"Ascender" integerValue:ftFace->ascender];
    [items addRowWithKey:@"Descender" integerValue:ftFace->descender];
    [items addRowWithKey:@"Height" integerValue:ftFace->height];
    [items addRowWithKey:@"BBox" stringValue: [NSString stringWithFormat:@"min: %ld, %ld, max: %ld, %ld", ftFace->bbox.xMin, ftFace->bbox.yMin, ftFace->bbox.xMax, ftFace->bbox.yMax]];
    [items addRowWithKey:@"Max Advance Width" integerValue:ftFace->max_advance_width];
    [items addRowWithKey:@"Max Advance Height" integerValue:ftFace->max_advance_height];
    [items addRowWithKey:@"Underline Position" integerValue:ftFace->underline_position];
    [items addRowWithKey:@"Underline Thickness" integerValue:ftFace->underline_thickness];
    
    return items;
}

- (HtmlTableRows*)loadTableTablesOfFace:(Typeface*)face ftFace:(FT_Face)ftFace {
    HtmlTableRows * items = [[HtmlTableRows alloc] init];
    
    FT_Error error = 0;
    FT_UInt tableIndex = 0;
    while (error != FT_Err_Table_Missing) {
        FT_ULong length = 0, tag = 0;
        error = FT_Sfnt_Table_Info(ftFace, tableIndex, &tag, &length);
        ++ tableIndex;
        if (!error) {
            // add tag
            [items addRowWithKey:SFNTTagName(tag) unsignedIntegerValue:length];
        }
    }
    
    return items;
}

- (HtmlTableRows*)loadHeadOfTypeface:(Typeface*)face ftFace:(FT_Face)ftFace {
    HtmlTableRows * items = [[HtmlTableRows alloc] init];
    TT_Header * head = FT_Get_Sfnt_Table(ftFace, FT_SFNT_HEAD);
    if (head) {
        [items addRowWithKey:@"Table Version" uint32HexValue:head->Table_Version withPrefix:@"0x"];
        [items addRowWithKey:@"Font Version"  uint32HexValue:head->Font_Revision withPrefix:@"0x"];
        [items addRowWithKey:@"CheckSum Adjustment" uint32HexValue:head->CheckSum_Adjust withPrefix:@"0x"];
        [items addRowWithKey:@"Magic Number" uint32HexValue:head->Magic_Number withPrefix:@"0x"];
        
        [items addRowWithKey:@"Flags" stringValue:[NSString stringWithFormat:@"0x%04hX<br/>%@",
                                                   head->Flags,
                                                   [HeadGetFlagFullDescription(head->Flags) stringByReplacingOccurrencesOfString:@";" withString:@"<br/>"]]];
        
        [items addRowWithKey:@"Units Per EM" integerValue:head->Units_Per_EM];
        
        NSInteger created = ((head->Created[0] & 0xFFFFFFFF) << 32) + (head->Created[1] & 0xFFFFFFFF);
        NSInteger modified = ((head->Modified[0] & 0xFFFFFFFF) << 32) + (head->Modified[1] & 0xFFFFFFFF);
        
        [items addRowWithKey:@"Created" stringValue:FTDateTimeToString(created)];
        [items addRowWithKey:@"Modified" stringValue:FTDateTimeToString(modified)];
        [items addRowWithKey:@"xMin" integerValue:head->xMin];
        [items addRowWithKey:@"yMin" integerValue:head->yMin];
        [items addRowWithKey:@"xMax" integerValue:head->xMax];
        [items addRowWithKey:@"yMax" integerValue:head->yMax];
        
        [items addRowWithKey:@"Mac Style" stringValue:[NSString stringWithFormat:@"0x%04hX (%@)",
                                                       head->Mac_Style,
                                                       HeadGetMacStyleDescription(head->Mac_Style)]];
        [items addRowWithKey:@"Lowest Rec PPEM" integerValue:head->Lowest_Rec_PPEM];
        [items addRowWithKey:@"Font Direction" integerValue:head->Font_Direction];
        [items addRowWithKey:@"Index To Loc Format" integerValue:head->Index_To_Loc_Format];
        [items addRowWithKey:@"Glyph Data Format" integerValue:head->Glyph_Data_Format];
    }
    
    return items;
}

- (HtmlTableRows*)loadHheaOfTypeface:(Typeface*)face ftFace:(FT_Face)ftFace {
    HtmlTableRows * items = [[HtmlTableRows alloc] init];
    
    TT_HoriHeader * hhea = FT_Get_Sfnt_Table(ftFace, FT_SFNT_HHEA);
    if (hhea) {
        [items addRowWithKey:@"Version" uint32HexValue:hhea->Version withPrefix:@"0x"];
        [items addRowWithKey:@"Ascender" integerValue:hhea->Ascender];
        [items addRowWithKey:@"Descender" integerValue:hhea->Descender];
        [items addRowWithKey:@"Line Gap" integerValue:hhea->Line_Gap];
        [items addRowWithKey:@"Advance Width Max" unsignedIntegerValue:hhea->advance_Width_Max];
        [items addRowWithKey:@"Min Left Side Bearing" integerValue:hhea->min_Left_Side_Bearing];
        [items addRowWithKey:@"Min Right Side Bearing" integerValue:hhea->min_Right_Side_Bearing];
        [items addRowWithKey:@"xMax Extent" integerValue:hhea->xMax_Extent];
        [items addRowWithKey:@"Caret Slope Rise" integerValue:hhea->caret_Slope_Rise];
        [items addRowWithKey:@"Caret Slope Run" integerValue:hhea->caret_Slope_Run];
        [items addRowWithKey:@"Caret Offset" integerValue:hhea->caret_Offset];
        [items addRowWithKey:@"Metric Data Format" integerValue:hhea->metric_Data_Format];
        [items addRowWithKey:@"Number Of HMetrics" unsignedIntegerValue:hhea->number_Of_HMetrics];
        
        [items addRowWithKey:@"<i>Long Metrics</i>" uint32HexValue:(NSUInteger)(hhea->long_metrics) withPrefix:@"0x"];
        [items addRowWithKey:@"<i>Short Metrics</i>" uint32HexValue:(NSUInteger)(hhea->short_metrics) withPrefix:@"0x"];
        
    }
    return items;
}

- (HtmlTableRows*)loadHmtxOfTypeface:(Typeface*)face ftFace:(FT_Face)ftFace {
    HtmlTableRows * items = [[HtmlTableRows alloc] init];
    
    FT_Error error = 0;
    FT_ULong length = 0;
    
    TT_HoriHeader * hhea = FT_Get_Sfnt_Table(ftFace, FT_SFNT_HHEA);
    
    typedef struct {
        uint16_t advanceWidth;
        int16_t lsb;
    } HorMetric;
    
    NSUInteger rowsNumberLimit = 3000;
    BOOL rowsNumberLimitReach = NO;
    
    error = FT_Load_Sfnt_Table(ftFace, 'hmtx', 0, 0, &length);
    if (!error && hhea) {
        void * tableData = malloc(length);
        error = FT_Load_Sfnt_Table(ftFace, 'hmtx', 0, tableData, &length);
        if (!error) {
            HorMetric * metricHead = (HorMetric*)tableData;
            FT_UShort index = 0;
            for (; index < hhea->number_Of_HMetrics; ++ index) {
                if (index > rowsNumberLimit) {
                    rowsNumberLimitReach = YES;
                    break;
                }
                HorMetric * metric = metricHead + index;
                NSString * glyphName = [face composedNameOfGlyph:index];
                if (!glyphName)
                    glyphName = [NSString stringWithFormat:@"glyph#%d", index];
                
                [items addRowWithKey:[NSString stringWithFormat:@"%d", index]
                         stringValue:[NSString stringWithFormat:@"%@, advance %u, lsb %d",
                                      glyphName,
                                      (uint16_t)SWAP_ENDIAN_16(metric->advanceWidth),
                                      (int16_t)SWAP_ENDIAN_16(metric->lsb)
                                      ]];
                
                
            }
            
            TT_MaxProfile * maxp = FT_Get_Sfnt_Table(ftFace, FT_SFNT_MAXP);
            if (maxp) {
                for (; index < maxp->numGlyphs; ++ index) {
                    if (index > rowsNumberLimit) {
                        rowsNumberLimitReach = YES;
                        break;
                    }
                    NSString * glyphName = [face composedNameOfGlyph:index];
                    if (!glyphName)
                        glyphName = [NSString stringWithFormat:@"glyph#%d", index];
                    
                    int16_t * lsb = (int16_t*)(metricHead + hhea->number_Of_HMetrics) + index;

                    [items addRowWithKey:[NSString stringWithFormat:@"%d", index]
                             stringValue:[NSString stringWithFormat:@"%@, lsb %d",
                                          glyphName,
                                          (int16_t)SWAP_ENDIAN_16(*lsb)
                                          ]];
                }
            }
            
            if (rowsNumberLimitReach) {
                [items addRowWithKey:@"<i>Too Many Glyphs</i>"
                         stringValue:[NSString stringWithFormat:@"<i>showing %ld, more glyphs ommited</i>", rowsNumberLimit]];
            }
        }
        free(tableData);
    }
    
    return items;
}

- (HtmlTableRows*)loadMaxpOfTypeface:(Typeface*)face ftFace:(FT_Face)ftFace {
    HtmlTableRows * items = [[HtmlTableRows alloc] init];
    TT_MaxProfile * maxp = FT_Get_Sfnt_Table(ftFace, FT_SFNT_MAXP);
    if (maxp) {
        [items addRowWithKey:@"version" uint32HexValue:maxp->version withPrefix:@"0x"];
        [items addRowWithKey:@"numGlyphs" unsignedIntegerValue:maxp->numGlyphs];
        [items addRowWithKey:@"maxPoints" unsignedIntegerValue:maxp->maxPoints];
        [items addRowWithKey:@"maxContours" unsignedIntegerValue:maxp->maxContours];
        [items addRowWithKey:@"maxCompositePoints" unsignedIntegerValue:maxp->maxCompositePoints];
        [items addRowWithKey:@"maxCompositeContours" unsignedIntegerValue:maxp->maxCompositeContours];
        [items addRowWithKey:@"maxZones" unsignedIntegerValue:maxp->maxZones];
        [items addRowWithKey:@"maxTwilightPoints" unsignedIntegerValue:maxp->maxTwilightPoints];
        [items addRowWithKey:@"maxStorage" unsignedIntegerValue:maxp->maxStorage];
        [items addRowWithKey:@"maxFunctionDefs" unsignedIntegerValue:maxp->maxFunctionDefs];
        [items addRowWithKey:@"maxInstructionDefs" unsignedIntegerValue:maxp->maxInstructionDefs];
        [items addRowWithKey:@"maxStackElements" unsignedIntegerValue:maxp->maxStackElements];
        [items addRowWithKey:@"maxSizeOfInstructions" unsignedIntegerValue:maxp->maxSizeOfInstructions];
        [items addRowWithKey:@"maxComponentElements" unsignedIntegerValue:maxp->maxComponentElements];
        [items addRowWithKey:@"maxComponentDepth" unsignedIntegerValue:maxp->maxComponentDepth];
    }
    
    return items;
}

- (HtmlTableRows*)loadOS2OfTypeface:(Typeface*)face ftFace:(FT_Face)ftFace {
    HtmlTableRows * items = [[HtmlTableRows alloc] init];
    TT_OS2 * os2 = FT_Get_Sfnt_Table(ftFace, FT_SFNT_OS2);
    if (os2) {
        [items addRowWithKey:@"version" unsignedIntegerValue:os2->version];
        [items addRowWithKey:@"xAvgCharWidth" integerValue:os2->xAvgCharWidth];
        [items addRowWithKey:@"usWeightClass" stringValue:[NSString stringWithFormat:@"%d, %@", os2->usWeightClass, OS2GetWeightClassName(os2->usWeightClass)]];
        [items addRowWithKey:@"usWidthClass" stringValue:[NSString stringWithFormat:@"%d, %@", os2->usWidthClass, OS2GetWidthClassName(os2->usWidthClass)]];
        [items addRowWithKey:@"fsType" stringValue:[NSString stringWithFormat:@"0x%04hX <br> %@", os2->fsType,
                                                    [OS2GetFsTypeDescription(os2->fsType) stringByReplacingOccurrencesOfString:@";" withString:@"<br>"]]]
        ;
        [items addRowWithKey:@"ySubscriptXSize" integerValue:os2->ySubscriptXSize];
        [items addRowWithKey:@"ySubscriptYSize" integerValue:os2->ySubscriptYSize];
        [items addRowWithKey:@"ySubscriptXOffset" integerValue:os2->ySubscriptXOffset];
        [items addRowWithKey:@"ySubscriptYOffset" integerValue:os2->ySubscriptYOffset];
        [items addRowWithKey:@"ySuperscriptXSize" integerValue:os2->ySuperscriptXSize];
        [items addRowWithKey:@"ySuperscriptYSize" integerValue:os2->ySuperscriptYSize];
        [items addRowWithKey:@"ySuperscriptXOffset" integerValue:os2->ySuperscriptXOffset];
        [items addRowWithKey:@"ySuperscriptYOffset" integerValue:os2->ySuperscriptYOffset];
        [items addRowWithKey:@"yStrikeoutSize" integerValue:os2->yStrikeoutSize];
        [items addRowWithKey:@"yStrikeoutPosition" integerValue:os2->yStrikeoutPosition];
        
        // Family class
        NSUInteger familyClass = ((os2->sFamilyClass & 0xFF00) >> 8);
        NSUInteger subFamilyClass = (os2->sFamilyClass & 0xFF);
        
        [items addRowWithKey:@"sFamilyClass" stringValue: [NSString stringWithFormat:@"%ld, %ld (%@)",
                                                        familyClass,
                                                        subFamilyClass,
                                                        OS2GetFamilyClassFullName(os2->sFamilyClass)]];
        
        // panose
        {
            NSMutableArray<NSString*> * panose = [[NSMutableArray<NSString*> alloc] init];
            NSMutableString * hex = [[NSMutableString alloc] init];
            for (NSUInteger i = 0; i < 10; ++ i) {
                if (i) [hex appendString:@" "];
                [hex appendFormat:@"%02hX", (unsigned short)os2->panose[i]];
            }
            [panose addObject:hex];
            [panose addObject:[NSString stringWithFormat:@"Family: %@", OS2GetPanoseFamilyType(os2->panose[0])]];
            [panose addObject:[NSString stringWithFormat:@"Serif: %@", OS2GetPanoseSerifType(os2->panose[1])]];
            [panose addObject:[NSString stringWithFormat:@"Weight: %@", OS2GetPanoseWeight(os2->panose[2])]];
            [panose addObject:[NSString stringWithFormat:@"Proportion: %@", OS2GetPanoseProportion(os2->panose[3])]];
            [panose addObject:[NSString stringWithFormat:@"Contrast: %@", OS2GetPanoseContrast(os2->panose[4])]];
            [panose addObject:[NSString stringWithFormat:@"Stroke Variation: %@", OS2GetPanoseStrokeVariation(os2->panose[5])]];
            [panose addObject:[NSString stringWithFormat:@"Arm: %@", OS2GetPanoseArmStyle(os2->panose[6])]];
            [panose addObject:[NSString stringWithFormat:@"Letter: %@", OS2GetPanoseLetterform(os2->panose[7])]];
            [panose addObject:[NSString stringWithFormat:@"Midline: %@", OS2GetPanoseMidline(os2->panose[8])]];
            [panose addObject:[NSString stringWithFormat:@"X Height: %@", OS2GetPanoseXHeight(os2->panose[9])]];
            
            [items addRowWithKey:@"PANOSE" stringValue:[panose componentsJoinedByString:@"<br>"]];
        }
        
        // unicode range
        [items addRowWithKey:@"ulUnicodeRange1" bitsValue:os2->ulUnicodeRange1 count:32];
        [items addRowWithKey:@"ulUnicodeRange2" bitsValue:os2->ulUnicodeRange2 count:32];
        [items addRowWithKey:@"ulUnicodeRange3" bitsValue:os2->ulUnicodeRange3 count:32];
        [items addRowWithKey:@"ulUnicodeRange4" bitsValue:os2->ulUnicodeRange4 count:32];
        
        [items addRowWithKey:@"<i>Unicode Ranges</i>"
              stringValue:[OS2GetUnicodeRanges(os2->ulUnicodeRange1,
                                               os2->ulUnicodeRange2,
                                               os2->ulUnicodeRange3,
                                               os2->ulUnicodeRange4) componentsJoinedByString:@"<br>"]];
        
        // Vender
        [items addRowWithKey:@"achVendID" stringValue:[[NSString alloc] initWithBytes:os2->achVendID length:4 encoding:NSASCIIStringEncoding]];
        
        [items addRowWithKey:@"fsSelection" stringValue: [NSString stringWithFormat:@"0x%04hX (%@)", os2->fsSelection, OS2GetFsSelectionDescription(os2->fsSelection)]];
        [items addRowWithKey:@"usFirstCharIndex" unsignedIntegerValue:os2->usFirstCharIndex];
        [items addRowWithKey:@"usLastCharIndex" unsignedIntegerValue:os2->usLastCharIndex];
        [items addRowWithKey:@"sTypoAscender" integerValue:os2->sTypoAscender];
        [items addRowWithKey:@"sTypoDescender" integerValue:os2->sTypoDescender];
        [items addRowWithKey:@"sTypoLineGap" integerValue:os2->sTypoLineGap];
        [items addRowWithKey:@"usWinAscent" unsignedIntegerValue:os2->usWinAscent];
        [items addRowWithKey:@"usWinDescent" unsignedIntegerValue:os2->usWinDescent];
        
        if (os2->version >= 1) {
            [items addRowWithKey:@"ulCodePageRange1" bitsValue:os2->ulCodePageRange1 count:32];
            [items addRowWithKey:@"ulCodePageRange2" bitsValue:os2->ulCodePageRange2 count:32];
            
            [items addRowWithKey:@"<i>CodePage Ranges</i>"
                  stringValue:[OS2GetCodePageRanges(os2->ulCodePageRange1,os2->ulCodePageRange2) componentsJoinedByString:@"<br>"]];
        }
        
        if (os2->version >= 2) {
            [items addRowWithKey:@"sxHeight" integerValue:os2->sxHeight];
            [items addRowWithKey:@"sCapHeight" integerValue:os2->sCapHeight];
            [items addRowWithKey:@"usDefaultChar" unsignedIntegerValue:os2->usDefaultChar];
            [items addRowWithKey:@"usBreakChar" unsignedIntegerValue:os2->usBreakChar];
            [items addRowWithKey:@"usMaxContext" unsignedIntegerValue:os2->usMaxContext];
        }
        
        if (os2->version >= 5) {
            [items addRowWithKey:@"usLowerOpticalPointSize" unsignedIntegerValue:os2->usLowerOpticalPointSize];
            [items addRowWithKey:@"usUpperOpticalPointSize" unsignedIntegerValue:os2->usUpperOpticalPointSize];
        }
    }
    
    return items;
}

- (HtmlTableRows*)loadNameTableOfFace:(Typeface*)face ftFace:(FT_Face)ftFace {
    HtmlTableRows * items = [[HtmlTableRows alloc] init];
    FT_Error error = 0;
    FT_UInt count = FT_Get_Sfnt_Name_Count(ftFace);
    
    for (FT_UInt i = 0; i < count; ++ i) {
        FT_SfntName sfntName;
        error = FT_Get_Sfnt_Name(ftFace, i, &sfntName);
        
        [items addRowWithKey:[NSString stringWithFormat:@"(%d-%d %@) %d %@", sfntName.platform_id, sfntName.encoding_id, SFNTNameGetLanguage(&sfntName, ftFace),
                              sfntName.name_id,
                           SFNTNameGetName(&sfntName) ]
              stringValue:SFNTNameGetValue(&sfntName)];
    }
    return items;
}

- (HtmlTableRows*)loadPostTableOfFace:(Typeface*)face ftFace:(FT_Face)ftFace {
    HtmlTableRows * items = [[HtmlTableRows alloc] init];
    TT_Postscript * post = FT_Get_Sfnt_Table(ftFace, FT_SFNT_POST);
    if (post) {
        [items addRowWithKey:@"FormatType" uint32HexValue:post->FormatType withPrefix:@"0x"];
        [items addRowWithKey:@"italicAngle" integerValue:post->italicAngle];
        [items addRowWithKey:@"underlinePosition" integerValue:post->underlinePosition];
        [items addRowWithKey:@"underlineThickness" integerValue:post->underlineThickness];
        [items addRowWithKey:@"isFixedPitch" boolValue:post->isFixedPitch];
        [items addRowWithKey:@"minMemType42" unsignedIntegerValue:post->minMemType42];
        [items addRowWithKey:@"maxMemType42" unsignedIntegerValue:post->maxMemType42];
        [items addRowWithKey:@"minMemType1" unsignedIntegerValue:post->minMemType1];
        [items addRowWithKey:@"maxMemType1" unsignedIntegerValue:post->maxMemType1];
        
        // load names
        FT_ULong postLength = 0;
        FT_Error error = FT_Load_Sfnt_Table(ftFace, TF_TABLE_POST, 0, 0, &postLength);
        if (!error) {
            uint32_t version = 0;
            FT_ULong versionLen = 4;
            error = FT_Load_Sfnt_Table(ftFace, TF_TABLE_POST, 0, (FT_Byte*)&version, &versionLen);
            if (!error) {
                [items addRowWithKey:@"Version" uint32HexValue:SWAP_ENDIAN_32(version) withPrefix:@"0x"];
                
                if (SWAP_ENDIAN_32(version) == 0x00020000) {
                    void * buffer = malloc(postLength);
                    error = FT_Load_Sfnt_Table(ftFace, TF_TABLE_POST, 0, buffer, &postLength);
                    if (!error) {
                        void * base = buffer + 8 * sizeof(uint32_t);
                        uint16_t numberGlyphs = SWAP_ENDIAN_16(*(uint16_t*)base);
                        uint16_t * glyphNameIndexBase = base + sizeof(uint16_t);
                        
                        uint16_t macGlyphNameStart = 258;
                        int8_t * namesBase = base + sizeof(uint16_t) + numberGlyphs * sizeof(uint16_t);
                        int8_t * p = namesBase;
                        
                        uint16_t numNames = 0;
                        while ((p - (int8_t*)buffer) < postLength) {
                            p += (*p + 1);
                            ++ numNames;
                        }
                        if (numNames) {
                            p = namesBase;
                            int8_t * * nameArray = malloc(numNames * sizeof(int8_t *));
                            for (uint16_t index = 0; index < numNames; ++ index) {
                                nameArray[index] = p;
                                p += (*p + 1);
                            }
                            
                            //for (
                            for (uint16_t index = 0; index < numberGlyphs; ++ index) {
                                uint16_t nameIndex = SWAP_ENDIAN_16(*(glyphNameIndexBase + index));
                                
                                NSString * glyphName = nil;
                                if (nameIndex < macGlyphNameStart) {
                                    glyphName = PostGetMacintoshGlyphName(nameIndex);
                                }
                                else {
                                    nameIndex -= macGlyphNameStart;
                                    if (nameIndex >= numNames)
                                        break;
                                    int8_t * name = nameArray[nameIndex];
                                    glyphName = [[NSString alloc] initWithBytes:name + 1 length:*name encoding:NSASCIIStringEncoding];
                                }
                                
                                [items addRowWithKey:[NSString stringWithFormat:@"%d", index]
                                         stringValue:glyphName];
                            }
                            free(nameArray);
                        }
                    }
                    free(buffer);
                }
            }
        }
    }
    return items;
}

- (HtmlTableRows*)loadGSUBTableOfFace:(Typeface*)face ftFace:(FT_Face)ftFace {
    return [self loadOTTable:OT_TAG_GSUB OfFace:face ftFace:ftFace];
}

- (HtmlTableRows*)loadGPOSTableOfFace:(Typeface*)face ftFace:(FT_Face)ftFace {
    return [self loadOTTable:OT_TAG_GPOS OfFace:face ftFace:ftFace];
}

- (HtmlTableRows*)loadOTTable:(ot_tag_t) table OfFace:(Typeface*)face ftFace:(FT_Face)ftFace {
    HtmlTableRows * items = [[HtmlTableRows alloc] init];

    Shapper * shapper = [face createShapper];
    hb_face_t * hbFace = (hb_face_t*)[shapper nativeFace];
    
    // script/langsys and features
    for (TypefaceTag * script in [shapper scriptsInTable:table]) {
        for (TypefaceTag * lang in [shapper languagesOfScript: script inTable:table]) {
            NSArray<OpenTypeFeatureTag*> * features = [shapper featuresOfScript:script language:lang inTable:table];
            NSMutableArray<NSString*> * featureStrs = [[NSMutableArray<NSString*>  alloc] init];
            for (OpenTypeFeatureTag * feature in features) {
                NSArray<NSNumber*> * lookups = [shapper lookupIndexesOfFeature:feature script:script language:lang inTable:table];
                NSUInteger featureIndex = [shapper indexOfFeature:feature script:script language:lang inTable:table];
                
                [featureStrs addObject:[NSString stringWithFormat:@"%@(%ld), lookups {%@}", feature, featureIndex, [lookups componentsJoinedByString:@", "]]];
            }
            [items addRowWithKey:[NSString stringWithFormat:@"%@ %@ (%@-%@)", OTGetScriptFullName(script.text), OTGetLanguageFullName(lang.text), script, lang]
                  stringValue:[featureStrs componentsJoinedByString:@"<br/> "]];
        }
    }
    
    // features
    unsigned int featureCount = hb_ot_layout_table_get_feature_tags(hbFace, table, 0, NULL, NULL);
    hb_tag_t * hbTags = (hb_tag_t*)malloc(featureCount * sizeof(hb_tag_t));
    hb_ot_layout_table_get_feature_tags(hbFace, table, 0, &featureCount, hbTags);
    for (unsigned int featureIndex = 0; featureIndex < featureCount; ++ featureIndex) {
        hb_tag_t featureTag = hbTags[featureIndex];
        unsigned int lookupCount = hb_ot_layout_feature_get_lookups(hbFace, table, featureIndex, 0, 0, 0);
        unsigned int * lookupIndexes = (unsigned int*)malloc(lookupCount * sizeof(unsigned int));
        hb_ot_layout_feature_get_lookups(hbFace, table, featureIndex, 0, &lookupCount, lookupIndexes);
        
        NSMutableArray<NSNumber*>* lookups = [[NSMutableArray<NSNumber*> alloc] init];
        for (unsigned int i = 0; i < lookupCount; ++ i)
            [lookups addObject:[NSNumber numberWithUnsignedInteger:lookupIndexes[i]]];
        
        [items addRowWithKey:[NSString stringWithFormat:@"Feature %u", featureIndex]
              stringValue:[NSString stringWithFormat:@"%@, lookups {%@}", [TypefaceTag codeToText:featureTag], [lookups componentsJoinedByString:@", "]]];
        
        free(lookupIndexes);
    }
    free(hbTags);
    
#if HAVE_HARFBUZZ_SOURCE
    // lookups
    unsigned int lookupCount = hb_ot_layout_table_get_lookup_count(hbFace, table);
    for (unsigned int lookupIndex = 0; lookupIndex < lookupCount; ++ lookupIndex) {
        
        unsigned int type = hb_ot_layout_lookup_get_type(hbFace, table, lookupIndex);
        unsigned int subTableCount = hb_ot_layout_lookup_get_subtable_count(hbFace, table, lookupIndex);
        
        uint16_t flag = hb_ot_layout_lookup_get_flag(hbFace, table, lookupIndex);
        uint16_t markFilteringSet = hb_ot_layout_lookup_get_mark_filtering_set(hbFace, table, lookupIndex);
        

        NSMutableArray<HtmlTableRow*> * subTableRows = [[NSMutableArray<HtmlTableRow*> alloc] init];
        
        for (unsigned int subTableIndex = 0; subTableIndex < subTableCount; ++ subTableIndex) {
            hb_set_t * coverage = hb_ot_layout_lookup_get_subtable_coverage(hbFace, table, lookupIndex, 0);
            NSString * text = [NSString stringWithFormat:@"Converage %@", HBSet2NSSet(coverage)];
            [subTableRows addObject:MakeHtmlTableRow([NSString stringWithFormat:@"SubTable %d", subTableIndex], text)];
            hb_set_destroy(coverage);
        }
        
        HtmlTableViewAppearance * appearance = [[HtmlTableViewAppearance alloc] init];
        appearance.dark = NO;
        appearance.fontSize = 9;
        NSString * subTableDescription = [HtmlTableView htmlTableWithRows:subTableRows appearance:appearance];
        
        [items addRowWithKey:[NSString stringWithFormat:@"Lookup %d", lookupIndex]
              stringValue:[NSString stringWithFormat:@"Name: %@<br/>Type: %d<br/>Flag: %@<br/>SubTables:%d <br/>%@",
                           (table == OT_TAG_GSUB? OTGetGSUBLookupName(type): OTGetGPOSLookupName(type)),
                           type,
                           OTGetLookupFlagDescription(flag),
                           subTableCount,
                           subTableDescription
                           ]];
        
        
#if DEBUG
        if (1)
        {
            hb_set_t * glyphs = hb_set_create();
            hb_ot_layout_lookup_substitute_closure(hbFace, lookupIndex, glyphs);
            NSLog(@"%@", HBSet2NSSet(glyphs));
        }
        
        if (0)
        {
            
            hb_set_t * glyphs_before = hb_set_create();
            hb_set_t * glyphs_input = hb_set_create();
            hb_set_t * glyphs_after = hb_set_create();
            hb_set_t * glyphs_output = hb_set_create();
            
            // Not really usefull
            hb_ot_layout_lookup_collect_glyphs(hbFace, table, lookupIndex, glyphs_before, glyphs_input, glyphs_after, glyphs_output);
            NSLog(@"%@", HBSet2NSSet(glyphs_before));
            NSLog(@"%@", HBSet2NSSet(glyphs_input));
            NSLog(@"%@", HBSet2NSSet(glyphs_after));
            NSLog(@"%@", HBSet2NSSet(glyphs_output));
            
            hb_set_destroy(glyphs_before);
            hb_set_destroy(glyphs_input);
            hb_set_destroy(glyphs_after);
            hb_set_destroy(glyphs_output);
        }
#endif
    }
#endif
    return items;
}



#pragma mark *** Actions ***
- (IBAction)doChangeCurrentSegment:(id)sender {
    self.currrentTable = [self getTableAtIndex: self.infoSegments.selectedSegment];
    
    [self.tableView reloadData];
}


- (HtmlTableRows *)currentRows {
    return [self.tfDict objectForKey:[NSNumber numberWithUnsignedInteger:self.currrentTable]];
}


- (NSUInteger)getTableAtIndex:(NSUInteger)index {
    NSUInteger tables[] = {TF_TABLE_BASIC, TF_TABLE_FACE,
        TF_TABLE_HEAD,
        TF_TABLE_HHEA,
        TF_TABLE_HMTX,
        TF_TABLE_MAXP,
        TF_TABLE_NAME,
        TF_TABLE_POST,
        TF_TABLE_OS2,
        TF_TABLE_GSUB,
        TF_TABLE_GPOS,
    };
    return tables[index];
}

-(NSUInteger)numberOfRowsInHtmlTableView:(HtmlTableView*)view {
    return self.currentRows.count;
}

- (HtmlTableRow*)htmlTableView:(HtmlTableView *)view rowAtIndex:(NSUInteger)index {
    return [self.currentRows objectAtIndex:index];
}

-(HtmlTableViewAppearance*)appearanceOfHtmlTableView:(HtmlTableView *)view {
    HtmlTableViewAppearance * appearance = [[HtmlTableViewAppearance alloc] init];
    appearance.dark = isDarkMode();
    appearance.keyColumnSize = 30;
    return appearance;
}
@end
