//
//  FontWindowController.h
//  tx-research
//
//  Created by Yuqing Jiang on 5/16/17.
//
//

#import <Cocoa/Cocoa.h>
#import "GlyphCollectionViewController.h"
#import "GlyphInfoViewController.h"

@interface TypefaceWindowController : NSWindowController<GlyphCollectionViewControllerDelegate, NSComboBoxDataSource>

- (IBAction)changeGlyphsLabel:(id _Nullable )sender;
- (IBAction)changeGlyphList:(id _Nullable )sender;
- (IBAction)changeCMap:(id _Nullable )sender;
- (IBAction)lookupCharacter:(id _Nullable )sender;

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *_Nonnull)comboBox;
- (nullable id)comboBox:(NSComboBox *_Nonnull)comboBox objectValueForItemAtIndex:(NSInteger)index;

- (void)lookupGlyphWithExpression:(NSString*)expression;
- (void)lookupGlyphWithType:(GlyphLookupType)type value:(NSString *_Nonnull)value;
- (void)lookupGlyph:(GlyphLookupRequest*)request;
@end
