//
//  GlyphCollectionViewController.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/15/17.
//
//

#import "TypefaceDocument.h"

#import "GlyphCollectionViewController.h"
#import "GlyphCollectionViewItem.h"
#import "GlyphInfoViewController.h"
#import "Typeface.h"
#import "CharEncoding.h"
#import "Common.h"
#import "AppDelegate.h"

@interface GlyphCollectionViewController ()
@property (nonatomic, readonly, getter=document) TypefaceDocument * document;
@property (nonatomic, readonly, getter=currentBlock) TypefaceGlyphBlock * block;
@property (strong) IBOutlet NSMenu *contextMenu;
@property (weak) IBOutlet NSMenuItem *menuItemCopyChar;
@property (weak) IBOutlet NSMenuItem *menuItemCopyCode;
@property (weak) IBOutlet NSMenuItem *menuItemSearch;
@end

@implementation GlyphCollectionViewController

@synthesize glyphLabelCategory = _glyphLabelCategory;
@synthesize currentBlockIndex = _currentBlockIndex;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    if (OS_IS_BELOW_SIERRA) {
        self.collectionView.wantsLayer = YES;
        self.collectionView.layer.backgroundColor = [[NSColor whiteColor] CGColor];
    }
    
    TypefaceDocument * document = self.view.window.windowController.document;
    [self setRepresentedObject:document];
    
    NSCollectionViewFlowLayout * layout = (NSCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    [document.typeface setPixelSize:(layout.itemSize.width - 5)*1];
}

- (void)reload {
    // For some reason, 'itemForRepresentedObjectAtIndexPath' is not called upon 'reloadData' in Yosemit/High Sierra,
    // so let's make a timer
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma marks *** Getter and Setters ***

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [self.collectionView reloadData];
}

- (TypefaceDocument*)document {
    return self.representedObject;
}

- (TypefaceCMap*)currentCMap {
    return self.document.currentCMap;
}
- (TypefaceGlyphBlock*)currentBlock {
    return [self.document.currentCMap.blocks objectAtIndex:self.currentBlockIndex];
}

- (NSInteger)currentBlockIndex {
    return _currentBlockIndex;
}

- (void)setCurrentBlockIndex:(NSInteger)currentBlockIndex {
    _currentBlockIndex = currentBlockIndex;
    [self reload];
}

- (GlyphLabelCategory)glyphLabelCategory {
    return _glyphLabelCategory;
}

- (void)setGlyphLabelCategory:(GlyphLabelCategory)glyphLabelCategory {
    _glyphLabelCategory = glyphLabelCategory;
    [self.collectionView reloadData];
}

- (void)selectItem:(NSUInteger)itemIndex inSection:(NSUInteger) sectionIndex scrollPosition: (NSCollectionViewScrollPosition) scrollPosition{
    [self.collectionView deselectItemsAtIndexPaths:[self.collectionView selectionIndexPaths]];
    
    NSIndexPath * path = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
    NSSet<NSIndexPath*> * set = [NSSet setWithObjects:path, nil];
    [self.collectionView selectItemsAtIndexPaths:set scrollPosition:scrollPosition];
}

- (NSIndexPath*)currentSelectionIndexPath {
    NSArray<NSIndexPath*> * indexes = self.collectionView.selectionIndexPaths.allObjects;
    if (!indexes.count)
        return nil;
    return [indexes objectAtIndex:0];
}

- (TypefaceGlyphcode*)currentGlyphCode {
    NSIndexPath* indexPath = [self currentSelectionIndexPath];
    NSUInteger section = indexPath.section;
    NSUInteger index = indexPath.item;
    TypefaceGlyphcode * gc = [[self.currentBlock.sections objectAtIndex:section] glyphCodeAtIndex:index];
    return gc;
}

- (codepoint_t)currentUnicode {
    TypefaceGlyphcode * code = self.currentGlyphCode;
    if (code && !code.isGID && self.currentCMap.isUnicode)
        return code.codepoint;
    return INVALID_CODE_POINT;
}

#pragma mark *** Actions ***

- (IBAction)copy:(id)sender {
    [self onCopyCharMenuItem:sender];
}

- (IBAction)onCopyCharMenuItem:(id)sender {
    codepoint_t code = self.currentUnicode;
    if (code != INVALID_CODE_POINT) {
        NSString * str = [CharEncoding NSStringFromUnicode:code];
        [self copyToPasteboard:str];
        [self postNotificationWithTitle:@"Character has been copied to pasteboard"  message:str];
    }
}

- (IBAction)onCopyCodeMenuItem:(id)sender {
    codepoint_t code = self.currentUnicode;
    if (code != INVALID_CODE_POINT)
        [self copyToPasteboard:[CharEncoding hexForCharcode:code unicodeFlavor:YES]];
}

- (IBAction)onSearchMenuItem:(id)sender {
    codepoint_t code = self.currentUnicode;
    if (code != INVALID_CODE_POINT) {
        NSString * url = [CharEncoding infoLinkOfUnicode:code];
        [(AppDelegate*)NSApp.delegate openURL:[NSURL URLWithString:url]];
    }
}

- (void)postNotificationWithTitle:(NSString*) title message:(NSString*)message {
    NSUserNotification * notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.informativeText = message;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)copyToPasteboard:(NSString*)string {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString: string forType:NSStringPboardType];
}

#pragma mark *** NSCollectionView datasource and delegate ***
- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return self.currentBlock.sections.count;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.currentBlock.sections objectAtIndex:section].numOfGlyphs;
}

- (NSView*)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:NSCollectionElementKindSectionHeader]) {
        NSView * view = [collectionView makeSupplementaryViewOfKind:kind withIdentifier:@"GlyphCollectionViewHeader" forIndexPath:indexPath];
        for (NSView * subView in view.subviews) {
            if ([subView isKindOfClass:[NSTextField class]]) {
                NSTextField * textField = (NSTextField*)subView;
                NSUInteger section = indexPath.section;
                textField.stringValue = [self.currentBlock.sections objectAtIndex:section].name;
                break;
            }
        }
        return view;
    }
    return nil;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    GlyphCollectionViewItem * item = [collectionView makeItemWithIdentifier:@"GlyphCollectionViewItem" forIndexPath:indexPath];
    item.delegate = self;
    item.indexPath = indexPath;
    
    NSUInteger section = indexPath.section;
    NSUInteger index = indexPath.item;
    TypefaceGlyphcode * gc = [[self.currentBlock.sections objectAtIndex:section] glyphCodeAtIndex:index];
    [item setGlyphCode:gc
            ofDocument:self.document
    GlyphLabelCategory:self.glyphLabelCategory];

    return item;
}


- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    if ([self.delegate respondsToSelector:@selector(glyphViewController:didSelectGlyphAtIndexPath:)]) {
        [self.delegate glyphViewController:self
                 didSelectGlyphAtIndexPath:[indexPaths anyObject]];
    }
}

- (void)doubleClickGlyphCollectionViewItem:(GlyphCollectionViewItem *)item {
    [[GlyphInfoViewController createViewController] showPopoverRelativeToRect:item.view.bounds
                                                                       ofView:item.view
                                                                preferredEdge:NSRectEdgeMaxY
                                                                    withGlyph:item.glyphCode
                                                                   ofDocument:item.document];
}

- (void)rightClickGlyphCollectionViewItem:(GlyphCollectionViewItem *)item event:(NSEvent *)event {
    if (!item.isSelected)
        return;
    
    [self.contextMenu popUpMenuPositioningItem:nil
                                    atLocation:[item.view convertPoint:event.locationInWindow fromView:nil]
                                        inView:item.view];
}

@end
