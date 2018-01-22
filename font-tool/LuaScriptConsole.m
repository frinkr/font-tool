//
//  LuaScriptConsole.m
//  font-tool
//
//  Created by Yuqing Jiang on 1/22/18.
//

#import "LuaScriptConsole.h"

static LuaScriptConsoleWindowController * sSharedInstance;

static NSString * currentDateTimeString() {
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ssZZZZZ"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    return dateString;
}

@interface LuaScriptConsoleWindowController ()
@property (weak) IBOutlet NSPanel *panel;
@end


@interface LuaScriptConsoleViewController ()
@property (unsafe_unretained) IBOutlet NSTextView *messagesTextView;
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
@end


@implementation LuaScriptConsoleViewController

- (void)appendMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * text = [NSString stringWithFormat:@"%@ : %@\n", currentDateTimeString(), message];
        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName : [NSColor greenColor]}];
        
        [[self.messagesTextView textStorage] appendAttributedString:attr];
        [self.messagesTextView scrollRangeToVisible:NSMakeRange([[self.messagesTextView string] length], 0)];
    });
}

@end
