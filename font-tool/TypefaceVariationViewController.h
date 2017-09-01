//
//  TypefaceVariationViewController.h
//  tx-master
//
//  Created by Yuqing Jiang on 8/31/17.
//
//

#import <Cocoa/Cocoa.h>

@class TypefaceDocument;

@interface TypefaceVariationViewController : NSViewController<NSPopoverDelegate, NSComboBoxDataSource, NSComboBoxDelegate>
- (void)forceLoadView;

- (void)showPopoverRelativeToRect:(NSRect)rect
                           ofView:(NSView*)view
                    preferredEdge:(NSRectEdge)preferredEdge
                       withDocument:(TypefaceDocument*)document;

+ (instancetype)createViewController;

@end
