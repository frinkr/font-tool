//
//  HtmlTableView.h
//  tx-research
//
//  Created by Yuqing Jiang on 5/19/17.
//
//

#import <WebKit/WebKit.h>

@interface HtmlTableRow : NSObject
@property (strong) NSString * _Nonnull key;
@property (strong) NSString * _Nonnull value;
- (id _Nonnull )initWithKey:(NSString*_Nonnull)key value:(NSString*_Nonnull)value;
@end

extern HtmlTableRow * MakeHtmlTableRow(NSString *key, NSString * value);

@interface NSMutableArray  (HtmlTableRow)
- (void)addRowWithKey:(NSString*_Nonnull)key stringValue:(NSString*_Nonnull)value;
- (void)addRowWithKey:(NSString*_Nonnull)key boolValue:(BOOL)value;
- (void)addRowWithKey:(NSString*_Nonnull)key integerValue:(NSInteger)value;
- (void)addRowWithKey:(NSString*_Nonnull)key unsignedIntegerValue:(NSUInteger)value;
- (void)addRowWithKey:(NSString*_Nonnull)key doubleValue:(double)value;
- (void)addRowWithKey:(NSString*_Nonnull)key uint32HexValue:(NSUInteger)value withPrefix:(NSString*_Nonnull)prefix;
- (void)addRowWithKey:(NSString*_Nonnull)key uint16HexValue:(NSUInteger)value withPrefix:(NSString*_Nonnull)prefix;
- (void)addRowWithKey:(NSString*_Nonnull)key bitsValue:(NSUInteger)value count:(NSUInteger)count;

@end

typedef NSMutableArray<HtmlTableRow*> HtmlTableRows;

@class HtmlTableView;

@protocol HtmlTableViewDataSource <NSObject>
@required
-(NSUInteger)numberOfRowsInHtmlTableView:(HtmlTableView*_Nonnull)view;
-(HtmlTableRow*_Nonnull)htmlTableView:(HtmlTableView*_Nonnull)view rowAtIndex:(NSUInteger)index;
@end


@interface HtmlTableViewAppearance : NSObject
@property CGFloat fontSize;
@property NSUInteger keyColumnSize; // 0-100, zero means free size
@property BOOL dark;

-(instancetype)init;

+(instancetype)defaultAppearance;

@end

@protocol HtmlTableViewDelegate <NSObject>
- (HtmlTableViewAppearance*_Nonnull) appearanceOfHtmlTableView:(HtmlTableView*_Nonnull)view;
@end


@interface HtmlTableView : WKWebView<WKNavigationDelegate>

@property (nullable, weak) id<HtmlTableViewDataSource> dataSource;
@property (nullable, weak) id<HtmlTableViewDelegate> delegate;

- (instancetype)initWithFrame:(NSRect)frameRect;

- (void)reloadData;

+ (NSString*)htmlTableRowWithKey:(NSString*)key keyStyle:(NSString*)keyStyle value:(NSString*)value valueStyle:(NSString*)valueStyle;
+ (NSString*)htmlTableWithRows:(NSArray<HtmlTableRow*> *) rows appearance:(HtmlTableViewAppearance*)appearance;

@end
