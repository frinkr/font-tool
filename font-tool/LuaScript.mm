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

@interface LuaScript() {
    lua_State *L;
}
-(BOOL)createState;
-(void)logMessage:(NSString *)format, ...;
@end

namespace elua {
    
    std::string toStdString(NSString * str) {
        if (!str) return std::string();
        return std::string([str UTF8String]);
    }
    
    std::vector<std::string> toStdVector(NSArray<NSString*> * names) {
        std::vector<std::string> ret;
        for (NSString * str in names) {
            ret.push_back(toStdString(str));
        }
        return ret;
    }
    
    std::set<std::string> toStdSet(NSSet<TypefaceTag*> * tags) {
        std::set<std::string> ret;
        for (TypefaceTag * t in tags) {
            ret.insert(toStdString(t.text));
        }
        return ret;
    }
    
    std::map<std::string, std::string> toStdMap(NSDictionary<NSString*, NSString*> * names) {
        std::map<std::string, std::string> ret;
        for (NSString * lang in names) {
            NSString * name = [names objectForKey:lang];
            ret[toStdString(lang)] = toStdString(name);
        }
        return ret;
    }
    
    std::map<std::string, bool> toStdMap(NSSet<OpenTypeFeatureTag*> * features) {
        std::map<std::string, bool> ret;
        for (OpenTypeFeatureTag * tag in features) {
            ret[toStdString(tag.text)] = tag.isRequired;
        }
        return ret;
    }
    
    NSString * toNSString(const std::string & str) {
        return [NSString stringWithUTF8String:str.c_str()];
    }
    
    NSString * toNSString(bool b) {
        return b? @"true": @"false";
    }
    
    template < template <typename K, typename Alloc> class C, typename K, typename Alloc>
    NSString * toNSString(const C<K, Alloc> & c) {
        NSMutableString * ret = [[NSMutableString alloc] init];
        for (const K & v : c) {
            if (ret.length != 0)
                [ret appendString:@", "];
            [ret appendString:toNSString(v)];
        }
        return [NSString stringWithFormat:@"{%@}", ret];
    }
    
    template < template <typename K, typename Compare, typename Alloc> class C, typename K, typename Compare, typename Alloc>
    NSString * toNSString(const C<K, Compare, Alloc> & c) {
        NSMutableString * ret = [[NSMutableString alloc] init];
        for (const K & v : c) {
            if (ret.length != 0)
                [ret appendString:@", "];
            [ret appendString:toNSString(v)];
        }
        return [NSString stringWithFormat:@"{%@}", ret];
    }
    
    NSString * toNSString(const std::map<std::string, bool> & features) {
        NSMutableString * ret = [[NSMutableString alloc] init];
        for (const auto  & key : features) {
            if (ret.length != 0)
                [ret appendString:@", "];
            if (key.second)
                [ret appendFormat:@"%@*", toNSString(key.first)];
            else
                [ret appendFormat:@"%@", toNSString(key.first)];
        }
        return [NSString stringWithFormat:@"{%@}", ret];
    }
    
    NSString * toNSString(const std::map<std::string, std::string> & map) {
        NSMutableString * ret = [[NSMutableString alloc] init];
        for (const auto  & key : map) {
            if (ret.length != 0)
                [ret appendString:@", "];
            [ret appendFormat:@"%@=%@", toNSString(key.first), toNSString(key.second)];
        }
        return [NSString stringWithFormat:@"{%@}", ret];
    }
    
    struct Font {
        ~Font() {
            if (userData)
                CFBridgingRelease(userData);
            if (tmFace)
                CFBridgingRelease(tmFace);
        }
        void Dump() {
            LuaScript * script = (__bridge LuaScript*)userData;
            [script logMessage:toNSString(postscriptName)];
            [script logMessage:@"   Num Glyphs = %d", numGlyphs];
            [script logMessage:@"   UPEM = %d", upem];
            [script logMessage:@"   CreatedDate = %@", toNSString(createDate)];
            [script logMessage:@"   ModifiedDate = %@", toNSString(modifiedDate)];
            [script logMessage:@"   IsOpenTypeVariation = %@", toNSString(isOpenTypeVariation)];
            [script logMessage:@"   IsAdobeMultiMaster = %@", toNSString(isAdobeMultiMaster)];
            [script logMessage:@"   OpenType Scripts = %@", toNSString(openTypeScripts)];
            [script logMessage:@"   OpenType Languages = %@", toNSString(openTypeLanguages)];
            [script logMessage:@"   OpenType Features = %@", toNSString(openTypeFeatures)];
            [script logMessage:@"   Family Name = %@", toNSString(familyName)];
            [script logMessage:@"   Style Name = %@", toNSString(styleName)];
            [script logMessage:@"   Full Name = %@", toNSString(fullName)];
            [script logMessage:@"   Localized Family Names = %@", toNSString(localizedFamilyNames)];
            [script logMessage:@"   Localized Style Names = %@", toNSString(localizedStyleNames)];
            [script logMessage:@"   Localized Full Names = %@", toNSString(localizedFullNames)];
            [script logMessage:@"   Design Languages = %@", toNSString(designLanguages)];
            [script logMessage:@"   Format = %@", toNSString(format)];
            [script logMessage:@"   IsCID = %@", toNSString(isCID)];
            [script logMessage:@"   Vender = %@", toNSString(vender)];
            [script logMessage:@"   Version = %@", toNSString(version)];
        }
        
