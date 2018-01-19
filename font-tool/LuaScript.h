#import <Cocoa/Cocoa.h>

@class TMTypeface;
@class LuaScript;

@interface LuaScript : NSObject
-(instancetype)initWithFile:(NSString*)scriptFile;
-(instancetype)initWithBuffer:(NSString*)script;

-(BOOL)runWithFont:(TMTypeface*)font;
@end
