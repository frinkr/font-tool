//
//  HtmlTableView.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/19/17.
//
//

#import "HtmlTableView.h"
#import "AppDelegate.h"

@implementation HtmlTableRow
- (id _Nonnull )initWithKey:(NSString*_Nonnull)key value:(NSString*_Nonnull)value {
    if (self = [super init]) {
        self.key = key;
        self.value = value;
    }
    return self;
}
@end

HtmlTableRow * MakeHtmlTableRow(NSString *key, NSString * value) {
    return [[HtmlTableRow alloc] initWithKey:key value:value];
}


@implementation NSMutableArray  (HtmlTableRow)

- (void)addRowWithKey:(NSString*_Nonnull)key stringValue:(NSString*_Nonnull)value {
    if (!value)
        value = @"<i>nil</i>";
    [self addObject:MakeHtmlTableRow(key, value)];
}

- (void)addRowWithKey:(NSString*_Nonnull)key boolValue:(BOOL)value {
    return [self addRowWithKey:key stringValue:value?@"YES":@"NO"];
}

- (void)addRowWithKey:(NSString*_Nonnull)key integerValue:(NSInteger)value {
    return [self addRowWithKey:key stringValue:[NSString stringWithFormat:@"%ld", value]];
}

- (void)addRowWithKey:(NSString*_Nonnull)key unsignedIntegerValue:(NSUInteger)value {
    return [self addRowWithKey:key stringValue:[NSString stringWithFormat:@"%lu", value]];
}

- (void)addRowWithKey:(NSString*_Nonnull)key doubleValue:(double)value{
    return [self addRowWithKey:key stringValue:[NSString stringWithFormat:@"%f", value]];
}

- (void)addRowWithKey:(NSString*_Nonnull)key uint32HexValue:(NSUInteger)value withPrefix:(NSString*)prefix{
    return [self addRowWithKey:key stringValue:[NSString stringWithFormat:@"%@%08lX", prefix, value]];
}

- (void)addRowWithKey:(NSString*_Nonnull)key uint16HexValue:(NSUInteger)value  withPrefix:(NSString*)prefix{
    return [self addRowWithKey:key stringValue:[NSString stringWithFormat:@"%@%04lX", prefix, value]];
}

- (void)addRowWithKey:(NSString*_Nonnull)key bitsValue:(NSUInteger)value count:(NSUInteger)count {
    char * buf = (char *)calloc(count+1, 1);
    for (NSUInteger i = 0; i < count; ++ i) {
        if ((1 << i) & value)
            buf[count - 1 - i] = '1';
        else
            buf[count - 1 - i] = '0';
    }
    NSString * str = [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
    free(buf);
    
    return [self addRowWithKey:key stringValue:str];
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

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"drawsTransparentBackground"];
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
    }
    decisionHandler(WKNavigationActionPolicyAllow);

}

+ (NSString*)htmlTableRowWithKey:(NSString*)key keyStyle:(NSString*)keyStyle value:(NSString*)value valueStyle:(NSString*)valueStyle {
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
            [htmlText appendFormat:@"<col style='width: %ld%%'/>", appearance.keyColumnSize];
            [htmlText appendFormat:@"<col style='width: %ld%%'/>", (100 - appearance.keyColumnSize)];
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