        bool containsChar(uint32_t unicodeChar) {
            TMTypeface * face = (__bridge TMTypeface*)tmFace;
            return [face containsChar:unicodeChar];
        }
        
        bool containsTable(const std::string & table) {
            TMTypeface * face = (__bridge TMTypeface*)tmFace;
            return [face containsTable:toNSString(table)];
        }
        
    public:
        std::string postscriptName;
        int numGlyphs;
        int upem;
        std::string createDate;
        std::string modifiedDate;
        
        bool isOpenTypeVariation;
        bool isAdobeMultiMaster;
        std::set<std::string> openTypeScripts;
        std::set<std::string> openTypeLanguages;
        std::map<std::string, bool> openTypeFeatures;
        
        std::string familyName;
        std::string styleName;
        std::string fullName;
        std::map<std::string, std::string> localizedFamilyNames;
        std::map<std::string, std::string> localizedStyleNames;
        std::map<std::string, std::string> localizedFullNames;
        std::vector<std::string> designLanguages;
        
        std::string format;
        bool isCID;
        std::string vender;
        std::string version;
        
        void * tmFace;
        void * userData;
    };
    
    void printMessage(const std::string & message) {
        NSLog(@"<Lua> %@", [NSString stringWithUTF8String:message.c_str()]);
    }
    
    Font toLuaFont(TMTypeface * face, LuaScript * script) {
        Font f;
        f.postscriptName = toStdString(face.attributes.postscriptName);
        f.numGlyphs = face.attributes.numGlyphs;
        f.upem = face.attributes.UPEM;
        f.createDate = toStdString(face.attributes.createdDate);
        f.modifiedDate = toStdString(face.attributes.modifiedDate);
        
        f.isOpenTypeVariation = face.attributes.isOpenTypeVariation;
        f.isAdobeMultiMaster = face.attributes.isAdobeMultiMaster;
        f.openTypeScripts = toStdSet(face.attributes.openTypeScripts);
        f.openTypeLanguages = toStdSet(face.attributes.openTypeLanguages);
        f.openTypeFeatures = toStdMap(face.attributes.openTypeFeatures);
        
        f.familyName = toStdString(face.familyName);
        f.styleName = toStdString(face.styleName);
        f.fullName = toStdString(face.attributes.fullName);
        f.localizedFamilyNames = toStdMap(face.attributes.localizedFamilyNames);
        f.localizedStyleNames = toStdMap(face.attributes.localizedStyleNames);
        f.localizedFullNames = toStdMap(face.attributes.localizedFullNames);
        f.designLanguages = toStdVector(face.attributes.designLanguages);
        
        f.format = toStdString(face.attributes.format);
        f.isCID = face.attributes.isCID;
        f.vender = toStdString(face.attributes.vender);
        f.version = toStdString(face.attributes.version);
        
        f.userData = (void*)CFBridgingRetain(script);
        f.tmFace = (void*)CFBridgingRetain(face);
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
        .addData("otScripts", &Font::openTypeScripts, false)
        .addData("otLanguages", &Font::openTypeLanguages, false)
        .addData("otFeatures", &Font::openTypeFeatures, false)
        
        .addData("familyName", &Font::familyName, false)
        .addData("styleName", &Font::styleName, false)
        .addData("fullName", &Font::fullName, false)
        .addData("localizedFamilyNames", &Font::localizedFamilyNames, false)
        .addData("localizedStyleNames", &Font::localizedStyleNames, false)
        .addData("localizedFullNames", &Font::localizedFullNames, false)
        .addData("designLanguages", &Font::designLanguages, false)
        
        .addData("format", &Font::format, false)
        .addData("isCID", &Font::isCID, false)
        .addData("vender", &Font::vender, false)
        .addData("version", &Font::version, false)
        
        .addFunction("dump", &Font::Dump)
        .addFunction("containsChar", &Font::containsChar)
        .addFunction("containsTable", &Font::containsTable)
        
        .endClass()
        .endNamespace();
    }
}

extern "C" {
    int luaScriptPrintMessage(lua_State *L) {
        const char * message = lua_tostring(L, -1);
        if (message) {
            lua_getglobal(L, "__LuaScriptHost__");
            void * ptr  = lua_touserdata(L, -1);
            LuaScript * script = (__bridge LuaScript*)ptr;
            if (script.messageHandler) {
                script.messageHandler([NSString stringWithUTF8String:message]);
            }
            else {
                NSLog(@"<Lua> %@", [NSString stringWithUTF8String:message]);
            }
        }
        return 0;
    }
}


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

-(BOOL)beginFilter {
    luabridge::LuaRef fInit = luabridge::getGlobal(L, "init");
    if (fInit.isFunction()) {
        try {
            fInit();
        }
        catch(const std::exception & ex) {
            [self logMessage:@"%@ %@", @"Exception", [NSString stringWithUTF8String:ex.what()] ];
            return NO;
        }
    }
    return YES;
}

-(BOOL)endFilter {
    luabridge::LuaRef fFinalize = luabridge::getGlobal(L, "finalize");
    if (fFinalize.isFunction()) {
        try {
            fFinalize();
        }
        catch(const std::exception & ex) {
            [self logMessage:@"%@ %@", @"Exception", [NSString stringWithUTF8String:ex.what()] ];
            return NO;
        }
    }
    return YES;
}

-(BOOL)filterFont:(TMTypeface *)font {
    luabridge::LuaRef fFilterFont = luabridge::getGlobal(L, "filterFont");
    if (fFilterFont.isFunction()) {
        try {
            elua::Font f = elua::toLuaFont(font, self);
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
