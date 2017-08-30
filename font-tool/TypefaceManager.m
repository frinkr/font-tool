//
//  TypefaceManager.m
//  tx-research
//
//  Created by Yuqing Jiang on 6/15/17.
//
//
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_CID_H
#include FT_SFNT_NAMES_H
#include FT_TRUETYPE_IDS_H
#include FT_TRUETYPE_TABLES_H
#include FT_SIZES_H

#import "TypefaceManager.h"
#import "TypefaceNames.h"

#pragma mark ##### TypefaceAttributesCache #####

NSString * TMProgressNotification = @"TMProgressNotification";
NSString * TMProgressNotificationFileKey = @"TMProgressNotificationFileKey";
NSString * TMProgressNotificationTotalKey = @"TMProgressNotificationTotalKey";
NSString * TMProgressNotificationCurrentKey = @"TMProgressNotificationCurrentKey";

static TypefaceAttributesCache * typefaceAttributesCache;

@interface TypefaceAttributesCache() {
    NSMutableDictionary<NSString *, TypefaceAttributes *> * cache;
}
@end

@implementation TypefaceAttributesCache

- (instancetype)init {
    if (self = [super init]) {
        NSData *serialized = [[NSUserDefaults standardUserDefaults] objectForKey:@"TypefaceAttributesCache"];
        if (serialized)
            cache = [[NSKeyedUnarchiver unarchiveObjectWithData: serialized] mutableCopy];
        if (!cache)
            cache = [[NSMutableDictionary<NSString *, TypefaceAttributes *> alloc] init];
        
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(appWillTerminate:)
                   name:NSApplicationWillTerminateNotification
                 object:nil];
        
    }
    return self;
}

- (void)appWillTerminate:(NSNotification*)notification {
    NSData *serialized = [NSKeyedArchiver archivedDataWithRootObject:cache];
    [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:@"TypefaceAttributesCache"];
}


- (TypefaceAttributes*)attributesOfTypefaceDescriptor:(TypefaceDescriptor*)descriptor {
    return [cache objectForKey:[self userDefaultsKeyOfTypefaceDescriptor:descriptor]];
}

- (void)setAttributes:(TypefaceAttributes*)attributes ofTypeface:(TypefaceDescriptor*)descriptor {
    [cache setObject:attributes forKey:[self userDefaultsKeyOfTypefaceDescriptor:descriptor]];
}

- (NSString*)userDefaultsKeyOfTypefaceDescriptor:(TypefaceDescriptor*)descriptor{
    return [NSString stringWithFormat:@"%@_%@", descriptor.family, descriptor.style];
}

+(TypefaceAttributesCache*)standardCache {
    if (!typefaceAttributesCache) {
        typefaceAttributesCache = [[TypefaceAttributesCache alloc] init];
    }
    return typefaceAttributesCache;
}
@end

@interface TMTypeface()
- (instancetype)initWithFamilyName:(NSString*)familyName styleName:(NSString*)styleName;
@end

@implementation TMTypeface
- (instancetype)initWithFamilyName:(NSString*)familyName styleName:(NSString*)styleName {
    if (self = [super init]) {
        self.familyName = familyName;
        self.styleName = styleName;
    }
    return self;
}

- (NSComparisonResult)compare:(TMTypeface*)other {
    NSComparisonResult result = [self.familyName compare:other.familyName];
    if (result == NSOrderedSame) {
        if ([self.styleName isEqualToString:@"Regular"])
            return NSOrderedAscending;
        return [self.styleName compare:other.styleName];
    }
    return result;
    
}

- (TypefaceDescriptor*)createTypefaceDescriptor {
    return [TypefaceDescriptor descriptorWithFamily:self.familyName style:self.styleName];
}

- (Typeface*)createTypeface {
    return [[Typeface alloc] initWithDescriptor:[self createTypefaceDescriptor]];
}

@end

@implementation TMTypeface(NSFont)

-(NSFont*)createFontWithSize:(CGFloat)size {
    NSFontDescriptor * descriptor = [[NSFontDescriptor alloc] initWithFontAttributes:@{
                                                                                       NSFontFamilyAttribute: self.familyName,
                                                                                       NSFontFaceAttribute: self.styleName,
                                                                                       }];
    return [NSFont fontWithDescriptor:descriptor size:size];
}

