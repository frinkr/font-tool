//
//  GlyphInfoViewController.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/15/17.
//
//
#include <hb.h>
#include <hb-ft.h>
#include <hb-ot.h>

#import <WebKit/WebKit.h>
#import "CharEncoding.h"
#import "GlyphImageView.h"
#import "GlyphInfoViewController.h"
#import "TypefaceDocument.h"
#import "Shapper.h"

@interface GlyphInfoViewController ()
@property (assign) IBOutlet HtmlTableView *tableView;

@property (strong) TypefaceGlyph * glyph;
@property (strong) HtmlTableRows * tableRows;
@property (strong) NSPopover *popover;
@end

@implementation GlyphInfoViewController

- (void)awakeFromNib {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)forceLoadView {
    if (!self.view)
        [self loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.glyphImage.edgeInsets = NSEdgeInsetsMake(20, 20, 20, 20);
    self.glyphImage.options = GlyphImageViewShowAllMetrics;
}

- (NSUInteger)numberOfRowsInHtmlTableView:(HtmlTableView *)view {
    return self.tableRows.count;
}

-(HtmlTableRow*_Nonnull)htmlTableView:(HtmlTableView*_Nonnull)view rowAtIndex:(NSUInteger)index {
    return [self.tableRows objectAtIndex:index];
}

-(HtmlTableViewAppearance*)appearanceOfHtmlTableView:(HtmlTableView *)view {
    HtmlTableViewAppearance * appearance = [[HtmlTableViewAppearance alloc] init];
    appearance.keyColumnSize = 50;
    return appearance;
}

- (void)loadGlyphcode:(TypefaceGlyphcode*)code ofDocument:(TypefaceDocument*)document {
    self.glyph = [document.typeface loadGlyph:code size:200];
    
    [self.glyphImage setGlyph:self.glyph
                 withForegroud:[NSColor blackColor]
                    background:[NSColor whiteColor]];
    
    [self updatetableRows];
    [self.tableView reloadData];
}

- (void)updatetableRows {
    HtmlTableRows * items = [[HtmlTableRows alloc] init];
    
    BOOL isUnicode = self.glyph.typeface.currentCMapIsUnicode;
    
    if (isUnicode) {
        [items addRowWithKey:@"Glyph Name" stringValue:self.glyph.name];
        [items addRowWithKey:@"Glyph Index" unsignedIntegerValue:self.glyph.GID];
        
        NSMutableArray<NSNumber*> * altCharcodes = [[NSMutableArray<NSNumber*> alloc] init];
        for (NSNumber * num in self.glyph.charcodes) {
            if (num.unsignedIntegerValue != self.glyph.charcode) {
                [altCharcodes addObject:num];
            }
        }
        
        NSString * hex = [CharEncoding hexForCharcode:self.glyph.charcode unicodeFlavor:isUnicode];

        [items addRowWithKey:@"Unicode" stringValue:hex? [NSString stringWithFormat:@"<a href=%@>%@</a>", [CharEncoding infoLinkOfUnicode:self.glyph.charcode], hex]: nil];
        [items addRowWithKey:@"UTF8" stringValue:[CharEncoding utf8HexStringForUnicode:self.glyph.charcode]];
        [items addRowWithKey:@"UTF16" stringValue:[CharEncoding utf16HexStringForUnicode:self.glyph.charcode]];
        
        
        NSArray<NSNumber*> * nfd = [CharEncoding canonicalDecomposition:self.glyph.charcode];
        if (nfd.count) {
            NSMutableString * nfdStr = [[NSMutableString alloc] init];
            for (NSUInteger i = 0; i < nfd.count; ++ i) {
                if (i) [nfdStr appendString:@", "];
                [nfdStr appendString:[CharEncoding hexForCharcode:[[nfd objectAtIndex:i] unsignedIntegerValue]
                                                    unicodeFlavor: isUnicode]];
            }
        
            [items addRowWithKey:@"NFD" stringValue:nfdStr];
        }
        
        if (altCharcodes.count) {
            NSMutableArray<NSString*> * altStrings = [[NSMutableArray<NSString*> alloc] init];
            for (NSNumber * num in altCharcodes) {
                NSUInteger code = num.unsignedIntegerValue;
                hex = [CharEncoding hexForCharcode:code unicodeFlavor:YES];
                if (hex)
                    [altStrings addObject:[NSString stringWithFormat:@"<a href=%@>%@</a>", [CharEncoding infoLinkOfUnicode:self.glyph.charcode], hex]];
                else
                    [altStrings addObject:[CharEncoding hexForCharcode:code unicodeFlavor:NO]];
            }
            [items addRowWithKey:@"Alternate" stringValue:[altStrings componentsJoinedByString:@"<br>"]];
        }
        
        [items addRowWithKey:@"Unicode Name" stringValue:[[UnicodeDatabase standardDatabase] attributesOfChar:self.glyph.charcode].name];
        [items addRowWithKey:@"Block" stringValue:[[UnicodeDatabase standardDatabase] blockOfChar:self.glyph.charcode].name];
        [items addRowWithKey:@"Script" stringValue:[[UnicodeDatabase standardDatabase] scriptOfChar:self.glyph.charcode]];
        [items addRowWithKey:@"Derived Age" stringValue:[[UnicodeDatabase standardDatabase] derivedAgeOfChar:self.glyph.charcode]];
        [items addRowWithKey:@"General Category" stringValue:[[UnicodeDatabase standardDatabase] attributesOfChar:self.glyph.charcode].generalCategory.fullDescription];

    }
    else {
        [items addRowWithKey:@"Glyph Name" stringValue:self.glyph.name];
        [items addRowWithKey:@"Glyph Index" unsignedIntegerValue:self.glyph.GID];
        [items addRowWithKey:@"Charcode" stringValue:[NSString stringWithFormat:@"%@(%ld)", self.glyph.charcodeHex, self.glyph.charcode]];
    }
    
    // metrics
    [items addRowWithKey:@"Width" integerValue:self.glyph.width];
    [items addRowWithKey:@"Height" integerValue:self.glyph.height];
    [items addRowWithKey:@"Hori Bearing X" integerValue:self.glyph.horiBearingX];
    [items addRowWithKey:@"Hori Bearing Y" integerValue:self.glyph.horiBearingY];
    [items addRowWithKey:@"Hori Advance" integerValue:self.glyph.horiAdvance];
    [items addRowWithKey:@"Vert Bearing X" integerValue:self.glyph.vertBearingX];
    [items addRowWithKey:@"Vert Bearing Y" integerValue:self.glyph.vertBearingY];
    [items addRowWithKey:@"Vert Advance" integerValue:self.glyph.vertAdvance];
    
    
    self.tableRows = items;
}

- (void)showPopoverRelativeToRect:(NSRect)rect
                           ofView:(NSView*)view
                    preferredEdge:(NSRectEdge)preferredEdge
                        withGlyph:(TypefaceGlyphcode*)code
                       ofDocument:(TypefaceDocument*)document {
    
    if (!self.popover) {
        self.popover = [[NSPopover alloc] init];
        self.popover.contentViewController = self;
        self.popover.delegate = self;
        self.popover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        self.popover.behavior = NSPopoverBehaviorTransient;
    }
    
    [self loadGlyphcode:code ofDocument:document];
    
    [self.popover showRelativeToRect:rect
                              ofView:view
                       preferredEdge:preferredEdge];
}


- (void)popoverWillClose:(NSNotification *)notification {
    self.popover.contentViewController = nil;
    self.popover = nil;
}

+ (instancetype)createViewController {
    GlyphInfoViewController * vc = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"glyphInfoViewController"];
    [vc forceLoadView];
    return vc;
}

@end
