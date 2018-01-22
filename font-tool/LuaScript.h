#import <Cocoa/Cocoa.h>

@class TMTypeface;
@class LuaScript;

@interface LuaScript : NSObject
@property (nonatomic) void (^messageHandler)(NSString * message);

-(instancetype)initWithFile:(NSString*)scriptFile;
-(instancetype)initWithBuffer:(NSString*)script;
-(BOOL)runWithFont:(TMTypeface*)font;
@end
