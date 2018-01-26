//
//  HtmlTableView.h
//  tx-research
//
//  Created by Yuqing Jiang on 5/19/17.
//
//

#import <WebKit/WebKit.h>

@interface HtmlTableRow : NSObject
@property (strong) NSString *  key;
@property (strong) NSString *  value;
- (id  )initWithKey:(NSString*)key value:(NSString*)value;
@end

extern HtmlTableRow * MakeHtmlTableRow(NSString *key, NSString * value);

@interface NSMutableArray  (HtmlTableRow)
- (void)addRowWithKey:(NSString*)key stringValue:(NSString*)value;
- (void)addRowWithKey:(NSString*)key boolValue:(BOOL)value;
- (void)addRowWithKey:(NSString*)key integerValue:(NSInteger)value;
- (void)addRowWithKey:(NSString*)key unsignedIntegerValue:(NSUInteger)value;
- (void)addRowWithKey:(NSString*)key doubleValue:(double)value;
- (void)addRowWithKey:(NSString*)key uint32HexValue:(NSUInteger)value withPrefix:(NSString*)prefix;
- (void)addRowWithKey:(NSString*)key uint16HexValue:(NSUInteger)value withPrefix:(NSString*)prefix;
- (void)addRowWithKey:(NSString*)key bitsValue:(NSUInteger)value count:(NSUInteger)count;

@end

typedef NSMutableArray<HtmlTableRow*> HtmlTableRows;

@class HtmlTableView;

@protocol HtmlTableViewDataSource <NSObject>
@required
-(NSUInteger)numberOfRowsInHtmlTableView:(HtmlTableView*)view;
-(HtmlTableRow*)htmlTableView:(HtmlTableView*)view rowAtIndex:(NSUInteger)index;
@end


@interface HtmlTableViewAppearance : NSObject
@property CGFloat fontSize;
@property NSUInteger keyColumnSize; // 0-100, zero means free size
@property BOOL absoluteKeyColumnSize; // keyColumnSize in pt when YES
@property BOOL dark;

-(instancetype)init;

+(instancetype)defaultAppearance;

@end

@protocol HtmlTableViewDelegate <NSObject>
- (HtmlTableViewAppearance*) appearanceOfHtmlTableView:(HtmlTableView*)view;
@optional
- (void)htmlTableView:(HtmlTableView*)view didOpenURL:(NSURL*)url;
@end


@interface HtmlTableView : WKWebView<WKNavigationDelegate>

@property (nullable, weak) id<HtmlTableViewDataSource> dataSource;
@property (nullable, weak) id<HtmlTableViewDelegate> delegate;

- (instancetype)initWithFrame:(NSRect)frameRect;

- (void)reloadData;

+ (NSString*)htmlTableRowWithKey:(NSString*)key keyStyle:(NSString*)keyStyle value:(NSString*)value valueStyle:(NSString*)valueStyle;
+ (NSString*)htmlTableWithRows:(NSArray<HtmlTableRow*> *) rows appearance:(HtmlTableViewAppearance*)appearance;

@end
