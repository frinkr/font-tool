//
//  Document.m
//  font-tool
//
//  Created by Yuqing Jiang on 5/12/17.
//  Copyright © 2017 Yuqing Jiang. All rights reserved.
//
#import <objc/runtime.h>
#import "Typeface.h"
#import "TypefaceDocument.h"
#import "TypefaceStylesWindowController.h"
#import "TypefaceWindowController.h"

@interface NSURL (TypefaceDocument)
@property NSNumber* faceIndex;
@end

@implementation NSURL (TypefaceDocument)
@dynamic faceIndex;

- (void)setFaceIndex:(NSNumber*)faceIndex {
    objc_setAssociatedObject(self, @selector(faceIndex), faceIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)faceIndex {
    return objc_getAssociatedObject(self, @selector(faceIndex));
}

@end

@interface TypefaceDocument ()
@end

@implementation TypefaceDocument

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

+ (BOOL)autosavesInPlace {
    return NO;
}

- (void)makeWindowControllers {
    // Override to return the Storyboard file name of the document.
    _mainWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Font Window Controller"];
    [self addWindowController:_mainWindowController];
}

#pragma mark *** Read file ***

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    // [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}


- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    //typeFace.reset(new tf::Typeface(data.bytes, data.length));
    return NO;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
    TypefaceDescriptor * descriptor = [TypefaceDocument typefaceDescriptorWithDocumentURL:url];
    if (!descriptor)
        return NO;
    _typeface = [[Typeface alloc] initWithDescriptor:descriptor];
    return YES;
}

#pragma mark *** CMap ****

- (NSArray<TypefaceCMap*>*)cmaps {
    return self.typeface.cmaps;
}

- (TypefaceCMap*)currentCMap {
    return self.typeface.currentCMap;
}

- (TypefaceCMap*)selectCMap:(TypefaceCMap*)cmap {
    return [self.typeface selectCMap:cmap];
}

- (TypefaceCMap*)selectCMapAtIndex:(NSUInteger)index {
    return [self.typeface selectCMapAtIndex:index];
}

#pragma mark *** Glyphs ***

- (TypefaceGlyph*)loadGlyph:(TypefaceGlyphcode *)gc {
    return [self.typeface loadGlyph:gc];
}

#pragma mark *** URL encoding ***

+ (NSURL*)documentURLWithTypefaceDescriptor:(TypefaceDescriptor*)descriptor {
    if (descriptor.isNameDescriptor)
        return [TypefaceDocument documentURLWithFamilyName:descriptor.family styleName:descriptor.style];
    else
        return [TypefaceDocument documentURLWithFaceIndex:descriptor.faceIndex filePath:descriptor.fileURL.path];
}

+ (TypefaceDescriptor*)typefaceDescriptorWithDocumentURL:(NSURL*)url {
    NSUInteger index = 0;
    NSString * filePath = nil;
    if ([TypefaceDocument getFaceIndex:&index filePath:&filePath ofDocumentURL:url])
        return [TypefaceDescriptor descriptorWithFilePath:filePath faceIndex:index];

    NSString * family = nil, * style = nil;
    if ([TypefaceDocument getFamilyName:&family styleName:&style ofDocumentURL:url])
        return [TypefaceDescriptor descriptorWithFamily:family style:style];
    
    return nil;
}

+(NSURL*)documentURLWithFamilyName:(NSString*)familyName styleName:(NSString*)styleName {
    return [NSURL URLWithString:[[NSString stringWithFormat:@"face://%@@%@", familyName, styleName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

+(NSURL*)documentURLWithFaceIndex:(NSUInteger)index filePath:(NSString *)filePath {
    return [NSURL URLWithString:[[NSString stringWithFormat:@"faci://%ld@%@", (long)index, filePath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

+ (BOOL)getFamilyName:(NSString**)familyName styleName:(NSString**)styleName ofDocumentURL:(NSURL*)url {
    if (![url.scheme isEqualToString:@"face"])
        return NO;
    
    NSString * res = [url.resourceSpecifier stringByRemovingPercentEncoding];
    
    NSArray<NSString*> * componnets = [res componentsSeparatedByString:@"@"];
    if (componnets.count != 2)
        return NO;
    
    *familyName = [componnets[0] stringByReplacingOccurrencesOfString:@"/" withString:@""];
    *styleName = componnets[1];
    return YES;
}

+ (BOOL)getFaceIndex:(NSUInteger*)outIndex filePath:(NSString**)outFilePath ofDocumentURL:(NSURL*)url {
    if (![url.scheme isEqualToString:@"faci"])
        return NO;
    
    NSString * res = [url.resourceSpecifier stringByRemovingPercentEncoding];
    
    NSArray<NSString*> * componnets = [res componentsSeparatedByString:@"@"];
    NSString * faceIndexStr = [componnets[0] stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString * path = componnets[1];
    
    *outIndex = [faceIndexStr integerValue];
    *outFilePath = path;
    return YES;
}

@end
