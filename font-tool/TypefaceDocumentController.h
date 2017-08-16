//
//  TypefaceDocumentController.h
//  tx-research
//
//  Created by Yuqing Jiang on 5/23/17.
//
//

#import <Cocoa/Cocoa.h>
#import "TypefaceDocument.h"

@interface TypefaceRecentDocumentInfo : NSObject <NSCoding>
@property (strong) NSString * family;
@property (strong) NSString * style;
@property (strong) NSString * localizedFullName;

@property (atomic) NSUInteger index;
@property (strong) NSString * file;

@property (strong) NSDate   * lastOpenTime;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

- (id)initWithFamily:(NSString*)family style:(NSString*)style localizedFullName:(NSString*)localizedFullName index:(NSUInteger) index file:(NSString*)file;

@end

@interface TypefaceDocumentController : NSDocumentController

- (IBAction)openFontFromFile:(id)sender;
- (IBAction)openFontFromList:(id)sender;
- (IBAction)doSearch:(id)sender;

- (TypefaceRecentDocumentInfo*)mostRecentDocument;

- (NSMenu*)buildRecentMenuWithAction:(SEL)action clearAction:(SEL)clearAction;

@end
