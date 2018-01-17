//
//  GlyphImageView.h
//  tx-research
//
//  Created by Yuqing Jiang on 6/12/17.
//
//

#import <Cocoa/Cocoa.h>

@class TypefaceGlyph;
@class Typeface;

typedef NS_ENUM(NSInteger, GlyphImageViewOptions) {
    GlyphImageViewShowOrgin        = 1 << 0,
    GlyphImageViewShowAscender     = 1 << 1,
    GlyphImageViewShowDescender    = 1 << 2,
    GlyphImageViewShowBaseline     = 1 << 3,
    GlyphImageViewShowEmBox        = 1 << 4,
    GlyphImageViewShowLeftBearing  = 1 << 5,
    GlyphImageViewShowHoriAdvance  = 1 << 6,
    GlyphImageViewShowAllMetrics = 0xFFFF,
};

@interface GlyphImageView : NSImageView
@property (nonatomic, assign) IBOutlet id delegate;
@property GlyphImageViewOptions options;
@property TypefaceGlyph * glyph;
@property NSColor * foreground;
@property NSColor * background;
@property NSEdgeInsets edgeInsets;

- (void)setObjectValue:(id)value;
- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle;

- (void)setGlyph:(TypefaceGlyph*)glyph
   withForegroud:(NSColor*)foreground
      background:(NSColor*)background;

@end
