#import <Cocoa/Cocoa.h>

@class TMTypeface;
@class LuaScript;

typedef void (^LuaScriptMessageHandler)(NSString * message);

@interface LuaScript : NSObject
@property (nonatomic) void (^messageHandler)(NSString * message);

-(instancetype)initWithFile:(NSString*)scriptFile messageHandler:(LuaScriptMessageHandler)messageHandler;
-(instancetype)initWithBuffer:(NSString*)script messageHandler:(LuaScriptMessageHandler)messageHandler;

-(BOOL)beginFilter;
-(BOOL)filterFont:(TMTypeface*)font;
-(BOOL)endFilter;
@end
