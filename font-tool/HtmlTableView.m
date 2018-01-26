//
//  HtmlTableView.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/19/17.
//
//

#import "HtmlTableView.h"
#import "AppDelegate.h"
#import "CharEncoding.h"
#import "Common.h"

@implementation HtmlTableRow
- (id  )initWithKey:(NSString*)key value:(NSString*)value {
    if (self = [super init]) {
        self.key = key;
        self.value = value;
    }
    return self;
}
@end

HtmlTableRow * MakeHtmlTableSection(NSString *section) {
    return [[HtmlTableRow alloc] initWithKey:section value:nil];
}


HtmlTableRow * MakeHtmlTableRow(NSString *key, NSString * value) {
    return [[HtmlTableRow alloc] initWithKey:key value:value];
}

BOOL IsHtmlTableSection(NSString * key, NSString * value) {
    return !value;
}

@implementation NSMutableArray  (HtmlTableRow)

- (void)addSection:(NSString *)sectionName {
    [self addObject:MakeHtmlTableSection(sectionName)];
}

- (void)addRowWithKey:(NSString*)key stringValue:(NSString*)value {
    if (!value)
        value = @"<i>nil</i>";
    [self addObject:MakeHtmlTableRow(key, value)];
}

- (void)addRowWithKey:(NSString*)key boolValue:(BOOL)value {
    return [self addRowWithKey:key stringValue:value?@"YES":@"NO"];
}

- (void)addRowWithKey:(NSString*)key integerValue:(NSInteger)value {
    return [self addRowWithKey:key stringValue:[NSString stringWithFormat:@"%ld", value]];
}

- (void)addRowWithKey:(NSString*)key unsignedIntegerValue:(NSUInteger)value {
    return [self addRowWithKey:key stringValue:[NSString stringWithFormat:@"%lu", value]];
}

- (void)addRowWithKey:(NSString*)key doubleValue:(double)value{
    return [self addRowWithKey:key stringValue:[NSString stringWithFormat:@"%f", value]];
}

- (void)addRowWithKey:(NSString*)key uint32HexValue:(NSUInteger)value withPrefix:(NSString*)prefix{
    return [self addRowWithKey:key stringValue:[NSString stringWithFormat:@"%@%08lX", prefix, value]];
}

- (void)addRowWithKey:(NSString*)key uint16HexValue:(NSUInteger)value  withPrefix:(NSString*)prefix{
    return [self addRowWithKey:key stringValue:[NSString stringWithFormat:@"%@%04lX", prefix, value]];
}

- (void)addRowWithKey:(NSString*)key bitsValue:(NSUInteger)value count:(NSUInteger)count {
    return [self addRowWithKey:key stringValue:[CharEncoding bitsStringOfNumber:value count:count]];
}

- (void)addRowWithKey:(NSString*)key arrayValue:(NSArray*) objects  delemiter:(NSString*)delemiter{
    return [self addRowWithKey:key stringValue:[objects componentsJoinedByString:delemiter]];
}

- (void)addRowWithKey:(NSString*)key setValue:(NSSet*) objects  delemiter:(NSString*)delemiter{
    return [self addRowWithKey:key arrayValue:objects.allObjects delemiter:delemiter];
}

- (void)addRowWithKey:(NSString *)key dictionaryValue:(NSDictionary *)objects  delemiter:(NSString*)delemiter{
    NSMutableArray<NSString*> * array = [[NSMutableArray alloc] init];
    for (id k in objects)
        [array addObject:[NSString stringWithFormat:@"%@ = %@", k, [objects objectForKey:k]]];
    return [self addRowWithKey:key arrayValue:array delemiter:delemiter];
}

@end

static HtmlTableViewAppearance * defaultHtmlTableViewApperance;

@implementation HtmlTableViewAppearance
-(instancetype)init {
    if (self = [super init]) {
        self.fontSize = 11;
    }
    return self;
}

+ (instancetype)defaultAppearance {
    if (!defaultHtmlTableViewApperance) {
        defaultHtmlTableViewApperance = [[HtmlTableViewAppearance alloc] init];
        defaultHtmlTableViewApperance.fontSize = 11;
        defaultHtmlTableViewApperance.keyColumnSize = 0;
        defaultHtmlTableViewApperance.dark = NO;
    }
    return defaultHtmlTableViewApperance;
}

@end

@implementation HtmlTableView


