//
//  GlyphImageView.m
//  tx-research
//
//  Created by Yuqing Jiang on 6/12/17.
//
//
#import "Typeface.h"
#import "GlyphImageView.h"
#include "CharEncoding.h"

static NSImage * UNASSIGNED_CODEPOINT_IMAGE = nil;

@interface GlyphImageView()

@end

@implementation GlyphImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpView];
    
    if (!UNASSIGNED_CODEPOINT_IMAGE) {
        UNASSIGNED_CODEPOINT_IMAGE = [NSImage imageNamed:@"UnAssigned"];
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"foreground"];
    [self removeObserver:self forKeyPath:@"background"];
    [self removeObserver:self forKeyPath:@"glyph"];
}

- (void)setUpView {
    [self addObserver:self forKeyPath:@"foreground" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"background" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"glyph" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString*,id> *)change context:(void *)context {
    if (object == self) {
        if ([keyPath isEqualToString:@"foreground"] ||
            [keyPath isEqualToString:@"background"] ||
            [keyPath isEqualToString:@"glyph"]) {
            [self setNeedsDisplay];
        }
    }
}

- (void)setObjectValue:(id)value {
    
    BOOL fallBackSuper = YES;
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = (NSDictionary*)value;
        TypefaceGlyph * glyph = [dict objectForKey:@"glyph"];
        if (glyph) {
            fallBackSuper = NO;
            [self setGlyph:glyph
             withForegroud:[dict objectForKey:@"foreground"]
                background:[dict objectForKey:@"background"]];
        }
    }
    else if ([value isKindOfClass:[TypefaceGlyph class]]) {
        [self setGlyph:(TypefaceGlyph*)value
         withForegroud:nil
            background:nil];
        fallBackSuper = NO;
    }
    
    return;
    if (fallBackSuper)
        [super setObjectValue:value];
    
    [self setNeedsDisplay];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {    
    if (backgroundStyle == NSBackgroundStyleDark)
        self.foreground = [NSColor whiteColor];
    else if (backgroundStyle == NSBackgroundStyleLight)
        self.foreground = [NSColor blackColor];
}

- (void)setGlyph:(TypefaceGlyph*)glyph withForegroud:(NSColor*)foreground background:(NSColor*)background {
    
    self.glyph = glyph;
    self.background = background;
    self.foreground = foreground;
    [self setNeedsDisplay];
}



- (NSView *)hitTest:(NSPoint)aPoint
{
    // don't allow any mouse clicks for subviews in this view
    if(NSPointInRect(aPoint,[self convertRect:[self bounds] toView:[self superview]])) {
        return self;
    } else {
        return nil;
    }
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    if([theEvent clickCount] > 1) {
        if([self.delegate respondsToSelector:@selector(doubleClick:)]) {
            [self.delegate performSelector:@selector(doubleClick:) withObject:self];
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = self.bounds;
    bounds = NSMakeRect(bounds.origin.x + self.edgeInsets.left,
                        bounds.origin.y + self.edgeInsets.bottom,
                        bounds.size.width - self.edgeInsets.left - self.edgeInsets.right,
                        bounds.size.height - self.edgeInsets.top - self.edgeInsets.bottom);
    
    
    
    // Drawing code here.
    // create master image
    {
        TypefaceGlyph * glyph = self.glyph;
        Typeface* typeface = glyph.typeface;
        NSColor * background = self.background;
        NSColor * foreground = self.foreground;
        
        CGFloat imageFontSize = glyph.imageFontSize;
        
        NSInteger faceHeightFu = typeface.ascender - typeface.descender;
        NSInteger faceBoxFu = MAX(typeface.upem, faceHeightFu);
        CGFloat faceBoxPx =[typeface fontUnitToPixel:faceBoxFu withFontSize:imageFontSize];
        CGFloat faceDescenderPx = [typeface fontUnitToPixel:typeface.descender withFontSize:imageFontSize];
        CGFloat faceAscenderPx = [typeface fontUnitToPixel:typeface.ascender withFontSize:imageFontSize];
        
        NSInteger glyphTop = glyph.image.size.height + glyph.imageOffsetY;
        NSInteger glyphBottom = glyph.imageOffsetY;
        
        CGFloat scaleTop = 1.0, scaleBottom = 1.0;
        if (glyphTop > (faceAscenderPx + self.edgeInsets.top))
            scaleTop = (faceAscenderPx + self.edgeInsets.top) / glyphTop;
        if (glyphBottom < (faceDescenderPx - self.edgeInsets.bottom))
            scaleBottom = (faceDescenderPx - self.edgeInsets.bottom) / glyphBottom;
        
        // glyph scaling related to EM box
        CGFloat glyphScale = MIN(1.0, MIN(scaleTop, scaleBottom));
        CGFloat emBoxSize = MIN(faceBoxPx, MIN(bounds.size.width, bounds.size.height));
        CGFloat facePxScale = emBoxSize/faceBoxPx;
        
        CGFloat glyphImageScale = facePxScale * glyphScale;
        
        // let's draw an EM box first
        
        CGRect emBox = CGRectMake(bounds.origin.x + (bounds.size.width - emBoxSize) / 2,
                                  bounds.origin.y + (bounds.size.height - emBoxSize) / 2,
                                  emBoxSize, emBoxSize);
        
        if (self.options & GlyphImageViewShowEmBox) {
            [[NSColor grayColor] set];
            NSBezierPath * emBoxPath = [NSBezierPath bezierPathWithRect:emBox];
        
            [emBoxPath stroke];
        }
        
        CGFloat advance = [typeface fontUnitToPixel:glyph.horiAdvance withFontSize:imageFontSize] * glyphImageScale;
        CGFloat widthFixed = [typeface fontUnitToPixel:glyph.width + glyph.horiBearingX withFontSize:imageFontSize] * glyphImageScale;
        CGFloat originX = emBox.origin.x + (widthFixed > emBoxSize? 0: (emBoxSize - widthFixed) / 2);
        CGFloat originY = emBox.origin.y - faceDescenderPx * facePxScale;
        CGFloat ascender  = originY + faceAscenderPx * facePxScale;
        CGFloat descender = emBox.origin.y;
        
        
        CGFloat leftBearing = originX + [typeface fontUnitToPixel:glyph.horiBearingX withFontSize:imageFontSize] * glyphImageScale;
        CGFloat rightBearing = originX + [typeface fontUnitToPixel:(glyph.horiBearingX + glyph.width) withFontSize:imageFontSize] * glyphImageScale;
        
        if (background && ![background isEqual:[NSColor clearColor]]) {
            [background setFill];
            NSBezierPath * path = [NSBezierPath bezierPathWithRect:emBox];
            [path fill];
        }
        
        NSImage * glyphImage = glyph.image;
        if (!typeface.isBitmap && foreground && ![foreground isEqual:[NSColor blackColor]]) {
            glyphImage= [glyph.image copy];
            [glyphImage lockFocus];
            [foreground set];
            NSRect imageRect = {NSZeroPoint, [glyphImage size]};
            NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
            [glyphImage unlockFocus];
        }
        
        
        CGRect imageRect = CGRectMake(originX + glyph.imageOffsetX * glyphImageScale,
                                      originY + glyph.imageOffsetY * glyphImageScale,
                                      glyph.image.size.width * glyphImageScale,
                                      glyph.image.size.height * glyphImageScale);
        
        if (glyph.GID) {
            [glyphImage drawInRect:imageRect
                          fromRect:NSZeroRect
                         operation:NSCompositeSourceOver
                          fraction:1];
        }
        // let's draw the codepoint using system font
        else {
            UInt32 cp = glyph.codepoint;
            if ([UnicodeDatabase.standardDatabase isAssigned:cp]) {
                if (![UnicodeDatabase.standardDatabase isControl:cp]) {
                    NSString * unicodeString = [[NSString alloc] initWithBytes:&cp length:sizeof(cp) encoding:NSUTF32LittleEndianStringEncoding];
                    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    style.alignment = NSTextAlignmentCenter;
                    
                    CGFloat fontSize = MIN(imageRect.size.height, imageRect.size.width);
                    NSDictionary * attributes = [NSDictionary dictionaryWithObjects: @[[NSFont systemFontOfSize:fontSize], [NSColor redColor], style]
                                                                            forKeys: @[NSFontAttributeName, NSForegroundColorAttributeName, NSParagraphStyleAttributeName]];
                    
                    [unicodeString drawInRect:emBox withAttributes:attributes];
                }
                else {
                    [glyphImage drawInRect:imageRect
                                  fromRect:NSZeroRect
                                 operation:NSCompositeSourceOver
                                  fraction:1];
                }
            }
            else {
                if (!typeface.isBitmap && foreground && ![foreground isEqual:[NSColor blackColor]]) {
                    NSImage * img = [UNASSIGNED_CODEPOINT_IMAGE copy];
                    [img lockFocus];
                    [foreground set];
                    NSRect imageRect = {NSZeroPoint, [img size]};
                    NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
                    [img unlockFocus];
                    [img drawInRect:emBox];
                }
                else
                    [UNASSIGNED_CODEPOINT_IMAGE drawInRect:emBox];
            }
        }
        
        if (glyphScale != 1) {
            // show marks the glyph is scaled, not the natual size
            CGFloat radius = 2;
            
            NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(emBox.origin.x + emBox.size.width - radius/2,
                                                                                     emBox.origin.y + emBox.size.height - radius/2,
                                                                                     radius*2, radius*2)
                                                                  xRadius:radius yRadius:radius];
            [[NSColor knobColor] setFill];
            [path fill];
        }
        
        if (glyph.GID != 0) {
            if (self.options & GlyphImageViewShowBaseline) {
                [self lineFrom:NSMakePoint(MIN(emBox.origin.x, leftBearing), originY)
                            to:NSMakePoint(MAX(emBox.origin.x + emBoxSize, rightBearing), originY)
                          dash:NO
                         color:[NSColor greenColor]];
            }
            
            if (self.options & GlyphImageViewShowOrgin) { // draw baseline mark
                CGFloat markSize = 10;
                
                [self lineFrom:NSMakePoint(originX - markSize / 2, originY)
                            to:NSMakePoint(originX + markSize / 2, originY)
                          dash:NO
                         color:[NSColor redColor]];
                
                [self lineFrom:NSMakePoint(originX, originY - markSize / 2)
                            to:NSMakePoint(originX, originY + markSize / 2)
                          dash:NO
                         color:[NSColor redColor]];
            }
            
            
            if (self.options & GlyphImageViewShowAscender) {
                [self lineFrom:NSMakePoint(originX, ascender)
                            to:NSMakePoint(originX + advance, ascender)
                          dash:NO
                         color:[NSColor blueColor]];
            }
            
            if (self.options & GlyphImageViewShowDescender) {
                [self lineFrom:NSMakePoint(originX, descender)
                            to:NSMakePoint(originX + advance, descender)
                          dash:NO
                         color:[NSColor blueColor]];
            }
            
            if (self.options & GlyphImageViewShowLeftBearing) {
                [self lineFrom:NSMakePoint(leftBearing, descender)
                            to:NSMakePoint(leftBearing, ascender)
                          dash:YES
                         color:[NSColor redColor]];
            }
            
            
            if (self.options & GlyphImageViewShowHoriAdvance) {
                [self lineFrom:NSMakePoint(originX + advance, descender)
                            to:NSMakePoint(originX + advance, ascender)
                          dash:YES
                         color:[NSColor redColor]];
            }
        }
        
    }

}

- (void)lineFrom:(NSPoint)from to:(NSPoint)to dash:(BOOL)dash color:(NSColor*)color {
    NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
    
    [theContext saveGraphicsState];
    
    NSBezierPath * baseline = [NSBezierPath bezierPath];
    [baseline moveToPoint:from];
    [baseline lineToPoint:to];
    if (dash) {
        CGFloat pattern [] = {4,2};
        [baseline setLineDash:pattern count:2 phase:0];
    }
    [color setStroke];
    [baseline stroke];
    
    [theContext restoreGraphicsState];
    
}

@end
