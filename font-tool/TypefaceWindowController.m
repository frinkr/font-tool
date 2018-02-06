//
//  FontWindowController.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/16/17.
//
//
#import "GlyphCollectionViewController.h"
#import "GlyphInfoViewController.h"
#import "GlyphTableWindowController.h"
#import "TypefaceWindowController.h"
#import "TypefaceDocumentController.h"
#import "TypefaceInfoViewController.h"
#import "TypefaceVariationViewController.h"
#import "ShapingWindowController.h"
#import "CharEncoding.h"
#import "AppDelegate.h"

@interface TypefaceWindowController () <GlyphTableDelegate>
@property (assign) IBOutlet NSComboBox * glyphListCombobox;
@property (weak) IBOutlet NSPopUpButton *cmapPopupButton;
@property (weak) IBOutlet NSSearchField *searchField;

@property (nonatomic) BOOL isAutocompleting;
@property (nonatomic, strong) NSString * lastEntry;
@property (nonatomic) BOOL backspaceKey;

@property (nonatomic, getter=glyphCollectionViewController) GlyphCollectionViewController * glyphCollectionViewController;
@property (nonatomic, getter=typefaceDocument) TypefaceDocument * typefaceDocument;
@end

@implementation TypefaceWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setDocument:(id)document {
    [super setDocument:document];
    
    [self.typefaceDocument.typeface addObserver:self
                            forKeyPath:@"currentVariation"
                               options:NSKeyValueObservingOptionNew
                               context:nil];
    
    // build cmap list
    [self.cmapPopupButton removeAllItems];
    for (NSUInteger index = 0; index < self.typefaceDocument.cmaps.count; ++ index) {
        TypefaceCMap * cm = [self.typefaceDocument.cmaps objectAtIndex:index];
        [self.cmapPopupButton addItemWithTitle:cm.name];
    }
    [self selectCMapAtIndex: 0];
    
    // switch to unicode labels if font doesn't have glyph names
    if (!self.typefaceDocument.typeface.hasCanonicalGlyphNames)
        self.glyphCollectionViewController.glyphLabelCategory = GlyphLabelByCode;
}

- (BOOL)shouldCloseDocument {
    // make the other WindowController close when closing the main window.
    return YES;
}

#pragma mark *** Actions ***
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ((object == self.typefaceDocument.typeface) && [keyPath isEqualToString:@"currentVariation"]) {
        [self.glyphCollectionViewController reload];
    }
}

#pragma mark *** Actions ***
- (IBAction)changeGlyphsLabel:(id)sender {
    NSUInteger cat = 0;
    if ([sender isKindOfClass:[NSSegmentedControl class]])
        cat = ((NSSegmentedControl*)sender).selectedSegment;
    else if ([sender isKindOfClass:[NSMenuItem class]])
        cat = ((NSMenuItem*)sender).tag;
    else
        return;
    self.glyphCollectionViewController.glyphLabelCategory = (GlyphLabelCategory)cat;
}

- (IBAction)changeGlyphList:(id)sender {
    [self selectGlyphListAtIndex:[self.glyphListCombobox indexOfSelectedItem]];
}

- (IBAction)selectVariant:(id)sender {
    if (!self.typefaceDocument.typeface.isAdobeMM && !self.typefaceDocument.typeface.isOpenTypeVariation) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"The font is not an OpenType Variant or Adobe Multiple Master."];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        return;
    }
        
    TypefaceVariationViewController * vc = [TypefaceVariationViewController createViewController];
    NSView * view = nil;
    if ([sender isKindOfClass:[NSView class]])
        view = (NSView*)sender;
    else if ([sender isKindOfClass:[NSToolbarItem class]])
        view = [(NSToolbarItem*)sender view];
    
    [vc showPopoverRelativeToRect:view.bounds
                           ofView:view
                    preferredEdge:NSRectEdgeMaxY
                     withDocument:self.typefaceDocument];
}

- (IBAction)changeCMap:(id)sender {
    [self selectCMapAtIndex:[self.cmapPopupButton indexOfSelectedItem]];
}

- (IBAction)lookupCharacter:(id)sender {
    [self.window makeFirstResponder:self.searchField];
}

