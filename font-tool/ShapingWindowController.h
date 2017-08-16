//
//  ShapingWindowController.h
//  tx-research
//
//  Created by Yuqing Jiang on 6/5/17.
//
//

#import <Cocoa/Cocoa.h>

@class ShapingView;
@class TypefaceDocument;

@protocol ShapingViewDelegate <NSObject>
- (void)shapingView:(ShapingView*)view doubleClickGlyph:(NSInteger)gid;
@end

@interface ShapingView : NSView
@property (nonatomic, assign) IBOutlet id<ShapingViewDelegate> delegate;

@end

@interface ShapingFeatureListView : NSTableView
@end

@interface ShapingWindowController : NSWindowController<NSWindowDelegate>
+(instancetype)createWithDocument:(TypefaceDocument*)document parentWindow:(NSWindow*)parentWindow bringFront:(BOOL)bringFront;
@end

@interface ShapingViewController : NSViewController<NSTableViewDelegate>
@property (weak) IBOutlet NSPopUpButton *languageScriptPopUpButton;
@property (weak) IBOutlet NSTextField *textInputField;
@property (weak) IBOutlet NSTableView *featuresListView;
@property (weak) IBOutlet ShapingView *shapingView;
@property (weak) IBOutlet NSScrollView *shapingScrollView;

@end
