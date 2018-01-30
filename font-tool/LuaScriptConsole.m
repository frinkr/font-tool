//
//  LuaScriptConsole.m
//  font-tool
//
//  Created by Yuqing Jiang on 1/22/18.
//

#import "LuaScriptConsole.h"

static LuaScriptConsoleWindowController * sSharedInstance;
static NSDateFormatter *sDateFormatter;

static NSString * currentDateTimeString() {
    NSDate *currDate = [NSDate date];
    if (!sDateFormatter) {
        sDateFormatter = [[NSDateFormatter alloc]init];
        [sDateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ssZZZZZ"];
    }
    NSString *dateString = [sDateFormatter stringFromDate:currDate];
    return dateString;
}

@interface LuaScriptConsoleWindowController ()
@property (weak) IBOutlet NSPanel *panel;
@end


@interface LuaScriptConsoleViewController ()
@property (unsafe_unretained) IBOutlet NSTextView *messagesTextView;
@property (strong) NSMutableString * cachedMessages;
- (void)flushMessages:(id)sender;
@end


@implementation LuaScriptConsoleWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.panel.worksWhenModal = YES;
    
    NSTitlebarAccessoryViewController * titleVc = [[NSStoryboard storyboardWithName:@"LuaScriptConsole" bundle:nil] instantiateControllerWithIdentifier:@"titleBarAccessoryViewController"];
    titleVc.layoutAttribute = NSLayoutAttributeLeft;
    
    NSButton * saveButton = [titleVc.view.subviews objectAtIndex:0];
    [saveButton setTarget:self];
    [saveButton setAction:@selector(doSave:)];
    NSButton * clearButton = [titleVc.view.subviews objectAtIndex:1];
    [clearButton setTarget:self];
    [clearButton setAction:@selector(doClear:)];
    
    [self.panel addTitlebarAccessoryViewController:titleVc];
    
    LuaScriptConsoleViewController * vc = (LuaScriptConsoleViewController*)self.contentViewController;

    vc.messagesTextView.editable = NO;
}

- (IBAction)doSave:(id)sender {
    LuaScriptConsoleViewController * vc = (LuaScriptConsoleViewController*)self.contentViewController;

    
    NSSavePanel*  panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:@[@"log"]];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSFileHandlingPanelOKButton) {
            [vc.messagesTextView.string writeToURL:panel.URL
                                        atomically:YES
                                          encoding:NSUTF8StringEncoding
                                             error:NULL];
        }
    }];
}

- (IBAction)doClear:(id)sender {
    LuaScriptConsoleViewController * vc = (LuaScriptConsoleViewController*)self.contentViewController;
    [vc.messagesTextView setString: @""];
}

+(LuaScriptConsoleWindowController*)sharedWindowController {
    if (sSharedInstance)
        return sSharedInstance;
    
    sSharedInstance = [[NSStoryboard storyboardWithName:@"LuaScriptConsole" bundle:nil] instantiateInitialController];
    
    return sSharedInstance;
}

- (void)appendMessage:(NSString *)message {
    if (!self.window.isVisible)
        [self.window makeKeyAndOrderFront:nil];
    [(LuaScriptConsoleViewController*)self.contentViewController appendMessage:message];
}

- (void)flushMessages:(id)sender {
    if (!self.window.isVisible)
        [self.window makeKeyAndOrderFront:nil];
    [(LuaScriptConsoleViewController*)self.contentViewController flushMessages:sender];
}
@end


@implementation LuaScriptConsoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cachedMessages = [[NSMutableString alloc] init];
    
    // disable word wrap to make text layout faster
    NSSize bigSize = NSMakeSize(FLT_MAX, FLT_MAX);
    [self.messagesTextView.enclosingScrollView setHasHorizontalScroller:YES];
    [self.messagesTextView setHorizontallyResizable:YES];
    [self.messagesTextView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [self.messagesTextView.textContainer setContainerSize:bigSize];
    [self.messagesTextView.textContainer setWidthTracksTextView:NO];
    
}

- (void)flushMessages:(id)sender {
    if ([self.cachedMessages length] == 0)
        return;
    [self.messagesTextView.textStorage beginEditing];
    
    NSAttributedString* attr = [[NSAttributedString alloc] initWithString:self.cachedMessages
                                                               attributes:@{NSForegroundColorAttributeName : [NSColor greenColor],
                                                                            //NSFontAttributeName: @"Courier New 12"
                                                                            }];
    [[self.messagesTextView textStorage] appendAttributedString:attr];
    [[self.messagesTextView textStorage] setFont:[NSFont fontWithName:@"Courier New" size:12]];
    [self.messagesTextView.textStorage endEditing];
    
    [self.cachedMessages setString:@""];
    //[self.messagesTextView scrollToEndOfDocument:self]; // scroll make it slow
}

- (void)appendMessage:(NSString *)message {
    [self.cachedMessages appendFormat:@"%@ : %@\n", currentDateTimeString(), message];
}

@end