- (IBAction)doLookup:(id)sender {
    [self lookupGlyphWithType:-1 /*smart*/ value:self.searchField.stringValue];
}

- (IBAction)doShapping:(id)sender {
    [ShapingWindowController createWithDocument:self.typefaceDocument
                                   parentWindow:nil
                                     bringFront:YES];
    //[self.typefaceDocument addWindowController:wc];
}

- (IBAction)showGlyphTable:(id)sender {
    GlyphTableWindowController * wc = [GlyphTableWindowController createWithDocument:self.typefaceDocument
                                                                        parentWindow:nil
                                                                          bringFront:YES];
    GlyphTableViewController * vc = (GlyphTableViewController*) wc.contentViewController;
    vc.tableDelegate = self;
}

- (IBAction)showFontInfo:(id)sender {
    [TypefaceInfoWindowController togglePanelWithDocument:self.document masterWindow:self.window sender:sender];
}

- (void)selectCMapAtIndex:(NSUInteger)index {
    [self.cmapPopupButton selectItemAtIndex:index];
    
    [self.typefaceDocument selectCMapAtIndex:index];
    
    [self.glyphListCombobox reloadData];
    if (self.typefaceDocument.currentCMap.isUnicode)
        [self selectGlyphListAtIndex:UNICODE_COMPACT_REPERTOIRE];
    else
        [self selectGlyphListAtIndex:FULL_GLYPH_LIST_BLOCK_INDEX];
}

- (void)selectGlyphListAtIndex:(NSUInteger)index {
    if (index >= self.glyphListCombobox.numberOfItems)
        index = 0;
    [self.glyphListCombobox selectItemAtIndex:index];
    self.glyphCollectionViewController.currentBlockIndex = index;
    
    [self.window makeFirstResponder:self.glyphCollectionViewController.collectionView];
}

- (void)glyphTable:(NSTableView *)tableView didSelectIndex:(NSUInteger)index {
    [self.window makeKeyAndOrderFront:self];
    [self lookupGlyphWithType:GlyphLookupByGlyphIndex
                        value:[NSString stringWithFormat:@"%ld", index]];
}

#pragma mark *** Menu updater ***
- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {
    if ([item action] == @selector(changeGlyphsLabel:)) {
        // This method is also used for toolbar items, so it's a good idea to
        // make sure you're validating a menu item here
        if ([(id)item respondsToSelector:@selector(setState:)]) {
            if (item.tag == self.glyphCollectionViewController.glyphLabelCategory)
                [(id)item setState:NSOnState];
            else
                [(id)item setState:NSOffState];
        }
    }
    return YES;
}

#pragma mark *** Lookup ***
- (void)lookupGlyphWithExpression:(NSString*)expression {
     [self lookupGlyph:[GlyphLookupRequest createRequestWithExpression:expression
                                                         preferedBlock:self.indexOfSelectedGlyphBlock]];
}

- (void)lookupGlyphWithType:(GlyphLookupType)type value:(NSString *)value {
    GlyphLookupRequest * request = nil;
    if(type == (GlyphLookupType)-1) {
        request = [GlyphLookupRequest createRequestWithExpression:value preferedBlock:self.indexOfSelectedGlyphBlock];
    }
    else {
        switch(type) {
            case GlyphLookupByName:
                request = [GlyphLookupRequest createRequestWithName:value preferedBlock:self.indexOfSelectedGlyphBlock];
                break;
            case GlyphLookupByGlyphIndex: {
                NSInteger index = [CharEncoding gidOfString:value];
                if (index != INVALID_CODE_POINT)
                    request = [GlyphLookupRequest createRequestWithId:index preferedBlock:self.indexOfSelectedGlyphBlock];
            } break;
            case GlyphLookupByCodepoint: {
                NSInteger code = [CharEncoding codepointOfString:value];
                if (code != INVALID_CODE_POINT)
                    request = [GlyphLookupRequest createRequestWithCodepoint:code preferedBlock:self.indexOfSelectedGlyphBlock];
            } break;
        }
    }
    
    return [self lookupGlyph:request];
}

