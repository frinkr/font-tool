#import <AppKit/NSApplication.h>

@class FontDocumentController;

@interface TMProgressViewController : NSViewController
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

@property (assign, nonatomic) IBOutlet NSWindow *window;
@property (assign) IBOutlet FontDocumentController *fontDocumentController;

- (void)openURL:(NSURL*)url;
- (IBAction)lookupGlyph:(id)sender;
@end
