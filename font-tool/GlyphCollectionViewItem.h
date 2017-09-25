//
//  GlyphCollectionViewItem.h
//  tx-research
//
//  Created by Yuqing Jiang on 5/15/17.
//
//

#import <Cocoa/Cocoa.h>
#import "TypefaceDocument.h"

@class GlyphImageView;
@class GlyphCollectionViewItem;

@protocol GlyphCollectionViewItemDelegate <NSObject>
@optional
- (void) doubleClickGlyphCollectionViewItem:(GlyphCollectionViewItem*)item;
- (void) rightClickGlyphCollectionViewItem:(GlyphCollectionViewItem*)item event:(NSEvent*)event;
@end


typedef NS_ENUM(NSInteger, GlyphLabelCategory) {
    GlyphLabelByName,
    GlyphLabelByGlyphIndex,
    GlyphLabelByCode,
};

@interface GlyphCollectionViewItem : NSCollectionViewItem
@property (assign) IBOutlet NSTextField *glyphNameLabel;
@property (assign) IBOutlet GlyphImageView *glyphImageView;

@property (nonatomic, strong) TypefaceDocument * document;
@property (nonatomic, strong) TypefaceGlyphcode * glyphCode;

@property (nonatomic, assign) NSObject<GlyphCollectionViewItemDelegate> * delegate;
@property (retain) NSIndexPath * indexPath;

- (void)setGlyphCode:(TypefaceGlyphcode*)gc ofDocument:(TypefaceDocument*)document GlyphLabelCategory:(GlyphLabelCategory)category;

@end
