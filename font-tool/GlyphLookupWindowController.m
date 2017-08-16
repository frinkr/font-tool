//
//  GlyphLookupWindowController.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/27/17.
//
//

#import "GlyphLookupWindowController.h"
#import "TypefaceDocumentController.h"
#import "TypefaceWindowController.h"
static GlyphLookupWindowController * lookupWindowController;

@interface GlyphLookupWindowController ()

@end


@interface GlyphLookupViewController ()
@property (assign) IBOutlet NSSegmentedControl *lookupTypeSegments;
@property (assign) IBOutlet NSTextField *lookupValueTextEdit;

@property (readonly) GlyphLookupType lookupType;
@property (readonly) NSString * lookupValue;

@property void (^lookupHander)(GlyphLookupType, NSString *);

@end

@implementation GlyphLookupWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    GlyphLookupViewController * vc = (GlyphLookupViewController*)self.contentViewController;
    vc.lookupHander = ^(GlyphLookupType lookupType, NSString * value) {
        TypefaceDocument * document = (TypefaceDocument *)[NSDocumentController sharedDocumentController].currentDocument;
        TypefaceWindowController * wc = document.mainWindowController;
        [wc lookupGlyphWithType:lookupType value:value];
    };
}

- (void)showWindowWithLookupHandler:(void (^)(GlyphLookupType, NSString *))handler {
    GlyphLookupViewController * vc = (GlyphLookupViewController*)self.contentViewController;
    
    vc.lookupHander = handler;
    [self.window makeKeyAndOrderFront:self];
}

- (void)toggleWindow:(id)sender {
    if (!self.window.isVisible)
        [self.window makeKeyAndOrderFront:sender];
    else
        [self.window orderOut:sender];
}

+(GlyphLookupWindowController*)sharedGlyphLookupWindowController {
    if (lookupWindowController)
        return lookupWindowController;
    
    lookupWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"glyphLookupWindowController"];
    return lookupWindowController;
}

@end


@implementation GlyphLookupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.lookupTypeSegments setSelectedSegment:0];
    [self doChangeLookupType: self];
    self.lookupValueTextEdit.delegate = self;
    
}

- (IBAction)doChangeLookupType:(id)sender {
    _lookupType = self.lookupTypeSegments.selectedSegment;
    switch (_lookupType - 1) {
        case GlyphLookupByCharcode:
            [self.lookupValueTextEdit setPlaceholderString:@"U+DEAD, 0xBEEF, \\uFB01, uniFB02, 12345"];
            break;
        case GlyphLookupByGlyphIndex:
            [self.lookupValueTextEdit setPlaceholderString:@"1234"];
            break;
        case GlyphLookupByName:
            [self.lookupValueTextEdit setPlaceholderString:@"fi"];
            break;
        case -1:
            [self.lookupValueTextEdit setPlaceholderString:@"U+DEAD, 0xBEEF, \\uFB01, uniFB02, 12345, \\g123, ffi"];
            break;
    }
    [self.lookupValueTextEdit setStringValue:@""];
}

- (IBAction)doLookup:(id)sender {
    _lookupType = self.lookupTypeSegments.selectedSegment - 1;
    _lookupValue = self.lookupValueTextEdit.stringValue;
    
    if (_lookupHander)
        _lookupHander(_lookupType, _lookupValue);
        
}

-(void)controlTextDidChange:(NSNotification *)obj{

    
    NSTextView * fieldEditor = [[obj userInfo] objectForKey:@"NSFieldEditor"];
    
    if (self.isAutocompleting == NO  && !self.backspaceKey) {
        self.isAutocompleting = YES;
        self.lastEntry = [[[fieldEditor string] uppercaseString] copy];
        [fieldEditor complete:nil];
        self.isAutocompleting = NO;
    }
    
    if (self.backspaceKey) {
        self.backspaceKey = NO;
    }
    
}


-(NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index{
    
    TypefaceDocumentController* tdc = (TypefaceDocumentController*)[TypefaceDocumentController sharedDocumentController];
    Typeface * tf = ((TypefaceDocument *)tdc.currentDocument).typeface;
    
    NSMutableArray * suggestions = [NSMutableArray array];
    NSArray * possibleStrings = tf.glyphNames;
    
    if (!self.lastEntry || !possibleStrings) {
        return @[];
    }
    
    for (NSString * string in possibleStrings) {
        NSRange range = [string rangeOfString:self.lastEntry options:NSAnchoredSearch|NSCaseInsensitiveSearch];
        if (range.location == 0 && range.length == self.lastEntry.length)
            [suggestions addObject:string];
    }
    
    return suggestions;
}

-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector{
    if (commandSelector == @selector(deleteBackward:)) {
        self.backspaceKey = YES;
    }
    return NO;
}



@end
