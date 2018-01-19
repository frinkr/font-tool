//
//  TypefaceListWindowController.h
//  tx-research
//
//  Created by Yuqing Jiang on 5/23/17.
//
//

#import <Cocoa/Cocoa.h>
#import "Typeface.h"

@interface TypefaceSelectorWindowController : NSWindowController <NSWindowDelegate>
+(TypefaceSelectorWindowController*) sharedTypefaceListWindowController;
+(TypefaceDescriptor*)selectTypeface;

- (IBAction)doToggleFeature:(id)sender;

@end

@interface TypefaceSelectorViewController : NSViewController<NSComboBoxDataSource, NSComboBoxDelegate>
- (IBAction)cancelTypefaceSelection:(id)sender;
- (IBAction)confirmTypeFaceSelection:(id)sender;
@end


@interface TypefaceSelectorFilterViewController : NSViewController
@end


extern void (^ParseTestSuccessBlock)(float value);
extern void (^ParseTestFailBlock)(NSString *msg);

// Added some extras to suppress warnings...
#ifndef FLEXINT_H

typedef struct yy_buffer_state *YY_BUFFER_STATE;
YY_BUFFER_STATE  yy_scan_string(const char *s);

int yyparse();
void yy_delete_buffer(YY_BUFFER_STATE buf);

#endif
