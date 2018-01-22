//
//  LuaScriptConsole.m
//  font-tool
//
//  Created by Yuqing Jiang on 1/22/18.
//

#import "LuaScriptConsole.h"

static LuaScriptConsoleWindowController * sSharedInstance;

@interface LuaScriptConsoleWindowController ()

@end

@implementation LuaScriptConsoleWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
}

+(LuaScriptConsoleWindowController*)sharedWindowController {
    if (sSharedInstance)
        return sSharedInstance;
    
    sSharedInstance = [[NSStoryboard storyboardWithName:@"LuaScriptConsole" bundle:nil] instantiateInitialController];
    
    return sSharedInstance;
}

- (void)appendMessage:(NSString *)message {
    [(LuaScriptConsoleViewController*)self.contentViewController appendMessage:message];
}
@end


@interface LuaScriptConsoleViewController ()
@property (unsafe_unretained) IBOutlet NSTextView *messagesTextView;
@end

@implementation LuaScriptConsoleViewController

- (void)appendMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:message];
        
        [[self.messagesTextView textStorage] appendAttributedString:attr];
        [self.messagesTextView scrollRangeToVisible:NSMakeRange([[self.messagesTextView string] length], 0)];
    });
}

@end
