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
#import "Common.h"

@interface GlyphCollectionViewController ()
@property (nonatomic, readonly, getter=document) TypefaceDocument * document;
@property (nonatomic, readonly, getter=currentBlock) TypefaceGlyphBlock * block;
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

- (TypefaceGlyphBlock*)currentBlock {
    return [self.document.currentCMap.blocks objectAtIndex:self.currentBlockIndex];
}

- (NSInteger)currentBlockIndex {
    return _currentBlockIndex;
}

- (void)setCurrentBlockIndex:(NSInteger)currentBlockIndex {
    _currentBlockIndex = currentBlockIndex;
    
    if (OS_IS_BELOW_SIERRA || YES) {
        // For some reason, 'itemForRepresentedObjectAtIndexPath' is not called upon 'reloadData' in Yosemit/High Sierra
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
    else {
        [self.collectionView reloadData];
    }
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
    [self selectItem:item.indexPath.item
           inSection:item.indexPath.section
     scrollPosition:NSCollectionViewScrollPositionNone];
}

@end
