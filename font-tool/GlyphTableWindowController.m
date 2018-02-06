//
//  GlyphTableWindowController.m
//  tx-research
//
//  Created by Yuqing Jiang on 6/23/17.
//
//

#import "GlyphInfoViewController.h"
#import "GlyphTableWindowController.h"
#import "TypefaceDocument.h"
#import "CharEncoding.h"
#import "GlyphImageView.h"

@interface GlyphTableWindowController ()
@end

@interface GlyphTableViewController ()
@property Typeface * typeface;
@property (weak) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSArrayController *glyphsArrayController;
@end

@interface GlyphTableRow : NSObject<NSCopying>
@property NSInteger index;
@property Typeface * typeface;

@property (nonatomic, readonly, getter=glyph) TypefaceGlyph * glyph;
@property (nonatomic, readonly, getter=name) NSString * name;
@property (nonatomic, readonly, getter=unicode) NSString * unicode;
@property (nonatomic, readonly, getter=character) NSString * character;
@property (nonatomic, readonly, getter=width) NSInteger width;
@property (nonatomic, readonly, getter=height) NSInteger height;
@property (nonatomic, readonly, getter=horiAdvance) NSInteger horiAdvance;
@property (nonatomic, readonly, getter=horiLsb) NSInteger horiLsb;
@property (nonatomic, readonly, getter=horiRsb) NSInteger horiRsb;
@property (nonatomic, readonly, getter=horiTsb) NSInteger horiTsb;
@property (nonatomic, readonly, getter=horiOverhang) NSInteger horiOverhang;
@property (nonatomic, readonly, getter=vertAdvance) NSInteger vertAdvance;
@property (nonatomic, readonly, getter=vertLsb) NSInteger vertLsb;
@property (nonatomic, readonly, getter=vertRsb) NSInteger vertRsb;
@property (nonatomic, readonly, getter=vertTsb) NSInteger vertTsb;

- (instancetype)initWithIndex:(NSUInteger)index typeface:(Typeface *)typeface;
@end

@implementation GlyphTableRow
@synthesize glyph = _glyph;

- (instancetype)initWithIndex:(NSUInteger)index typeface:(Typeface *)typeface {
    if (self = [super init]) {
        self.index = index;
        self.typeface = typeface;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    GlyphTableRow * copy = [[GlyphTableRow allocWithZone:zone] init];
    copy.index = self.index;
    copy.typeface = self.typeface;
    return copy;
}

- (TypefaceGlyph*)glyph {
    if (_glyph)
        return _glyph;
    _glyph = [self.typeface loadGlyph:[TypefaceGlyphcode glyphCodeWithGID:self.index]];
    return _glyph;
}

- (NSString*)name {
    return self.glyph.name;
}

- (NSString*)unicode {
    
    BOOL isUnicode = self.glyph.typeface.currentCMapIsUnicode;
    NSString * hex = [CharEncoding hexForCharcode:self.glyph.codepoint
                                    unicodeFlavor:isUnicode];
    if (!hex)
        hex = UNDEFINED_UNICODE_CODEPOINT;
    
    if (isUnicode && [[UnicodeDatabase standardDatabase] isPUA:self.glyph.codepoint])
        return [NSString stringWithFormat:@"%@ (PUA)", hex];
    else
        return hex;
}

- (NSString*)character {
    unichar c = self.glyph.codepoint;
    return [NSString stringWithCharacters:&c length:1];
}

- (NSInteger)width {
    return self.glyph.width;
}

- (NSInteger)height {
    return self.glyph.height;
}

- (NSInteger)horiAdvance {
    return self.glyph.horiAdvance;
}

- (NSInteger)horiLsb {
    return self.glyph.horiBearingX;
}

- (NSInteger)horiRsb {
    return self.glyph.horiAdvance - self.glyph.width - self.glyph.horiBearingX;
}

- (NSInteger)horiTsb {
    return self.glyph.horiBearingY;
}

- (NSInteger)horiOverhang {
    return self.glyph.horiBearingY - self.glyph.height;
}

- (NSInteger)vertAdvance {
    return self.glyph.vertAdvance;
}

- (NSInteger)vertLsb {
    return self.glyph.vertBearingX;
}

- (NSInteger)vertRsb {
    return self.glyph.width + self.glyph.vertBearingX;
}

- (NSInteger)vertTsb {
    return self.glyph.vertBearingY;
}

@end


@implementation GlyphTableWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    //self.window.titleVisibility = NSWindowTitleHidden;

    NSTitlebarAccessoryViewController * titleVc = [[NSStoryboard storyboardWithName:@"GlyphTableWindow" bundle:nil] instantiateControllerWithIdentifier:@"titleBarAccessoryViewController"];
    titleVc.layoutAttribute = NSLayoutAttributeLeft;
    
    NSButton * exportButton = [titleVc.view.subviews objectAtIndex:0];
    [exportButton setTarget:self];
    [exportButton setAction:@selector(doExport:)];
    
    [self.window addTitlebarAccessoryViewController:titleVc];
}

