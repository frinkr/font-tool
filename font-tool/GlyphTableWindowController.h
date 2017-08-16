//
//  GlyphTableWindowController.h
//  tx-research
//
//  Created by Yuqing Jiang on 6/23/17.
//
//

#import <Cocoa/Cocoa.h>
@class TypefaceDocument;
@class GlyphTableViewController;

@interface GlyphTableWindowController : NSWindowController
+ (instancetype)createWithDocument:(TypefaceDocument*)document parentWindow:(NSWindow*)parentWindow bringFront:(BOOL)bringFront;
@end


@protocol GlyphTableDelegate <NSObject>

- (void)glyphTable:(NSTableView*)tableView didSelectIndex:(NSUInteger)index;

@end

@interface GlyphTableViewController : NSViewController<NSTableViewDataSource>
@property (weak) id<GlyphTableDelegate> tableDelegate;
@end