- (void)lookupGlyph:(GlyphLookupRequest*)request {
    if (!request)
        return;
    [self.typefaceDocument.typeface lookupGlyph: request
                                completeHandler:^(NSUInteger blockIndex, NSUInteger sectionIndex, NSUInteger itemIndex, NSError * error) {
                                    if (error)
                                        return;
                                    [self selectGlyphAtBlockIndex:blockIndex sectionIndex:sectionIndex itemIndex:itemIndex];
                                    
                                }];
}

- (NSUInteger)indexOfSelectedGlyphBlock {
    return self.glyphListCombobox.indexOfSelectedItem;
}

- (void)selectGlyphAtBlockIndex:(NSUInteger)blockIndex sectionIndex:(NSUInteger) sectionIndex itemIndex:(NSUInteger)itemIndex {
    if (blockIndex != self.glyphListCombobox.indexOfSelectedItem)
        [self selectGlyphListAtIndex:blockIndex];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.glyphCollectionViewController selectItem:itemIndex
                                             inSection:sectionIndex
                                        scrollPosition:NSCollectionViewScrollPositionCenteredVertically];
    });
}

#pragma mark *** Search field ***
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

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    if (notification.object == self.searchField) {
        [self doLookup:self.searchField];
    }
}

-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector{
    if (commandSelector == @selector(deleteBackward:)) {
        self.backspaceKey = YES;
    }
    return NO;
}

-(NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index{
    
    Typeface * tf = self.typefaceDocument.typeface;
    
    NSMutableArray * suggestions = [NSMutableArray array];
    NSArray * possibleStrings = tf.glyphNames;
    
    if (!self.lastEntry || !possibleStrings) {
        return @[];
    }
    
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"U\\+%@", UNI_CODEPOINT_REGEX]
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    
    for (NSString * string in possibleStrings) {
        NSRange range = [regex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
        if (range.length == 0) { // don't include artificial names
            range = [string rangeOfString:self.lastEntry options:NSAnchoredSearch|NSCaseInsensitiveSearch];
            if (range.location == 0 && range.length == self.lastEntry.length)
                [suggestions addObject:string];
        }
    }
    
    return suggestions;
}

#pragma mark *** Getters ***

- (GlyphCollectionViewController*)glyphCollectionViewController {
    if ([self.contentViewController isKindOfClass:[GlyphCollectionViewController class]])
        _glyphCollectionViewController = (GlyphCollectionViewController*)self.contentViewController;
    return _glyphCollectionViewController;
}

- (TypefaceDocument*)typefaceDocument {
    _typefaceDocument = (TypefaceDocument*)self.document;
    return _typefaceDocument;
}


#pragma mark *** NSComboboxDataSource ***

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox {
    if (comboBox == self.glyphListCombobox)
        return self.typefaceDocument.currentCMap.blocks.count;
    else
        return 0;
}

- (nullable id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
    if (comboBox == self.glyphListCombobox)
        return [self.typefaceDocument.currentCMap.blocks objectAtIndex:index].name;
    else
        return nil;
}

- (NSString*)comboBox:(NSComboBox *)comboBox completedString:(NSString *)string {
    if (comboBox == self.glyphListCombobox) {
        NSString * maxPrefixMatch = @"";
        NSUInteger maxPrefixMatchLength = 0;
        
        for (TypefaceGlyphBlock * block in self.typefaceDocument.currentCMap.blocks) {
            NSString * prefix = [block.name commonPrefixWithString:string options:NSCaseInsensitiveSearch];
            if (prefix.length > maxPrefixMatchLength) {
                maxPrefixMatch = block.name;
                maxPrefixMatchLength = prefix.length;
            }
        }
        return maxPrefixMatch;
    }
    return @"";
}

- (NSUInteger)comboBox:(NSComboBox *)comboBox indexOfItemWithStringValue:(NSString *)string {
    if (comboBox == self.glyphListCombobox) {
        NSArray<TypefaceGlyphBlock*> * blocks = self.typefaceDocument.currentCMap.blocks;
        for (NSUInteger i = 0; i < blocks.count; ++ i) {
            if ([[blocks objectAtIndex:i].name isEqualToString:string])
                return i;
        }
        return -1;
    }
    return -1;
}

@end