@end

@interface TMTypefaceFamily ()
- (instancetype)initWithFamilyName:(NSString*)familyName;
@end

@implementation TMTypefaceFamily
- (instancetype)initWithFamilyName:(NSString*)familyName {
    if (self = [super init]) {
        self.familyName = familyName;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (self == other)
        return YES;
    if (![other isKindOfClass:[TMTypefaceFamily class]])
        return NO;
    return [self isEqualToFamily:other];
}

- (BOOL)isEqualToFamily:(TMTypefaceFamily*)other {
    return [self.familyName isEqualToString:other.familyName];
}

- (BOOL)hash {
    return [self.familyName hash];
}

- (NSComparisonResult)compare:(TMTypefaceFamily*)other {
    return [self.familyName compare:other.familyName];
}
@end

@interface TypefaceManager()
{
    FT_Library  ftLib;
}
@end

static TypefaceManager * defaultTypefaceManager;

@interface TypefaceManager() {
    NSMutableDictionary<TypefaceDescriptor*, TypefaceAttributes*> * _fileDescriptorAttributesMapping;
    
    NSMutableDictionary<TypefaceDescriptor*, TypefaceDescriptor*> * _nameDescriptorFileMapping;
    NSMutableArray<TMTypefaceFamily*> * _typefaceFimilies;
}

@end

@implementation TypefaceManager

- (instancetype)init {
    if (self = [super init]) {
        ftLib = 0;
        [self initFTLib];
    }
    return self;
}

-(void)loadFontDatabase {
    NSData *serialized = [[NSUserDefaults standardUserDefaults] objectForKey:@"TypefaceFontList"];
    if (serialized)
        _fileDescriptorAttributesMapping = [[NSKeyedUnarchiver unarchiveObjectWithData: serialized] mutableCopy];
    
    NSUInteger databaseHash = [[NSUserDefaults standardUserDefaults] integerForKey:@"TypefaceFontListHash"];;
    
    NSMutableSet<NSString*> * allFontFiles = [[NSMutableSet<NSString*> alloc] init]; {
        NSArray<NSString*> * allFontNamess = [[NSFontManager sharedFontManager] availableFonts];
        for (NSString * fontName in allFontNamess) {
            CTFontDescriptorRef fontDescriptorRef = CTFontDescriptorCreateWithNameAndSize((CFStringRef)fontName, 12);
            CFURLRef url = (CFURLRef)CTFontDescriptorCopyAttribute(fontDescriptorRef, kCTFontURLAttribute);
            
            NSString *fontPath = [NSString stringWithString:[(NSURL *)CFBridgingRelease(url) path]];
            CFRelease(fontDescriptorRef);
            
            [allFontFiles addObject:fontPath];
            
        }
    }
    
    NSUInteger databaseHashNew = [allFontFiles hash];
    
    if (databaseHash == databaseHashNew)
        return;
    
    _fileDescriptorAttributesMapping = [[NSMutableDictionary<TypefaceDescriptor*, TypefaceAttributes*> alloc] init];
    
    NSInteger currentIndex = 0;
    NSInteger fontFilesTotal = allFontFiles.count;
    
    for (NSString * fontFile in allFontFiles) {
        
        // Progress
        [[NSNotificationCenter defaultCenter] postNotificationName:TMProgressNotification
                                                            object:self
                                                          userInfo:@{
                                                                     TMProgressNotificationFileKey: fontFile,
                                                                     TMProgressNotificationTotalKey: [NSNumber numberWithInteger:fontFilesTotal],
                                                                     TMProgressNotificationCurrentKey : [NSNumber numberWithInteger:currentIndex]
                                                                     }];
        ++ currentIndex;
        
        [self enumurateFacesOfURL:[NSURL fileURLWithPath:fontFile] handler:^BOOL(OpaqueFTFace opaqueFace, NSUInteger index) {
            Typeface * face = [[Typeface alloc] initWithOpaqueFace:opaqueFace];
            TypefaceAttributes * attributes = face.attributes;
            
            TypefaceDescriptor * descriptor = [TypefaceDescriptor descriptorWithFilePath:fontFile faceIndex:index];
            
            [_fileDescriptorAttributesMapping setObject:attributes
                                           forKey:descriptor];
            
            return YES;
        }];
    }
    
    serialized = [NSKeyedArchiver archivedDataWithRootObject:_fileDescriptorAttributesMapping];
    [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:@"TypefaceFontList"];
    [[NSUserDefaults standardUserDefaults] setInteger:databaseHashNew forKey:@"TypefaceFontListHash"];

}

- (void) buildAccelerations {
    _nameDescriptorFileMapping = [[NSMutableDictionary<TypefaceDescriptor*, TypefaceDescriptor*> alloc] init];
    {
        for (TypefaceDescriptor * fileDescriptor in _fileDescriptorAttributesMapping) {
            TypefaceAttributes * attributes = [_fileDescriptorAttributesMapping objectForKey:fileDescriptor];
            [_nameDescriptorFileMapping setObject:fileDescriptor
                                           forKey:[TypefaceDescriptor descriptorWithFamily:attributes.familyName style:attributes.styleName]];
        }
    }
    
    _typefaceFimilies = [[NSMutableArray<TMTypefaceFamily*> alloc] init];
    {
        NSMutableDictionary<NSString*, TMTypefaceFamily*> * familiesMap = [[NSMutableDictionary<NSString*, TMTypefaceFamily*> alloc] init];
        for (TypefaceDescriptor * fileDescriptor in _fileDescriptorAttributesMapping) {
            TypefaceAttributes * attributes = [_fileDescriptorAttributesMapping objectForKey:fileDescriptor];
            
            TMTypefaceFamily * family = [familiesMap objectForKey:attributes.familyName];
            if (!family) {
                family = [[TMTypefaceFamily alloc] initWithFamilyName:attributes.familyName];
                [familiesMap setObject:family forKey:attributes.familyName];
            }
            
            if (!family.localizedFamilyName)
                family.localizedFamilyName = attributes.preferedLocalizedFamilyName;
            
            NSMutableArray<TMTypeface*>* faces = (NSMutableArray<TMTypeface*>*)family.faces;
            if (!faces) {
                faces = [[NSMutableArray<TMTypeface*> alloc] init];
                family.faces = faces;
            }
            
            TMTypeface * face = [[TMTypeface alloc] initWithFamilyName:attributes.familyName styleName:attributes.styleName];
            face.localizedFamilyName = attributes.preferedLocalizedFamilyName;
            face.localizedStyleName = attributes.preferedLocalizedStyleName;
            face.attributes = attributes;
            
            [faces addObject:face];
        }
        
        for (NSString * familyName in familiesMap) {
            TMTypefaceFamily * family = [familiesMap objectForKey:familyName];
            NSMutableArray<TMTypeface*>* faces = (NSMutableArray<TMTypeface*>*)family.faces;
            [faces sortUsingSelector:@selector(compare:)];
        }
        
        _typefaceFimilies = [[familiesMap allValues] mutableCopy];
        [_typefaceFimilies sortUsingSelector:@selector(compare:)];
    }
}

-(NSArray<TMTypefaceFamily*>*)availableTypefaceFamilies {
    return _typefaceFimilies;
}

-(void)initFTLib {
    if (!ftLib)
        FT_Init_FreeType(&ftLib);
}

-(void)doneFTLib {
    FT_Done_FreeType(ftLib);
}

-(OpaqueFTLibrary)ftLib {
    return ftLib;
}

-(NSArray<NSString*> *)listFacesOfURL:(NSURL*)url {
    NSMutableArray<NSString*> * faces = [[NSMutableArray<NSString*> alloc] init];
    
    [self enumurateFacesOfURL:url handler:^BOOL(OpaqueFTFace opaqueFace, NSUInteger index) {
        [faces addObject:[NSString stringWithFormat:@"%@ %@",
                          [NSString stringWithUTF8String:((FT_Face)opaqueFace)->family_name],
                          [NSString stringWithUTF8String:((FT_Face)opaqueFace)->style_name]]];
        return true;
    }];
    return faces;
}


-(NSString*)faceNameAtIndex:(NSUInteger)index ofURL:(NSURL*)url {
    return [[self listFacesOfURL:url] objectAtIndex:index];
}

-(NSString*)familyNameAtIndex:(NSUInteger)index ofURL:(NSURL*)url {
    __block NSString * style;
    [self enumurateFacesOfURL:url handler:^BOOL(OpaqueFTFace opaqueFace, NSUInteger theIndex) {
        if (index == theIndex) {
            style = [NSString stringWithUTF8String:((FT_Face)opaqueFace)->family_name];
            return NO;
        }
        return YES;
    }];
    return style;
}

-(NSString*)styleNameAtIndex:(NSUInteger)index ofURL:(NSURL*)url {
    __block NSString * style;
    [self enumurateFacesOfURL:url handler:^BOOL(OpaqueFTFace opaqueFace, NSUInteger theIndex) {
        if (index == theIndex) {
            style = [NSString stringWithUTF8String:((FT_Face)opaqueFace)->style_name];
            return NO;
        }
        return YES;
    }];
    return style;
}


- (TypefaceDescriptor*)fileDescriptorFromNameDescriptor:(TypefaceDescriptor*)nameDescriptor {
    NSAssert(nameDescriptor.isNameDescriptor, @"Expect a name descriptor");
    return [_nameDescriptorFileMapping objectForKey:nameDescriptor];
}


-(void)enumurateFacesOfURL:(NSURL*)url handler:(BOOL (^)(OpaqueFTFace opaqueFace, NSUInteger index))hander {
    FT_Error ft_err = FT_Err_Ok;
    
    FT_Face  face;
    FT_Long  i, num_faces;
    
    FT_Open_Args  args;
    args.flags    = FT_OPEN_PATHNAME;
    args.pathname = (char*)[url.path UTF8String];
    args.stream   = NULL;
    
    // NSFontManager tells 'Skia' has a few styles, but tag of /Libarary/Fonts/Skia.ttf is 'true'.
    // Mostlikely it's a TrueType GX Variations, which Freetype can't handle right now.
    ft_err = FT_Open_Face(ftLib, &args, -1, &face);
    if (ft_err) return;
    
    num_faces = face->num_faces;
    FT_Done_Face(face);
    
    // new ft face
    for ( i = 0; i < num_faces; i++ )
    {
        ft_err = FT_Open_Face(ftLib, &args, i, &face);
        if (ft_err) return ;
        BOOL continueLoop = hander(face, i);
        FT_Done_Face(face);
        if (!continueLoop)
            break;
    }
}


-(NSInteger)indexOfFamily:(NSString*)family style:(NSString*)style ofURL:(NSURL*)url {
    __block NSInteger faceIndex = INVALID_FACE_INDEX;
    [self enumurateFacesOfURL:url handler:^BOOL(OpaqueFTFace opaqueFace, NSUInteger index) {
        if ([family isEqualToString:[NSString stringWithUTF8String:((FT_Face)opaqueFace)->family_name]]) {
            if ([style isEqualToString:[NSString stringWithUTF8String:((FT_Face)opaqueFace)->style_name]]) {
                faceIndex = index;
                return NO;
            }
            
            FT_UInt nameCount = FT_Get_Sfnt_Name_Count(((FT_Face)opaqueFace));
            for (FT_UInt nameIndex = 0; nameIndex < nameCount; ++ nameIndex) {
                FT_SfntName sfntName;
                FT_Get_Sfnt_Name(opaqueFace, nameIndex, &sfntName);
                if (sfntName.name_id == TT_NAME_ID_FONT_SUBFAMILY || sfntName.name_id == 17 /*TT_NAME_ID_TYPOGRAPHIC_SUBFAMILY*/ ||
                    sfntName.name_id == TT_NAME_ID_WWS_SUBFAMILY) {
                    if ([style isEqualToString:SFNTNameGetValue(&sfntName)]) {
                        faceIndex = index;
                        return NO;
                    }
                }
            }
        }
        return YES;
    }];
    return faceIndex;
}

+ (instancetype) defaultManager {
    if (!defaultTypefaceManager) {
        defaultTypefaceManager = [[TypefaceManager alloc] init];
        [defaultTypefaceManager loadFontDatabase];
        [defaultTypefaceManager buildAccelerations];
    }

    return defaultTypefaceManager;
}
@end
