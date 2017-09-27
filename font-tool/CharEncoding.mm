//
//  CharEncoding.m
//  tx-research
//
//  Created by Yuqing Jiang on 6/9/17.
//
//


#import "CharEncoding.h"

NSString * UNI_CODEPOINT_REGEX = @"[0-9a-fA-F]{4,6}";

/**
 * U+BEEF, Uniocde flavor
 * uBEEF, AGL flavor
 * uniBEEF, AGL flavor
 * \uBEEF, Python flavor
 * 0xBEEF, Programmer flavor
 */
NSString * UNI_CODEPOINT_LOOKUP_REGEX = @"([uU]\\+?|uni|\\\\u|0[xX])[0-9a-fA-F]{4,6}";
NSString * GLYPH_INDEX_LOOKUP_REGEX = @"\\g[0-9]+";

NSString * UNDEFINED_UNICODE_CODEPOINT = @"<undefined>";

#define UNI_CODEPOINT_PREFIXES @[ @"U+", @"u", @"uni", @"\\u", @"0x"]

NSString * RegexReplace(NSString * string,
                        NSString * regexStr,
                        NSString * (^handler)(NSRange range, BOOL * stop)) {
    if (!string) return string;
    
    NSError * error = nil;
    
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:regexStr
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:&error];
    
    NSMutableArray<NSValue*> * matchRanges = [[NSMutableArray<NSValue*> alloc] init];
    [regex enumerateMatchesInString:string
                            options:0
                              range:NSMakeRange(0, string.length)
                         usingBlock:^(NSTextCheckingResult * result, NSMatchingFlags flags, BOOL * stop) {
        [matchRanges addObject:[NSValue valueWithRange:result.range]];
    }];
    
    if (!matchRanges.count)
        return string;
    
    NSMutableString * newString = [[NSMutableString alloc] init];
        
    NSUInteger start = 0;
    for (NSValue * r in matchRanges) {
        NSRange range = r.rangeValue;
        if (start < range.location) {
            // un-matched
            NSRange free = NSMakeRange(start, range.location - start);
            [newString appendString:[string substringWithRange:free]];
        }
        
        start = range.location + range.length;
        BOOL stop = NO;
        NSString * replace = handler(range, &stop);
        if (replace)
            [newString appendString:replace];
        
        if (stop)
            break;
    }
    
    if (start < string.length) {
        [newString appendString:[string substringWithRange:NSMakeRange(start, string.length - start)]];
    }
    
    return newString;
}



@implementation CharEncoding

+(NSString*)hexForCharcode:(codepoint_t)charcode unicodeFlavor:(BOOL)unicode {
    if (unicode) {
        if (charcode <= 0x10FFFF)
            return [NSString stringWithFormat:@"U+%04X", charcode];
        else
            return nil;
    }
    else
        return [NSString stringWithFormat:@"0x%04X", charcode];
}


+(NSUInteger)utf8ForUnicode:(codepoint_t)unicode outUTF8:(unsigned char*)utf8 {
    if (unicode <= 0x007F) {
        utf8[0] = unicode;
        return 1;
    }
    else if (unicode <= 0x07FF) {
        utf8[0] = ((unicode >> 6) & 0x1F) | 0xC0;
        utf8[1] = ((unicode >> 0) & 0x3F) | 0x80;
        return 2;
    }
    else if (unicode <= 0xFFFF) {
        utf8[0] = ((unicode >> 12) & 0x0F) | 0xE0;
        utf8[1] = ((unicode >> 6) & 0x3F) | 0x80;
        utf8[2] = ((unicode >> 0) & 0x3F) | 0x80;
        return 3;
        
    }
    else if (unicode <= 0x10FFFF) {
        utf8[0] = ((unicode >> 18) & 0x07) | 0xF0;
        utf8[1] = ((unicode >> 12) & 0x3F) | 0x80;
        utf8[2] = ((unicode >> 6)  & 0x3F) | 0x80;
        utf8[3] = ((unicode >> 0)  & 0x3F) | 0x80;
        return 4;
    }
    
    return 0;
}