- (instancetype)initWithFrame:(NSRect)frameRect {
    WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
    config.suppressesIncrementalRendering = YES;
    config.allowsAirPlayForMediaPlayback = NO;

    if (self = [super initWithFrame:frameRect configuration:config]) {
        if (!OS_IS_BELOW_SIERRA)
            [self setValue:@(NO) forKey:@"drawsBackground"];
        self.navigationDelegate = self;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSAssert(!OS_IS_BELOW_SIERRA, @"WKWebview can't live in Nib in OS older than Sierra");
        
    [self setValue:@(NO) forKey:@"drawsBackground"];
    self.navigationDelegate = self;
}


- (void)reloadData {
    NSMutableArray<HtmlTableRow*> * rows = [[NSMutableArray<HtmlTableRow*> alloc] init];
    for (NSUInteger index = 0; index < [self.dataSource numberOfRowsInHtmlTableView:self]; ++ index) {
        if ([self.dataSource respondsToSelector:@selector(htmlTableView:rowAtIndex:)]) {
            HtmlTableRow * row = [self.dataSource htmlTableView:self rowAtIndex:index];
            [rows addObject:row];
        }
    }
    
    [self loadHTMLString:[self htmlTable:rows] baseURL:nil];
}

- (NSString*)htmlTable:(NSArray<HtmlTableRow*> *) rows {
    HtmlTableViewAppearance * appearance = nil;
    if ([self.delegate respondsToSelector:@selector(appearanceOfHtmlTableView:)])
        appearance = [self.delegate appearanceOfHtmlTableView:self];
    if (!appearance)
        appearance = [HtmlTableViewAppearance defaultAppearance];
    
    return [[self class] htmlTableWithRows:rows appearance:appearance];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    // always open in external browser
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        NSURL * url = navigationAction.request.URL;
        [(AppDelegate*)NSApp.delegate openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        
        if ([self.delegate respondsToSelector:@selector(htmlTableView:didOpenURL:)])
            [self.delegate htmlTableView:self didOpenURL:url];
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);

}

+ (NSString*)htmlTableRowWithKey:(NSString*)key keyStyle:(NSString*)keyStyle value:(NSString*)value valueStyle:(NSString*)valueStyle {
    if (IsHtmlTableSection(key, value)) {
        NSString * padding = [@"" stringByPaddingToLength:15 withString:@"\u2592" startingAtIndex:0];
        
        return [NSString stringWithFormat:@"<tr><td colspan=2 align='center' valign='bottom' >%@ %@ %@</td></tr>", padding, [key uppercaseString], padding];
    }
    
    return [NSString stringWithFormat:@"<tr><td %@>%@:</td> <td %@>%@</td></tr>", keyStyle, key, valueStyle, value];
}

+ (NSString*)htmlTableWithRows:(NSArray<HtmlTableRow*> *) rows appearance:(HtmlTableViewAppearance*)appearance {
    NSString * keyStyle = @"align='right' valign='top'";
    NSString * valueStyle = @"";
    
    NSMutableArray<NSString*> * rowsText = [[NSMutableArray<NSString*> alloc] init];
    for (HtmlTableRow * row in rows)
        [rowsText addObject:[self htmlTableRowWithKey:row.key
                                             keyStyle:keyStyle
                                                value:row.value
                                           valueStyle:valueStyle]];
    
    NSMutableString * htmlText = [[NSMutableString alloc] init];
    
    [htmlText appendFormat:@"<table "]; {
        [htmlText appendFormat:@"style='font-family:-apple-system; font-size:%f; margin:0px 0px;", appearance.fontSize];
        if (appearance.keyColumnSize)
            [htmlText appendFormat:@"table-layout:fixed; width:100%%;"];
        [htmlText appendFormat:@"color:%@;'>\n", (appearance.dark? @"white" : @"black")];
    }
    
    [htmlText appendFormat:@"<colgroup>"]; {
        if (appearance.keyColumnSize) {
            if (appearance.absoluteKeyColumnSize) {
                [htmlText appendFormat:@"<col style='width: %ld'/>", appearance.keyColumnSize];
                [htmlText appendFormat:@"<col/>"];
            }
            else {
                [htmlText appendFormat:@"<col style='width: %ld%%'/>", appearance.keyColumnSize];
                [htmlText appendFormat:@"<col style='width: %ld%%'/>", (100 - appearance.keyColumnSize)];
            }
        }
        else {
            [htmlText appendFormat:@"<col/>"];
            [htmlText appendFormat:@"<col/>"];
        }
        [htmlText appendFormat:@"</colgroup>\n"];
    }
    
    [htmlText appendFormat:@"%@\n", [rowsText componentsJoinedByString:@"\n"]];
    [htmlText appendFormat:@"</table>"];
    
    return htmlText;
}

@end
