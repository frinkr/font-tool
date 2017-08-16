//
//  GlyphLookupWindowController.h
//  tx-research
//
//  Created by Yuqing Jiang on 5/27/17.
//
//

#import <Cocoa/Cocoa.h>
#include "TypefaceDocument.h"

@interface GlyphLookupWindowController : NSWindowController

+(GlyphLookupWindowController*)sharedGlyphLookupWindowController;
- (void)toggleWindow:(id)sender;
@end


@interface GlyphLookupViewController : NSViewController <NSTextFieldDelegate, NSControlTextEditingDelegate>
@property (nonatomic) BOOL isAutocompleting;
@property (nonatomic, strong) NSString * lastEntry;
@property (nonatomic) BOOL backspaceKey;
@end
