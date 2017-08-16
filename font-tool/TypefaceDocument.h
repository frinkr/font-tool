//
//  Document.h
//  font-tool
//
//  Created by Yuqing Jiang on 5/12/17.
//  Copyright © 2017 Yuqing Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Typeface.h"


@class TypefaceWindowController;

@interface TypefaceDocument : NSDocument
@property NSColor * glyphColor;
@property (nonatomic, readonly) Typeface* typeface;
@property (nonatomic, readonly) TypefaceWindowController * mainWindowController;

- (NSArray<TypefaceCMap*>*)cmaps;
- (TypefaceCMap*)currentCMap;
- (TypefaceCMap*)selectCMap:(TypefaceCMap*)cmap;
- (TypefaceCMap*)selectCMapAtIndex:(NSUInteger)index;

- (TypefaceGlyph*)loadGlyph:(TypefaceGlyphcode*)gc;


#pragma mark *** URL encoding ****
+ (NSURL*)documentURLWithTypefaceDescriptor:(TypefaceDescriptor*)descriptor;
+ (TypefaceDescriptor*)typefaceDescriptorWithDocumentURL:(NSURL*)url;
@end

