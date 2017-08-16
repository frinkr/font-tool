//
//  GlyphInfoViewController.h
//  tx-research
//
//  Created by Yuqing Jiang on 5/15/17.
//
//

#import <Cocoa/Cocoa.h>
#import "HtmlTableView.h"

@class TypefaceDocument;
@class TypefaceGlyphcode;
@class GlyphImageView;

@interface GlyphInfoViewController : NSViewController<HtmlTableViewDataSource, HtmlTableViewDelegate, NSPopoverDelegate>

@property (assign) IBOutlet GlyphImageView *glyphImage;
- (void)forceLoadView;
- (void)loadGlyphcode:(TypefaceGlyphcode*)code ofDocument:(TypefaceDocument*)document;

- (void)showPopoverRelativeToRect:(NSRect)rect
                           ofView:(NSView*)view
                    preferredEdge:(NSRectEdge)preferredEdge
                        withGlyph:(TypefaceGlyphcode*)code
                       ofDocument:(TypefaceDocument*)document;

+ (instancetype)createViewController;

@end
