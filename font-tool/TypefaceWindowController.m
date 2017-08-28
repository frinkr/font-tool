//
//  FontWindowController.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/16/17.
//
//
#import "GlyphLookupWindowController.h"
#import "GlyphCollectionViewController.h"
#import "GlyphInfoViewController.h"
#import "GlyphTableWindowController.h"
#import "TypefaceWindowController.h"
#import "TypefaceDocumentController.h"
#import "TypefaceInfoViewController.h"
#import "ShapingWindowController.h"
#import "CharEncoding.h"
#import "AppDelegate.h"

@interface TypefaceWindowController () <GlyphTableDelegate>
@property (assign) IBOutlet NSComboBox * glyphListCombobox;
@property (assign) IBOutlet NSComboBox *cmapCombobox;

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
    
    [self.cmapCombobox reloadData];
    [self selectCMapAtIndex: 0];
}

- (BOOL)shouldCloseDocument {
    // make the other WindowController close when closing the main window.
    return YES;
}

#pragma mark *** Actions ***
- (IBAction)changeGlyphsLabel:(NSSegmentedControl*)sender {
    self.glyphCollectionViewController.glyphLabelCategory = (GlyphLabelCategory)sender.selectedSegment;
}

- (IBAction)changeGlyphList:(id)sender {
    [self selectGlyphListAtIndex:[self.glyphListCombobox indexOfSelectedItem]];
}

- (IBAction)changeCMap:(id)sender {
    [self selectCMapAtIndex:[self.cmapCombobox indexOfSelectedItem]];
}

- (IBAction)lookupCharacter:(id)sender {
    [(AppDelegate*)NSApp.delegate lookupGlyph:sender];
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
    [self.cmapCombobox selectItemAtIndex:index];
    
    [self.typefaceDocument selectCMapAtIndex:index];
    
    [self.glyphListCombobox reloadData];
    [self selectGlyphListAtIndex:ALL_GLYPHS_BLOCK_INDEX];
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
            case GlyphLookupByCharcode: {
                NSInteger code = [CharEncoding charcodeOfString:value];
                if (code != INVALID_CODE_POINT)
                    request = [GlyphLookupRequest createRequestWithCharcode:code preferedBlock:self.indexOfSelectedGlyphBlock];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.glyphCollectionViewController selectItem:itemIndex inSection:sectionIndex];
    });
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
    if (comboBox == self.cmapCombobox)
        return [self.typefaceDocument cmaps].count;
    else if (comboBox == self.glyphListCombobox)
        return self.typefaceDocument.currentCMap.blocks.count;
    else
        return 0;
}

- (nullable id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
    if (comboBox == self.cmapCombobox)
        return [[self.typefaceDocument cmaps] objectAtIndex:index].name;
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
