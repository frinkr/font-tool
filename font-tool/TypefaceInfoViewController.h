//
//  FontInfoViewController.h
//  tx-research
//
//  Created by Yuqing Jiang on 5/15/17.
//
//

#import <Cocoa/Cocoa.h>
#import "HtmlTableView.h"

@class TypefaceDocument;

@interface TypefaceInfoWindowController : NSWindowController<NSWindowDelegate>
+ (instancetype)togglePanelWithDocument:(TypefaceDocument*)document masterWindow:(NSWindow*)masterWindow sender:(id)sender;
@end

@interface TypefaceInfoViewController : NSViewController <HtmlTableViewDataSource, HtmlTableViewDelegate>

@end
