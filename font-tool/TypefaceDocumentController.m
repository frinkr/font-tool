//
//  TypefaceDocumentController.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/23/17.
//
//
#import "TypefaceWindowController.h"
#import "TypefaceDocumentController.h"
#import "TypefaceSelectorWindowController.h"
#import "TypefaceStylesWindowController.h"
#import "TypefaceManager.h"
#import "Shapper.h"

#pragma mark ##### TypefaceRecentDocument #####

@implementation TypefaceRecentDocumentInfo
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_family forKey:@"family"];
    [aCoder encodeObject:_style forKey:@"style"];
    [aCoder encodeObject:_localizedFullName forKey:@"fullname"];
    [aCoder encodeInteger:_index forKey:@"index"];
    [aCoder encodeObject:_file forKey:@"file"];
    [aCoder encodeObject:_lastOpenTime forKey:@"lastOpen"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _family = [aDecoder decodeObjectForKey:@"family"];
        _style = [aDecoder decodeObjectForKey:@"style"];
        _localizedFullName = [aDecoder decodeObjectForKey:@"fullname"];
        _index = [aDecoder decodeIntegerForKey:@"index"];
        _file  = [aDecoder decodeObjectForKey:@"file"];
        _lastOpenTime = [aDecoder decodeObjectForKey:@"lastOpen"];
    }
    return self;
}

- (id)initWithFamily:(NSString *)family style:(NSString *)style localizedFullName:(NSString*)localizedFullName  index:(NSUInteger)index file:(NSString *)file {
    if (self = [super init]) {
        self.family = family;
        self.style = style;
        self.localizedFullName = localizedFullName;
        self.index = index;
        self.file = file;
        self.lastOpenTime = [NSDate date];
    }
    return self;
}

@end


#pragma mark ##### TypefaceDocumentController #####

@interface TypefaceDocumentController ()
{
    NSMutableArray<TypefaceRecentDocumentInfo*> *_recentDocumentsInfo;
}
@end
@implementation TypefaceDocumentController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self restoreRecentDocumentList];
    
}

- (IBAction)openFontFromFilePanel:(id)sender {
    [self beginOpenPanelWithCompletionHandler:^(NSArray<NSURL *> * files) {
        for (NSURL * url in files) {
            [self openFontFromFilePath:url];
        }
    }];
}

- (IBAction)openFontFromList:(id)sender {
    TypefaceDescriptor * font = [TypefaceSelectorWindowController selectTypeface];
    if (!font)
        return;
    NSURL * path = [TypefaceDocument documentURLWithTypefaceDescriptor:font];
    [self openDocumentForURL:path];
}

- (IBAction)doSearch:(id)sender {
    TypefaceWindowController * twc = (TypefaceWindowController*)[self.currentDocument.windowControllers objectAtIndex:0];
    [twc lookupCharacter:sender];
}

- (BOOL)openFontFromFilePath:(NSURL*)file {
    NSInteger face = [TypefaceStylesWindowController selectTypefaceOfFile:file];
    if (face == -1)
        return YES;
    
    NSURL * faceURL = [TypefaceDocument documentURLWithTypefaceDescriptor:[TypefaceDescriptor descriptorWithFileURL:file faceIndex:face]];
    [self openDocumentForURL:faceURL];
    return YES;
}

- (void)openDocumentForURL:(NSURL*)url {
    [self openDocumentWithContentsOfURL:url display:YES completionHandler:^(NSDocument * document, BOOL documentWasAlreadyOpen, NSError * error) {
        if (!error) {
            TypefaceDocument * tfDoc = (TypefaceDocument*)document;
            if (tfDoc.typeface) {
                for (NSWindowController * wc in [document windowControllers]) {
                    [wc.window setRepresentedFilename:tfDoc.typeface.fileURL.path];
                    wc.window.title = [NSString stringWithFormat:@"%@ %@",
                                       tfDoc.typeface.preferedLocalizedFamilyName, tfDoc.typeface.preferedLocalizedStyleName];

                }
            }

        }
    }];
}

- (NSDocument *)makeDocumentWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
    return [super makeDocumentWithContentsOfURL:url ofType:typeName error:outError];
}