+(NSUInteger)utf16ForUnicode:(codepoint_t)unicode outUTF16:(uint16_t*)utf16  {
    if (unicode < 0xFFFF) {
        utf16[0] = unicode;
        return 1;
    }
    else if ( unicode <= 0x10FFFF) {
        // souragate
        NSUInteger d = unicode - 0x010000;
        utf16[0] = ((d >> 10) & 0x03FF) + 0xD800; // top ten bits
        utf16[1] = (d & 0x03FF) + 0xDC00; // low ten bits
        return 2;
    }
    return 0;
}

+(NSString*)utf8HexStringForUnicode:(codepoint_t)unicode {
    NSMutableArray<NSString*>* all = [[NSMutableArray<NSString*> alloc] init];
    unsigned char utf8[4];
    NSUInteger c = [CharEncoding utf8ForUnicode:unicode outUTF8:utf8];
    for (NSUInteger i = 0; i < c; ++ i)
        [all addObject:[NSString stringWithFormat:@"%02X", utf8[i]]];
    
    if (all.count)
        return [NSString stringWithFormat:@"%@", [all componentsJoinedByString:@" "]];
    else
        return nil;
}

+(NSString*)utf16HexStringForUnicode:(codepoint_t)unicode{
    NSMutableArray<NSString*>* all = [[NSMutableArray<NSString*> alloc] init];
    uint16_t utf16[2];
    NSUInteger c = [CharEncoding utf16ForUnicode:unicode outUTF16:utf16];
    for (NSUInteger i = 0; i < c; ++ i)
        [all addObject:[NSString stringWithFormat:@"%04X", utf16[i]]];
    
    if (all.count)
        return [NSString stringWithFormat:@"U+%@", [all componentsJoinedByString:@","]];
    else
        return nil;
}

