#import <AppKit/AppKit.h>
#import "AppDelegate.h"
#import "Typeface.h"
#import "TypefaceManager.h"
#import "TypefaceDocumentController.h"
#import "TypefaceWindowController.h"
#import "LuaScriptConsole.h"

@interface TMProgressViewController ()
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *fileLabel;
- (void)updateProgress:(NSUInteger)progress ofTotal:(NSUInteger)total currentFile:(NSString*)file;
@end

@implementation TMProgressViewController
- (void)updateProgress:(NSUInteger)progress ofTotal:(NSUInteger)total currentFile:(NSString*)file {
    self.fileLabel.stringValue = file;
    [self.view setNeedsDisplay:YES];
}
@end

@interface AppDelegate()
{
    BOOL applicationHasStarted;
    NSWindowController * progressWindowController;
    TMProgressViewController * progressViewController;
}
@property (weak) IBOutlet NSMenu *devKitsMenu;
@property (weak) IBOutlet NSMenu *devLinksMenu;
@end

@implementation AppDelegate

@synthesize window = _windows;

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(TMProgress:)
                                                 name:TMProgressNotification
                                               object:nil];
    
    [[TypefaceManager defaultManager] initFTLib];
    
    [self loadDevLinkSubMenu];
}

- (void)TMProgress:(NSNotification*)notification {
#if 0
    if (!progressWindowController) {
        progressWindowController = [[NSStoryboard storyboardWithName:@"TMProgress" bundle:nil] instantiateControllerWithIdentifier:@"progressWindowController"];
        
        progressViewController = (TMProgressViewController*)(progressWindowController.contentViewController);
        [progressWindowController.window makeKeyAndOrderFront:self];
        //[NSApp runModalForWindow:progressWindowController.window];
    }
#endif
    // TODO: progress UI
    
    NSString * file = [notification.userInfo objectForKey:TMProgressNotificationFileKey];
    NSNumber * total = [notification.userInfo objectForKey:TMProgressNotificationTotalKey];
    NSNumber * current = [notification.userInfo objectForKey:TMProgressNotificationCurrentKey];
    
    [progressViewController updateProgress:current.integerValue
                                   ofTotal:total.integerValue
                               currentFile:file];
    NSLog(@"%@/%@ %@", current, total, file);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[TypefaceManager defaultManager] doneFTLib];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    [(TypefaceDocumentController*)[NSDocumentController sharedDocumentController] openFontFromList:nil];
    return NO;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    return [(TypefaceDocumentController*)[NSDocumentController sharedDocumentController] openFontFromFilePath:[NSURL fileURLWithPath:filename]];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

- (void)openURL:(NSURL *)url {
    if ([url.scheme isEqualToString:@"lookup"]) {
        TypefaceDocument * document = (TypefaceDocument *)[NSDocumentController sharedDocumentController].currentDocument;
        TypefaceWindowController * wc = document.mainWindowController;
        [wc lookupGlyphWithExpression:url.host];
    }
    else {
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}

- (IBAction)showLuaConsole:(id)sender {
    [[[LuaScriptConsoleWindowController sharedWindowController] window] makeKeyAndOrderFront:sender];
}

- (void)loadDevLinkSubMenu {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"DevLinks" ofType:@"plist"];
    if (!path) return;
    
    NSArray<NSString*> * links = [[NSArray<NSString*> alloc] initWithContentsOfFile:path];
    
    for (NSUInteger i = 0; i < links.count; i += 2) {
        NSString * name = links[i];
        NSString * url = links[i+1];
        NSMenuItem * item = [self.devLinksMenu addItemWithTitle:name
                                                         action:@selector(doOpenDevLink:)
                                                  keyEquivalent:@""];
        [item setRepresentedObject:url];
    }
    
}

- (IBAction)doOpenDevLink:(id)sender {
    if ([[sender class] isSubclassOfClass:[NSMenuItem class]]) {
        NSMenuItem * item = (NSMenuItem*)sender;
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:item.representedObject]];
    }
}

@end
