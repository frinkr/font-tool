//
//  TypefaceStylesWindowController.h
//  tx-research
//
//  Created by Yuqing Jiang on 5/17/17.
//
//

#import <Cocoa/Cocoa.h>

@interface TypefaceStylesWindowController : NSWindowController
+ (NSInteger) selectTypefaceOfFile:(NSURL*)url; // -1, cancel
@end

@interface TypefaceStylesViewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate>
- (IBAction)cancelTypefaceSelection:(id)sender;
- (IBAction)confirmTypeFaceSelection:(id)sender;
@end