- (id)openDocumentWithContentsOfURL:(NSURL *)url display:(BOOL)display {
    return [super openDocumentWithContentsOfURL:url display:display];
}

- (NSString*)typeForContentsOfURL:(NSURL *)url error:(NSError * __autoreleasing *)outError {
    TypefaceDescriptor * descriptor = [TypefaceDocument typefaceDescriptorWithDocumentURL:url];
    if (descriptor)
        return @"public.font";
    else
        return [super typeForContentsOfURL:url error:outError];
}

- (void)removeDocument:(NSDocument *)document {
    [super removeDocument:document];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.documents.count == 0) {
            [self openFontFromList:self];
        }
    });
}

#pragma mark *** Recents ***

- (void)noteNewRecentDocument:(NSDocument *)document {
    TypefaceDocument * tdoc = (TypefaceDocument*)document;
    Typeface * tface = tdoc.typeface;
    
    TypefaceRecentDocumentInfo* info = nil;
    NSUInteger infoIndex = 0;
    for (NSUInteger i = 0; i < _recentDocumentsInfo.count; ++ i) {
        TypefaceRecentDocumentInfo * aInfo = [_recentDocumentsInfo objectAtIndex:i];
        if ([aInfo.family isEqualToString:tface.familyName] &&
            [aInfo.style isEqualToString:tface.styleName] &&
            [aInfo.file isEqualToString:tface.fileURL.path] &&
            aInfo.index == tface.faceIndex) {
            
            infoIndex = i;
            info = aInfo;
            break;
            aInfo.lastOpenTime = [NSDate date];
        }
    }
    
    if (info) {
        info.lastOpenTime = [NSDate date];
        if (infoIndex) {
            [_recentDocumentsInfo removeObjectAtIndex:infoIndex];
            [_recentDocumentsInfo insertObject:info atIndex:0];
        }
    }
    else {
        info = [[TypefaceRecentDocumentInfo alloc] initWithFamily:tface.familyName
                                                            style:tface.styleName
                                                localizedFullName:[NSString stringWithFormat:@"%@ %@", tface.attributes.preferedLocalizedFamilyName, tface.attributes.preferedLocalizedStyleName]
                                                            index:tface.faceIndex
                                                             file:tface.fileURL.path];
        [_recentDocumentsInfo insertObject:info atIndex:0];
        
    }
    
    [self saveRecentDocumentList];
}

- (IBAction)clearRecentDocuments:(id)sender {
    [_recentDocumentsInfo removeAllObjects];
    [self saveRecentDocumentList];
}

- (void)saveRecentDocumentList {
    NSData *serialized = [NSKeyedArchiver archivedDataWithRootObject:_recentDocumentsInfo];
    [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:@"recentDocumentsInfo"];
}

- (void)restoreRecentDocumentList {
    NSData *serialized = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentDocumentsInfo"];
    if (!serialized)
        return;
    
    _recentDocumentsInfo = [NSKeyedUnarchiver unarchiveObjectWithData:serialized];
    if (!_recentDocumentsInfo)
        _recentDocumentsInfo = [[NSMutableArray<TypefaceRecentDocumentInfo*> alloc] init];
}

- (TypefaceRecentDocumentInfo*)mostRecentDocument {
    if (_recentDocumentsInfo.count)
        return [_recentDocumentsInfo objectAtIndex:0];
    else
        return nil;
}

- (NSMenu*)buildRecentMenuWithAction:(SEL)action clearAction:(SEL)clearAction {
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    for (TypefaceRecentDocumentInfo * info in _recentDocumentsInfo) {
        NSString * menuText = info.localizedFullName;//[NSString stringWithFormat:@"%@ - %@", info.family, info.style];
        NSMenuItem * item = [theMenu addItemWithTitle:menuText action:action keyEquivalent:@""];
        [item setRepresentedObject:info];
        [item setTarget:nil];
    }
    if (_recentDocumentsInfo.count)
        [theMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem * clearItem = [theMenu addItemWithTitle:@"Clear recents" action:clearAction keyEquivalent:@""];
    [clearItem setTarget:nil];
    
    return theMenu;
}
@end
