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
    TypefaceDocument * document = self.view.window.windowController.document;
    [self setRepresentedObject:document];
    
    NSCollectionViewFlowLayout * layout = self.collectionView.collectionViewLayout;
    [document.typeface setPixelSize:(layout.itemSize.width - 5)*1];
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
    return [self.document.currentCMap.glyphBlocks objectAtIndex:self.currentBlockIndex];
}

- (NSInteger)currentBlockIndex {
    return _currentBlockIndex;
}

- (void)setCurrentBlockIndex:(NSInteger)currentBlockIndex {
    _currentBlockIndex = currentBlockIndex;
    [self.collectionView reloadData];
}

- (GlyphLabelCategory)glyphLabelCategory {
    return _glyphLabelCategory;
}

- (void)setGlyphLabelCategory:(GlyphLabelCategory)glyphLabelCategory {
    _glyphLabelCategory = glyphLabelCategory;
    [self.collectionView reloadData];
}

- (void)selectGlyphAtIndex:(NSUInteger)index {
    // deselect all
    [self.collectionView deselectItemsAtIndexPaths:[self.collectionView selectionIndexPaths]];
    
    NSIndexPath * path = [NSIndexPath indexPathForItem:index inSection:0];
    NSSet<NSIndexPath*> * set = [NSSet setWithObjects:path, nil];
    [self.collectionView selectItemsAtIndexPaths:set scrollPosition:NSCollectionViewScrollPositionCenteredVertically];
}

#pragma mark *** NSCollectionView datasource and delegate ***
- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentBlock.numOfGlyphs;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    GlyphCollectionViewItem * item = [collectionView makeItemWithIdentifier:@"GlyphCollectionViewItem" forIndexPath:indexPath];
    item.delegate = self;
    
    NSUInteger index = indexPath.item;
    TypefaceGlyphcode * gc = [self.currentBlock glyphCodeAtIndex:index];
    [item setGlyphCode:gc
            ofDocument:self.document
    GlyphLabelCategory:self.glyphLabelCategory];

    return item;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    if ([self.delegate respondsToSelector:@selector(glyphViewController:selectGlyphAtIndex:)]) {
        NSIndexPath * path = [indexPaths anyObject];
        [self.delegate glyphViewController:self selectGlyphAtIndex:path.item];
    }
}

- (void)doubleClickGlyphCollectionViewItem:(GlyphCollectionViewItem *)item {
    [[GlyphInfoViewController createViewController] showPopoverRelativeToRect:item.view.bounds
                                                                       ofView:item.view
                                                                preferredEdge:NSRectEdgeMaxY
                                                                    withGlyph:item.glyphCode
                                                                   ofDocument:item.document];
}

@end
