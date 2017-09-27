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
@property (strong) HtmlTableView *tableView;

@property (strong) TypefaceGlyph * glyph;
@property (strong) HtmlTableRows * tableRows;
@property (strong) NSPopover *popover;
@end

@implementation GlyphInfoViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)forceLoadView {
    if (!self.view)
        [self loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[HtmlTableView alloc] initWithFrame:CGRectMake(0, 0, 400, 600)];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    NSDictionary<NSString*, id> * views = @{@"tableView": self.tableView,
                                            @"imageView": self.glyphImage};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[tableView]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView]-0-[tableView]-0-|" options:0 metrics:nil views:views]];

    
    // Do view setup here.
    self.glyphImage.edgeInsets = NSEdgeInsetsMake(20, 20, 20, 20);
    self.glyphImage.options = GlyphImageViewShowAllMetrics;
}

- (NSUInteger)numberOfRowsInHtmlTableView:(HtmlTableView *)view {
    return self.tableRows.count;
}

-(HtmlTableRow*)htmlTableView:(HtmlTableView*)view rowAtIndex:(NSUInteger)index {
    return [self.tableRows objectAtIndex:index];
}

-(HtmlTableViewAppearance*)appearanceOfHtmlTableView:(HtmlTableView *)view {
    HtmlTableViewAppearance * appearance = [[HtmlTableViewAppearance alloc] init];
    appearance.keyColumnSize = 50;
    return appearance;
}

- (void)htmlTableView:(HtmlTableView*)view didOpenURL:(NSURL*)url {
    [self.popover performClose:self];
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
        
        NSString * hex = [CharEncoding hexForCharcode:self.glyph.codepoint unicodeFlavor:isUnicode];
        
        [items addRowWithKey:@"Unicode" stringValue:hex? [NSString stringWithFormat:@"<a href=%@>%@</a>", [CharEncoding infoLinkOfUnicode:self.glyph.codepoint], hex]: nil];
        [items addRowWithKey:@"UTF8" stringValue:[CharEncoding utf8HexStringForUnicode:self.glyph.codepoint]];
        [items addRowWithKey:@"UTF16" stringValue:[CharEncoding utf16HexStringForUnicode:self.glyph.codepoint]];
        
        NSMutableArray<NSNumber*> * altCharcodes = [[NSMutableArray<NSNumber*> alloc] init];
        for (NSNumber * num in self.glyph.codepoints) {
            if (num.unsignedIntegerValue != self.glyph.codepoint) {
                [altCharcodes addObject:num];
            }
        }
        if (altCharcodes.count) {
            NSMutableArray<NSString*> * altStrings = [[NSMutableArray<NSString*> alloc] init];
            for (NSNumber * num in altCharcodes) {
                NSUInteger code = num.unsignedIntegerValue;
                hex = [CharEncoding hexForCharcode:code unicodeFlavor:YES];
                if (hex)
                    [altStrings addObject:[NSString stringWithFormat:@"<a href=%@>%@</a>", [CharEncoding infoLinkOfUnicode:self.glyph.codepoint], hex]];
                else
                    [altStrings addObject:[CharEncoding hexForCharcode:code unicodeFlavor:NO]];
            }
            [items addRowWithKey:@"Alternate" stringValue:[altStrings componentsJoinedByString:@"<br>"]];
        }
        
        UnicodeCharCoreAttributes * coreAttrs = [[UnicodeDatabase standardDatabase] coreAttributesOfChar:self.glyph.codepoint];

        [items addRowWithKey:@"Unicode Name" stringValue:coreAttrs.name];
        
        if (true) {
            NSString * string = [[coreAttrs.decomposition
                                  stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]
                                  stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
            
            string = RegexReplace(string, UNI_CODEPOINT_REGEX, ^NSString *(NSRange range, BOOL *stop) {
                NSString * sub = [string substringWithRange:range];
                return [NSString stringWithFormat:@"<a href=%@>U+%@</a>",
                        [CharEncoding gotoLinkOfUnicodeHex:sub],
                        sub];
            });
            [items addRowWithKey:@"Decomposition" stringValue:string];
        }
        
        [items addRowWithKey:@"Block" stringValue:[[UnicodeDatabase standardDatabase] blockOfChar:self.glyph.codepoint].name];
        [items addRowWithKey:@"Script" stringValue:[[UnicodeDatabase standardDatabase] scriptOfChar:self.glyph.codepoint]];
        [items addRowWithKey:@"Derived Age" stringValue:[[UnicodeDatabase standardDatabase] derivedAgeOfChar:self.glyph.codepoint]];
        [items addRowWithKey:@"General Category" stringValue:coreAttrs.generalCategory.fullDescription];

    }
    else {
        [items addRowWithKey:@"Glyph Name" stringValue:self.glyph.name];
        [items addRowWithKey:@"Glyph Index" unsignedIntegerValue:self.glyph.GID];
        [items addRowWithKey:@"Codepoint" stringValue:[NSString stringWithFormat:@"%@(%u)", self.glyph.charcodeHex, self.glyph.codepoint]];
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