+(codepoint_t)codepointOfString:(NSString*)str {
    NSScanner * scanner = [NSScanner scannerWithString:str];
    NSUInteger code = INVALID_CODE_POINT;
    
    for (NSString * prefix in UNI_CODEPOINT_PREFIXES) {
        if ([str rangeOfString:prefix options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [scanner setScanLocation:prefix.length];
            if (scanner.atEnd)
                break;
            unsigned int hex = INVALID_CODE_POINT;
            if ([scanner scanHexInt:&hex]) {
                if (scanner.scanLocation != str.length)
                    hex = INVALID_CODE_POINT;
            }
            code = hex;
            if (code != INVALID_CODE_POINT)
                break;
        }
    }
    if (code == INVALID_CODE_POINT) {
        [scanner setScanLocation:0];
        unsigned long long ll = INVALID_CODE_POINT;
        if ([scanner scanUnsignedLongLong:&ll]) {
            if (scanner.scanLocation != str.length)
                ll = INVALID_CODE_POINT;
        }
        code = ll;
    }
    
    if (code == INVALID_CODE_POINT) {
        if (str.length == 1) {
            code = [str characterAtIndex:0]; // TODO: beyound BMP?
        }
    }
    return code;
}

+(codepoint_t)unicodeOfString:(NSString *)str {
    return [CharEncoding codepointOfString:str];
}

+(NSString*)NSStringFromUnicode:(codepoint_t)unicode {
    uint16_t utf16[2];
    NSUInteger c = [CharEncoding utf16ForUnicode:unicode outUTF16:utf16];
    return [[NSString alloc] initWithCharacters:utf16 length:c];
}

+(NSInteger)gidOfString:(NSString *)str {
    NSString * prefix = @"\\g";
    
    if ([str hasPrefix:prefix])
        return [CharEncoding integerOfString:[str substringFromIndex:prefix.length]];
    
    return [CharEncoding integerOfString:str];
}

+(NSInteger)integerOfString:(NSString*)str {
    NSScanner * scanner = [NSScanner scannerWithString:str];
    unsigned long long ll = INVALID_CODE_POINT;
    if ([scanner scanUnsignedLongLong:&ll]) {
        if (scanner.scanLocation != str.length)
            ll = INVALID_CODE_POINT;
    }
    return ll;
}

+(NSString*)infoLinkOfUnicode:(codepoint_t)unicode {
    return [NSString stringWithFormat:@"https://codepoints.net/U+%04X", unicode];
}

+(NSString*)infoLinkOfUnicodeHex:(NSString*)unicodeHex {
    return [NSString stringWithFormat:@"https://codepoints.net/U+%@", unicodeHex];
}

+(NSString*)gotoLinkOfUnicode:(codepoint_t)unicode {
    return [NSString stringWithFormat:@"lookup://U+%04X", unicode];
}

+(NSString*)gotoLinkOfUnicodeHex:(NSString*)unicodeHex {
    return [NSString stringWithFormat:@"lookup://U+%@", unicodeHex];
}

+ (NSString*)decodeUnicodeMixed:(NSString*)string {
    return RegexReplace(string, UNI_CODEPOINT_LOOKUP_REGEX, ^NSString *(NSRange range, BOOL *stop) {
        codepoint_t unichar = [CharEncoding unicodeOfString:[string substringWithRange:range]];
        return [CharEncoding NSStringFromUnicode:unichar];
    });
}

+(NSString*)bitsStringOfNumber:(NSUInteger)value count:(NSUInteger)count {
    char * buf = (char *)calloc(count+1, 1);
    for (NSUInteger i = 0; i < count; ++ i) {
        if ((1 << i) & value)
            buf[count - 1 - i] = '1';
        else
            buf[count - 1 - i] = '0';
    }
    NSString * str = [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
    free(buf);
    return str;
}


@end

static NSMutableArray<UnicodeBlock*> * blocks;

@implementation UnicodeBlock
-(id) initWithName:(NSString*)name from:(codepoint_t)from to:(codepoint_t)to {
    if (self = [super init]) {
        self.from = from;
        self.to = to;
        self.name = name;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (self == other)
        return YES;
    if (![other isKindOfClass:[UnicodeBlock class]])
        return NO;
    return self.from == ((UnicodeBlock*)other).from && self.to == ((UnicodeBlock*)other).to;
}

- (NSUInteger)hash {
    return [_name hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%04X-%04X)", self.name, self.from, self.to];
}

+(id)unicodeBlockWithName:(NSString*)name from:(codepoint_t)from to:(codepoint_t)to {
    return [[UnicodeBlock alloc] initWithName:name from:from to:to];
}

-(NSUInteger)codepointCount {
    return self.to - self.from + 1;
}

- (BOOL)isFullRange {
    return self.from == 0 && self.to == 0x10FFFF;
}

-(BOOL)containsUnicode:(codepoint_t)unicode {
    return unicode >= self.from && unicode <= self.to;
}
@end

static NSMutableDictionary<NSString*, UnicodeGeneralCategory *> * generalCategories;

@implementation UnicodeGeneralCategory

+(UnicodeGeneralCategory*)categoryByAbbreviation:(NSString *)abbr {
    if (!generalCategories) {
        NSDictionary<NSString*, NSString*> * dict = @{
                                                      @"Lu": @"Letter, Uppercase",
                                                      @"Ll": @"Letter, Lowercase",
                                                      @"Lt": @"Letter, Titlecase",
                                                      @"Lm": @"Letter, Modifier",
                                                      @"Lo": @"Letter, Other",
                                                      @"Mn": @"Mark, Nonspacing",
                                                      @"Mc": @"Mark, Spacing Combining",
                                                      @"Me": @"Mark, Enclosing",
                                                      @"Nd": @"Number, Decimal Digit",
                                                      @"Nl": @"Number, Letter",
                                                      @"No": @"Number, Other",
                                                      @"Pc": @"Punctuation, Connector",
                                                      @"Pd": @"Punctuation, Dash",
                                                      @"Ps": @"Punctuation, Open",
                                                      @"Pe": @"Punctuation, Close",
                                                      @"Pi": @"Punctuation, Initial quote",
                                                      @"Pf": @"Punctuation, Final quote",
                                                      @"Po": @"Punctuation, Other",
                                                      @"Sm": @"Symbol, Math",
                                                      @"Sc": @"Symbol, Currency",
                                                      @"Sk": @"Symbol, Modifier",
                                                      @"So": @"Symbol, Other",
                                                      @"Zs": @"Separator, Space",
                                                      @"Zl": @"Separator, Line",
                                                      @"Zp": @"Separator, Paragraph",
                                                      @"Cc": @"Other, Control",
                                                      @"Cf": @"Other, Format",
                                                      @"Cs": @"Other, Surrogate",
                                                      @"Co": @"Other, Private Use",
                                                      @"Cn": @"Other, Not Assigned",
                                                      };
        
        generalCategories = [[NSMutableDictionary<NSString*, UnicodeGeneralCategory *> alloc] init];
        for (NSString * key in dict) {
            UnicodeGeneralCategory * cat = [[UnicodeGeneralCategory alloc] init];
            cat.abbreviation = key;
            cat.fullDescription = [dict objectForKey:key];
            [generalCategories setObject:cat forKey:key];
        }
    }
    
    return [generalCategories objectForKey:abbr];
}

@end

@implementation UnicodeCharCoreAttributes

@end



static UnicodeDatabase *standardUnicodDatabase = nil;

@interface UnicodeDatabase ()
@property NSMutableDictionary<NSString*, NSNumber*> * nameCodeMapping;

@end

@implementation UnicodeDatabase
@synthesize unicodeBlocks = _unicodeBlocks;
@synthesize scriptBlocks = _scriptBlocks;
@synthesize derivedAgeBlocks = _derivedAgeBlocks;
@synthesize coreAttributesDictionary = _coreAttributesDictionary;
@synthesize propListBlocks = _propListBlocks;

- (instancetype)initWithRootDirectory:(NSString *)rootDirectory {
    if (self = [super init]) {
        _rootDirectory = rootDirectory;
    }
    return self;
}

+ (instancetype)standardDatabase {
    if (!standardUnicodDatabase) {
        standardUnicodDatabase = [[UnicodeDatabase alloc] initWithRootDirectory:[[NSBundle mainBundle] pathForResource:@"UNIDATA" ofType:nil]];
    }
    return standardUnicodDatabase;
}

- (NSArray<UnicodeBlock*>*)unicodeBlocks {
    if (!_unicodeBlocks) {
        NSMutableArray<UnicodeBlock*> * blocks = [[NSMutableArray<UnicodeBlock*> alloc] init];
        //[blocks addObject:[UnicodeBlock unicodeBlockWithName:@"Unicode Full Repertoire" from:0 to:0x10FFFF]];
        [blocks addObjectsFromArray:[self loadUnicodeBlocksFromFile:@"Blocks.txt"]];

        _unicodeBlocks = blocks;
    }
    return _unicodeBlocks;
}

- (NSArray<UnicodeScriptBlock*>*)scriptBlocks {
    if (!_scriptBlocks) {
        _scriptBlocks = [self loadUnicodeBlocksFromFile:@"Scripts.txt"];
    }
    return _scriptBlocks;
}

- (NSArray<UnicodeDerivedAgeBlock*>*)derivedAgeBlocks {
    if (!_derivedAgeBlocks) {
        _derivedAgeBlocks = [self loadUnicodeBlocksFromFile:@"DerivedAge.txt"];
    }
    return _derivedAgeBlocks;
}

- (NSArray<UnicodePropListBlock*>*)propListBlocks {
    if (!_propListBlocks) {
        _propListBlocks = [self loadUnicodeBlocksFromFile:@"PropList.txt"];
    }
    return _propListBlocks;
}

- (NSDictionary<NSNumber*, UnicodeCharCoreAttributes*>* ) coreAttributesDictionary {
    if (!_coreAttributesDictionary) {
        NSMutableDictionary<NSNumber*, UnicodeCharCoreAttributes*>* dict = [[NSMutableDictionary<NSNumber*, UnicodeCharCoreAttributes*> alloc] init];
        _nameCodeMapping = [[NSMutableDictionary<NSString*, NSNumber*> alloc] init];
        
        NSString * unicodeDataTxt = [NSString pathWithComponents:@[self.rootDirectory, @"UnicodeData.txt"]];
        
        [self enumrateCommaSeperatedFile:unicodeDataTxt trimSpaces:YES withHandler:^BOOL(NSArray<NSString *> *components) {
            if (components.count != 15)
                return YES;
            NSAssert(components.count == 15, @"");
            
            NSString * codeStr = [components objectAtIndex:0];
            NSString * nameStr = [components objectAtIndex:1];;
            NSString * categoryStr = [components objectAtIndex:2];
            NSString * combiningClassesStr = [components objectAtIndex:3];
            NSString * bidiCategoryStr = [components objectAtIndex:4];
            NSString * decompositionMappingStr = [components objectAtIndex:5];
            NSString * decimalDigitStr = [components objectAtIndex:6];
            NSString * digitStr = [components objectAtIndex:7];
            NSString * numericStr = [components objectAtIndex:8];
            NSString * mirroredStr = [components objectAtIndex:9];
            NSString * unicode1_0Name = [components objectAtIndex:10];
            NSString * comment10646 = [components objectAtIndex:11];
            NSString * upperCaseMappingStr = [components objectAtIndex:12];
            NSString * lowercaseMappingStr = [components objectAtIndex:13];
            NSString * titleCaseMappingStr = [components objectAtIndex:14];
            
            UnicodeCharCoreAttributes * charAttrs = [[UnicodeCharCoreAttributes alloc] init];
            charAttrs.codepoint = [self scanUnicodeStr:codeStr];
            charAttrs.name = nameStr;
            charAttrs.generalCategory = [UnicodeGeneralCategory categoryByAbbreviation:categoryStr];
            charAttrs.decomposition = decompositionMappingStr;
            charAttrs.simpleUppercase = [self scanUnicodeStr:upperCaseMappingStr];
            charAttrs.simpleLowercase = [self scanUnicodeStr:lowercaseMappingStr];
            charAttrs.simpleTitlecase = [self scanUnicodeStr:titleCaseMappingStr];
            
            
            [dict setObject:charAttrs forKey:[NSNumber numberWithInteger:charAttrs.codepoint]];
            [_nameCodeMapping setObject:[NSNumber numberWithInteger:charAttrs.codepoint] forKey:charAttrs.name];
            
            return YES;
        }];
        

        _coreAttributesDictionary = dict;
    }
    return _coreAttributesDictionary;
}

-(UnicodeBlock*)unicodeBlockWithName:(NSString*)blockName {
    for (UnicodeBlock * block in self.unicodeBlocks) {
        if ([block.name caseInsensitiveCompare:blockName] == NSOrderedSame)
            return block;
    }
    NSAssert(NO, @"Unicode block %@ not found!", blockName);
    return nil;
}

- (UnicodeCharCoreAttributes*)coreAttributesOfChar:(codepoint_t)unicode {
    return [self.coreAttributesDictionary objectForKey:[NSNumber numberWithInteger:unicode]];
}

- (UnicodeBlock*)blockOfChar:(codepoint_t)unicode {
    return [self binarySearchUnicode:unicode inBlocks:self.unicodeBlocks];
}

- (NSString*)scriptOfChar:(codepoint_t)unicode {
    return [self linearSearchUnicode:unicode inBlocks:self.scriptBlocks].name;
}

- (NSString*)derivedAgeOfChar:(codepoint_t)unicode {
    return [self linearSearchUnicode:unicode inBlocks:self.derivedAgeBlocks].name;
}

- (BOOL)isPUA:(codepoint_t)unicode {
    if (unicode >= 0xE000 && unicode <= 0xF8FF)
        return YES;
    if (unicode >= 0xF0000 && unicode <= 0xFFFFD)
        return YES;
    if (unicode >= 0x100000 && unicode <= 0x10FFFD)
        return YES;
    return NO;
}

- (NSString*)propListOfChar:(codepoint_t)unicode {
    return [self linearSearchUnicode:unicode inBlocks:self.propListBlocks].name;
}

- (uint32_t)codepointFromName:(NSString*)charName {
    return [self.nameCodeMapping objectForKey:charName].integerValue;
}


- (UnicodeBlock*)linearSearchUnicode:(codepoint_t)unicode inBlocks:(NSArray<UnicodeBlock*>*)blocks {
    for (UnicodeBlock * block in blocks) {
        if ([block containsUnicode:unicode])
            return block;
    }
    return nil;
}

- (UnicodeBlock*)binarySearchUnicode:(codepoint_t)unicode inBlocks:(NSArray<UnicodeBlock*>*)blocks {
    NSUInteger from = 0, to = blocks.count;

    while (from < to) {
        NSUInteger mid = (from + to)/2;
        UnicodeBlock * block = [blocks objectAtIndex:mid];
        if ([block containsUnicode:unicode])
            return block;
        if (block.from > unicode)
            to = mid;
        else
            from = mid + 1;
    }
    return nil;
}

- (NSString*)getPathOfUnidataFile:(NSString*)fileName {
    return [NSString pathWithComponents:@[self.rootDirectory, fileName]];
}

- (NSArray<UnicodeBlock*>*)loadUnicodeBlocksFromFile:(NSString*)fileName {
    NSMutableArray<UnicodeBlock*> * blocks = [[NSMutableArray<UnicodeBlock*> alloc] init];
    
    NSString * filePath = [self getPathOfUnidataFile:fileName];
    
    [self enumrateCommaSeperatedFile:filePath trimSpaces:YES withHandler:^BOOL(NSArray<NSString *> * components) {
        if (components.count != 2)
            return YES; // invalid line, but continue
        
        NSString * range = [components objectAtIndex:0];
        NSString * name = [components objectAtIndex:1];
        
        uint32_t from, to;
        if (![self scanUnicodeRangeStr:range from:&from to:&to])
            return YES; // invalid hex, but continue
        
        UnicodeBlock * block = [[UnicodeBlock alloc] initWithName:name from:from to:to];
        [blocks addObject:block];
        return YES;
    }];
    
    return blocks;
}


- (void) enumrateCommaSeperatedFile:(NSString*)filePath trimSpaces:(BOOL)trimSpaces withHandler:(BOOL(^)(NSArray<NSString*> * components)) handler {
    NSString * fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray<NSString*> * allLines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString * line in allLines) {
        
        
        BOOL continueLoop = [self enumrateCommaSeperatedLine:line trimSpaces:YES withHandler:^BOOL(NSArray<NSString *> *components) {
            return handler(components);
        }];
        
        if (!continueLoop)
            break;
    }
}

- (BOOL) enumrateCommaSeperatedLine:(NSString*)line trimSpaces:(BOOL)trimSpaces withHandler:(BOOL(^)(NSArray<NSString*> * components)) handler {
    NSString * trimedLine = line;
    if (trimSpaces)
        trimedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([trimedLine hasPrefix:@"#"]) // comment
        return YES;
    
    if (trimedLine.length == 0)
        return YES; // empty line
    
    NSArray<NSString*> * components = [line componentsSeparatedByString:@"#"];
    
    if (components.count == 1)
        components = [line componentsSeparatedByString:@";"];
    else
        components = [[components objectAtIndex:0] componentsSeparatedByString:@";"]; // has # trailing comments
    
    if (trimSpaces) {
        NSMutableArray<NSString*> * trimed = [[NSMutableArray<NSString*> alloc] init];
        for (NSString * c in components)
            [trimed addObject:[c stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        components = trimed;
    }
    return handler(components);
}

- (uint32_t)scanUnicodeStr:(NSString *)str{
    NSScanner * scanner = [NSScanner scannerWithString:str];
    unsigned long long value = -1;
    if (![scanner scanHexLongLong:&value])
        return INVALID_CODE_POINT;
    return value;
}


- (BOOL)scanUnicodeStr:(NSString *)str code:(uint32_t*)code{
    NSScanner * scanner = [NSScanner scannerWithString:str];
    unsigned long long value = INVALID_CODE_POINT;
    if (![scanner scanHexLongLong:&value])
        return NO;
    *code = value;
    return YES;
}

- (BOOL)scanUnicodeRangeStr:(NSString *)str from:(uint32_t *) from to:(uint32_t *)to {
    NSArray<NSString*> * components = [str componentsSeparatedByString:@".."];
    if (components.count > 2)
        return NO;
    
    if (components.count == 1) {
        return [self scanUnicodeStr:[components objectAtIndex:0] code:from] && [self scanUnicodeStr:[components objectAtIndex:0] code:to];
    }
    else {
        NSString * fromStr = [components objectAtIndex:0];
        NSString * toStr = [components objectAtIndex:1];
        return [self scanUnicodeStr:fromStr code:from] && [self scanUnicodeStr:toStr code:to];
    }
}

@end

