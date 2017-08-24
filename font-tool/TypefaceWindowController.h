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

- (IBAction)changeGlyphsLabel:(id )sender;
- (IBAction)changeGlyphList:(id )sender;
- (IBAction)changeCMap:(id )sender;
- (IBAction)lookupCharacter:(id )sender;

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *_Nonnull)comboBox;
- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index;

- (void)lookupGlyphWithExpression:(NSString*)expression;
- (void)lookupGlyphWithType:(GlyphLookupType)type value:(NSString *)value;
- (void)lookupGlyph:(GlyphLookupRequest*)request;
@end
