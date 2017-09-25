//
//  GlyphsViewItem.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/15/17.
//
//

#import "GlyphCollectionViewItem.h"
#import "GlyphImageView.h"

@interface GlyphCollectionViewItem ()
@property GlyphLabelCategory labelCategory;
@end

@implementation GlyphCollectionViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer = TRUE;
    self.view.layer.cornerRadius = 5;
    self.glyphImageView.edgeInsets = NSEdgeInsetsMake(15, 15, 15, 15);
    self.glyphImageView.options = GlyphImageViewShowOrgin;
}


-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.view.layer.backgroundColor = [[NSColor alternateSelectedControlColor] CGColor];
        [self.glyphNameLabel setTextColor:[NSColor alternateSelectedControlTextColor]];
        [self.glyphImageView setForeground:[NSColor whiteColor]];
    }
    else {
        self.view.layer.backgroundColor = [[NSColor clearColor] CGColor];
        [self.glyphNameLabel setTextColor:[NSColor keyboardFocusIndicatorColor]];
        [self.glyphImageView setForeground:nil];
    }
    
}

- (IBAction)rightMouseDown:(NSEvent *)event {
    if ([self.delegate respondsToSelector:@selector(rightClickGlyphCollectionViewItem:event:)])
        [self.delegate rightClickGlyphCollectionViewItem:self event:event];
}


- (IBAction)doubleClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(doubleClickGlyphCollectionViewItem:)])
        [self.delegate doubleClickGlyphCollectionViewItem:self];
}

- (void)setGlyphCode:(TypefaceGlyphcode *)glyphCode ofDocument:(TypefaceDocument*)document GlyphLabelCategory:(GlyphLabelCategory)category {
    self.glyphCode = glyphCode;
    self.document = document;
    self.labelCategory = category;
    [self reload];
}

- (void) reload {
    TypefaceGlyph * glyph = [self.document loadGlyph:self.glyphCode];
    if (glyph) {
        NSString * label;
        switch(self.labelCategory) {
            case GlyphLabelByName:
                label = glyph.name;
                break;
            case GlyphLabelByCode:
                label = glyph.charcodeHex;
                break;
            case GlyphLabelByGlyphIndex:
                label = [NSString stringWithFormat:@"%lu", glyph.GID];
                break;
        }
        
        [self.glyphImageView setGlyph:glyph
                         withForegroud:self.document.glyphColor
                            background:[NSColor clearColor]];
        
        self.glyphNameLabel.stringValue = label;
    }
    
}

@end
