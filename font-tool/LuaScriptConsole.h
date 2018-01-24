//
//  LuaScriptConsole.h
//  font-tool
//
//  Created by Yuqing Jiang on 1/22/18.
//

#import <Cocoa/Cocoa.h>

@interface LuaScriptConsoleWindowController : NSWindowController

+(LuaScriptConsoleWindowController*)sharedWindowController;

-(void)appendMessage:(NSString*)message;
-(void)flushMessages:(id)sender;
@end

@interface LuaScriptConsoleViewController : NSViewController
-(void)appendMessage:(NSString*)message;
@end