- (IBAction)doExport:(id)sender {
    Typeface * typeface = [self.document typeface];
    NSSavePanel * panel = [NSSavePanel savePanel];
    panel.allowedFileTypes=@[@"csv"];
    panel.nameFieldStringValue = [NSString stringWithFormat:@"%@ %@",
                                  typeface.preferedLocalizedFamilyName,
                                  typeface.preferedLocalizedStyleName];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSString * path = panel.URL.path;
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];

            
            NSError * error = nil;
            NSFileHandle * file = [NSFileHandle fileHandleForWritingToURL:panel.URL error:&error];
            if (!file)
                return;
            
            NSString * header = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                                 @"Index",
                                 @"Name",
                                 @"Unicode",
                                 @"Character",
                                 @"Width",
                                 @"Height",
                                 @"Hori Advance",
                                 @"Hori Bearing X",
                                 @"Hori Bearing Y",
                                 @"Hori Right Side Bearing",
                                 @"Hori Overhang",
                                 @"Vert Advance",
                                 @"Vert Bearing X",
                                 @"Vert Bearing Y",
                                 @"Vert Right Side Bearing"];
            
            
            NSData * data = [header dataUsingEncoding:NSUTF8StringEncoding];
            [file writeData:data];
            
            for (NSUInteger gid = 0; gid < typeface.numberOfGlyphs; ++ gid) {
                GlyphTableRow * row = [[GlyphTableRow alloc] initWithIndex:gid typeface:typeface];
                
                NSString * character = row.character;
                switch(row.glyph.codepoint) {
                    case '\'': character = @"<quote>"; break;
                    case ',': character = @"<comma>"; break;
                    case '"': character = @"<double quote>"; break;
                    default: character = row.character;
                }
                
                NSString * text = [NSString  stringWithFormat:@"%ld,%@,%@,%@,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld\n",
                                   gid,
                                   row.name,
                                   row.unicode,
                                   character,
                                   row.width,
                                   row.height,
                                   row.horiAdvance,
                                   row.horiLsb,
                                   row.horiTsb,
                                   row.horiRsb,
                                   row.horiOverhang,
                                   row.vertAdvance,
                                   row.vertLsb,
                                   row.vertTsb,
                                   row.vertRsb];
                
                NSData * data = [text dataUsingEncoding:NSUTF8StringEncoding];
                [file writeData:data];
                
            }
            
            [file closeFile];
        }
    }];
}

- (void)setupWindowTitle {
    
    TypefaceDocument * doc = self.document;
    
    [self.window setRepresentedFilename:doc.typeface.fileURL.path];
    self.window.title = [NSString stringWithFormat:@"%@ %@ (Glyph Table)",
                         doc.typeface.preferedLocalizedFamilyName,
                         doc.typeface.preferedLocalizedStyleName];
    
    
}


+ (instancetype)createWithDocument:(TypefaceDocument*)document parentWindow:(NSWindow*)parentWindow bringFront:(BOOL)bringFront {
    GlyphTableWindowController * wc = [[NSStoryboard storyboardWithName:@"GlyphTableWindow" bundle:nil] instantiateInitialController];
    
    GlyphTableViewController * vc = (GlyphTableViewController*)wc.contentViewController;
    vc.typeface = document.typeface;
    [vc.tableView reloadData];
    
    [document addWindowController:wc];
    [parentWindow addChildWindow:wc.window ordered:NSWindowAbove];
    
    if (bringFront) {
        [wc.window makeKeyAndOrderFront:parentWindow];
        [wc setupWindowTitle];
    }
    return wc;
}

@end

@implementation GlyphTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self addObserver:self forKeyPath:@"typeface" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc {
    [self.typeface removeObserver:self forKeyPath:@"currentVariation"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"typeface"] && (object == self)) {
        switch ([[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue]) {
            case NSKeyValueObservingOptionOld: {
                Typeface * old = [change objectForKey:NSKeyValueChangeOldKey];
                [old removeObserver:self forKeyPath:@"currentVariation"];
                break;
            }
            case NSKeyValueObservingOptionNew: {
                Typeface * newFace = [change objectForKey:NSKeyValueChangeNewKey];
                [newFace addObserver:self forKeyPath:@"currentVariation" options:NSKeyValueObservingOptionNew context:nil];
                
                [self reloadGlyphs];
                break;
            }
            default:
                break;
        };
    }
    if ([keyPath isEqualToString:@"currentVariation"] && (object == self.typeface)) {
        [self reloadGlyphs];
    }
}

- (void)reloadGlyphs {
    NSMutableArray<GlyphTableRow *> * rows = [[NSMutableArray<GlyphTableRow *> alloc] init];
    for (NSUInteger index = 0; index < self.typeface.numberOfGlyphs; ++ index) {
        GlyphTableRow * row = [[GlyphTableRow alloc] initWithIndex:index
                                                          typeface:self.typeface];
        [rows addObject:row];
    }
    
    NSRange range = NSMakeRange(0, [[self.glyphsArrayController arrangedObjects] count]);
    [self.glyphsArrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    
    [self.glyphsArrayController addObjects:rows];
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [self.glyphsArrayController setSortDescriptors:[tableView sortDescriptors]];
    [tableView reloadData];
}

- (IBAction)doDoubleClickTable:(id)sender {
    if (self.tableView.clickedRow == -1)
        return;
    
    GlyphTableRow * row = [self.glyphsArrayController.arrangedObjects objectAtIndex:self.tableView.clickedRow];
    
    if ([self.tableDelegate respondsToSelector:@selector(glyphTable:didSelectIndex:)])
        [self.tableDelegate glyphTable:self.tableView didSelectIndex:row.index];
    
    return;
    NSRect rect = [self.tableView frameOfCellAtColumn:self.tableView.clickedColumn row:self.tableView.clickedRow];
    GlyphInfoViewController * vc = [GlyphInfoViewController createViewController];
    TypefaceGlyphcode * code = [TypefaceGlyphcode glyphCodeWithGID:row.index];
    [vc showPopoverRelativeToRect:rect ofView:self.tableView preferredEdge:NSRectEdgeMinY withGlyph:code ofDocument:self.document];
}

- (TypefaceDocument*)document {
    return [self.view.window.windowController document];
}

@end
