#import "LuaScript.h"



// work around the Nil defination conflict of ObjC and LuaBridge
#ifdef Nil
#undef Nil
#define Nil LuaNil
#include "LuaBind.h"
#undef Nil
#define Nil nullptr
#endif

#import "TypefaceManager.h"

namespace elua {
    class Font {
    public:
        void setOpenTypeFeatures(const std::set<std::string> & otFeatures) {
            openTypeFeatures_ = otFeatures;
        }
        
        std::set<std::string> openTypeFeatures() const {
            return openTypeFeatures_;
        }
        
        
        Font & addOpenTypeFeature(const std::string & feature) {
            openTypeFeatures_.insert(feature);
            return *this;
        }
        
        Font & addOpenTypeFeatures(const std::initializer_list<std::string> & features) {
            for (const auto & f : features)
                openTypeFeatures_.insert(f);
            return * this;
        }
        
        
    public:
        std::string postscriptName;
        int numGlyphs;
        int upem;
        std::string createDate;
        std::string modifiedDate;
        
        bool isOpenTypeVariation;
        bool isAdobeMultiMaster;
        
        std::string familyName;
        std::string styleName;
        std::string fullName;
        
        std::string format;
        bool isCID;
        std::string vender;
        std::string version;

       
    private:
        std::set<std::string>  openTypeFeatures_;
    };
    
    void printMessage(const std::string & message) {
        NSLog(@"<Lua> %@", [NSString stringWithUTF8String:message.c_str()]);
    }
    
    std::string toStdString(NSString * str) {
        if (!str) return std::string();
        return std::string([str UTF8String]);
    }
    
    Font toLuaFont(TMTypeface * face) {
        Font f;
        f.postscriptName = toStdString(face.attributes.postscriptName);
        f.numGlyphs = face.attributes.numGlyphs;
        f.upem = face.attributes.UPEM;
        f.createDate = toStdString(face.attributes.createdDate);
        f.modifiedDate = toStdString(face.attributes.modifiedDate);
        
        f.isOpenTypeVariation = face.attributes.isOpenTypeVariation;
        f.isAdobeMultiMaster = face.attributes.isAdobeMultiMaster;
        
        f.familyName = toStdString(face.familyName);
        f.styleName = toStdString(face.styleName);
        f.fullName = toStdString(face.attributes.fullName);
        
        f.format = toStdString(face.attributes.format);
        f.isCID = face.attributes.isCID;
        f.vender = toStdString(face.attributes.vender);
        f.version = toStdString(face.attributes.version);
        
        return f;
    }
    
    void registerClasses(lua_State * L) {
        luabridge::getGlobalNamespace(L).
        beginNamespace("el")
        .addFunction("print", printMessage)
        .beginClass<Font>("Font")
        .addConstructor<void(*)(void)>()
        .addData("postscriptName", &Font::postscriptName, false)
        .addData("numGlyphs", &Font::numGlyphs, false)
        .addData("UPEM", &Font::upem, false)
        .addData("createdDate", &Font::createDate)
        .addData("modifiedDate", &Font::modifiedDate)
        
        .addData("isOpenTypeVariation", &Font::isOpenTypeVariation, false)
        .addData("isAdobeMultiMaster", &Font::isAdobeMultiMaster, false)
        
        .addData("familyName", &Font::familyName, false)
        .addData("styleName", &Font::styleName, false)
        .addData("fullName", &Font::fullName, false)
        
        .addData("format", &Font::format, false)
        .addData("isCID", &Font::isCID, false)
        .addData("vender", &Font::vender, false)
        .addData("version", &Font::version, false)
        .addProperty("openTypeFeatures", &Font::openTypeFeatures)
        //.addProperty("name", &Font::familyName, &Font::setFamilyName)
        
        .endClass()
        .endNamespace();
    }
}

extern "C" {
    int luaScriptPrintMessage(lua_State *L) {
        const char * message = lua_tostring(L, -1);
        lua_getglobal(L, "__LuaScriptHost__");
        void * ptr  = lua_touserdata(L, -1);
        LuaScript * script = (__bridge LuaScript*)ptr;
        if (script.messageHandler) {
            script.messageHandler([NSString stringWithUTF8String:message]);
        }
        else {
            NSLog(@"<Lua> %@", [NSString stringWithUTF8String:message]);
        }
        return 0;
    }
}

@interface LuaScript() {
    lua_State *L;
}
-(BOOL)createState;
@end

@implementation LuaScript
-(instancetype)initWithFile:(NSString*)scriptFile messageHandler:(LuaScriptMessageHandler)messageHandler{
    if ((self = [super init]) && [self createState]) {
        self.messageHandler = messageHandler;
        
        const char* utf8 = [scriptFile UTF8String];
        
        if (luaL_loadfile(L, utf8) || lua_pcall (L, 0, LUA_MULTRET, 0)) {
            const char * message = lua_tostring(L, -1);
            [self logMessage:[NSString stringWithUTF8String:message]];
            lua_pop(L, 1); // failed to load script
            self = nil;
        }
        
        if (![self checkScript])
            self = nil;
    }
    return self;
}

-(instancetype)initWithBuffer:(NSString*)script  messageHandler:(LuaScriptMessageHandler)messageHandler {
    if ((self = [super init]) && [self createState]) {
        self.messageHandler = messageHandler;
        
        const char* utf8 = [script UTF8String];
        int lua_error = LUA_OK;
        if ((lua_error = luaL_loadbufferx(L, utf8, strlen(utf8), "BUFFER-SCRIPT.LUA", NULL))
            || (lua_error = lua_pcall (L, 0, LUA_MULTRET, 0))) {
            const char * message = lua_tostring(L, -1);
            [self logMessage:[NSString stringWithUTF8String:message]];
            lua_pop(L, 1); // failed to load script
            self = nil;
        }
        
        if (![self checkScript])
            self = nil;
    }
    return self;
}

-(BOOL)createState {
    L = luaL_newstate();
    luaL_openlibs(L); // load Lua standard libraries.
    elua::registerClasses(L);
    
    lua_pushlightuserdata(L, (void*)CFBridgingRetain(self));
    lua_setglobal(L, "__LuaScriptHost__");
    lua_pushcfunction(L, luaScriptPrintMessage);
    lua_setglobal(L, "print");
    
    return YES;
}

-(BOOL)checkScript {
    luabridge::LuaRef fFilterFont = luabridge::getGlobal(L, "filterFont");
    BOOL hasFunction = fFilterFont.isFunction();
    if (!hasFunction)
        [self logMessage:@"Failed to find function filterFont in script"];
    return hasFunction;
}

-(BOOL)runWithFont:(TMTypeface *)font {
    luabridge::LuaRef fFilterFont = luabridge::getGlobal(L, "filterFont");
    if (fFilterFont.isFunction()) {
        try {
            elua::Font f = elua::toLuaFont(font);
            luabridge::LuaRef ref = fFilterFont(&f);
            bool ret = ref;
            return ret;
        }
        catch(const std::exception & ex) {
            [self logMessage:@"%@ %@", @"Exception", [NSString stringWithUTF8String:ex.what()] ];
            return NO;
        }
    }
    else {
        [self logMessage:@"Failed to find function filterFont in script"];
        return NO;
    }
    return YES;
}

- (void)logMessage:(NSString *)format, ... {
    if (self.messageHandler) {
        va_list args;
        va_start(args, format);
        NSString * s = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        self.messageHandler(s);
    }
    else {
        va_list args;
        va_start(args, format);
        NSLogv(format, args);
        va_end(args);
    }
}
@end
