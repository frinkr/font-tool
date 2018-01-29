//
//  TypefaceListWindowController.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/23/17.
//
//

#import "TypefaceSelectorWindowController.h"
#import "TypefaceDocumentController.h"
#import "TypefaceManager.h"
#import "LuaScript.h"
#import "SourceTextView.h"
#import "LuaScriptConsole.h"
#import "HtmlTableView.h"

static TypefaceSelectorWindowController * sharedTypefaceListWC;

#define TypefaceSerifStyleAny (TypefaceSerifStyleUndefined)
#define TypefaceFormatAny ((TypefaceFormat)-1)

typedef NS_ENUM(NSInteger, TypefaceVariationFlavor) {
    TypefaceVariationFlavorAny,
    TypefaceVariationFlavorOpenType,
    TypefaceVariationFlavorAdobeMM,
};


#pragma mark #### TypefaceListFilter ####
@interface TypefaceListFilter : NSObject

@property LuaScript * luaScript;
@property NSString * luaScriptBuffer;
@property NSString * luaScriptFile;
@property (nonatomic) void (^messageHandler)(NSString * message);

- (instancetype)initWithBuffer:(NSString*)script;
- (instancetype)initWithFile:(NSString*)filePath;
- (BOOL)filter:(TMTypeface*)face;
@end

@implementation TypefaceListFilter

- (instancetype)initWithBuffer:(NSString*)script{
    if (self = [super init]) {
        [self reloadWithBuffer:script];
    }
    return self;
}

- (instancetype)initWithFile:(NSString*)filePath {
    if (self = [super init]) {
        [self reloadWithFile:filePath];
    }
    return self;
}

- (BOOL)reloadWithBuffer:(NSString*) script {
    NSString *trimmedText = [script stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedText.length == 0) {
        self.luaScriptBuffer = trimmedText;
        self.luaScript = nil;
    }
    else {
        self.luaScriptBuffer = script;
        self.luaScript = [[LuaScript alloc] initWithBuffer:script
                                            messageHandler:self.messageHandler];
    }
    self.luaScriptFile = nil;

    return true;
}

- (BOOL)reloadWithFile:(NSString*)filePath {
    self.luaScriptBuffer = nil;
    self.luaScriptFile = filePath;
    self.luaScript =  [[LuaScript alloc] initWithFile:filePath messageHandler:self.messageHandler];
    self.luaScript.messageHandler = self.messageHandler;
    return true;
}

- (BOOL)filter:(TMTypeface *)face {
    if (self.isEmpty)
        return YES;
    return [self.luaScript runWithFont:face];
}

- (BOOL)isEmpty {
    return !self.luaScript ;
}
@end


#pragma mark #### TypefaceSelectorWindowController ####

@interface TypefaceSelectorWindowController ()
@property (weak) IBOutlet NSButton *moreButton;
@property (strong) CALayer * moreButtonBadgeLayer;

@property (strong) TypefaceListFilter * filter;

@end


@interface TypefaceComboBoxCell : NSComboBoxCell
{
}
- (void)popUpList;
- (BOOL)isPopUpWindowVisible;
@end

#pragma mark #### TypefaceSelectorViewController ####
@interface TypefaceSelectorViewController ()
@property (weak) IBOutlet NSComboBox *typefaceCombobox;
@property (weak) IBOutlet TypefaceComboBoxCell *typefaceComboboxCell;
@property (unsafe_unretained) IBOutlet NSTextView *typefaceInfoEdit;
@property (assign) IBOutlet NSTextField *sampleTextField;
@property (strong) TypefaceDescriptor * selectedTypefaceDescriptor;
@property (assign) IBOutlet NSArrayController *typefacesArrayController;
@property (nonatomic) HtmlTableView * typefaceDetailsTableView;
@property (weak) IBOutlet NSView *typefaceDetailsPlaceholder;

@property (nonatomic) CGFloat previewFontSize;

@property (strong) HtmlTableRows * tableRows;

- (void)filterTypefaces:(TypefaceListFilter*)filter;
- (IBAction)showRecentTypeMenu:(id)sender;
@end

@interface TypefaceSelectorFilterWindowController()
@property (strong) TypefaceListFilter * filter;
@property (nonatomic) NSString * filePath;
@end

@interface TypefaceSelectorFilterViewController ()
@property (unsafe_unretained) IBOutlet SourceTextView *luaScriptEditor;
@property (strong) TypefaceListFilter * filter;
@end


#pragma mark ##### TypefaceSelectorWindowController #####

@implementation TypefaceSelectorWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.window.delegate = self;
    NSString * scriptBuffer = [NSString stringWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"SampleScripts/template" ofType:@"lua"]
                                                        encoding:NSUTF8StringEncoding
                                                           error:nil];
    
    self.filter = [[TypefaceListFilter alloc] initWithBuffer:scriptBuffer];
    self.filter.messageHandler = ^(NSString * message) {
        [[LuaScriptConsoleWindowController sharedWindowController] appendMessage:message];
    };
    
    self.moreButton.wantsLayer = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] stopModalWithCode: NSModalResponseCancel];
}

+(TypefaceSelectorWindowController*) sharedTypefaceListWindowController {
    if (sharedTypefaceListWC)
        return sharedTypefaceListWC;
    
    sharedTypefaceListWC = [[NSStoryboard storyboardWithName:@"TypefaceSelectorWindow" bundle:nil] instantiateInitialController];
    
    return sharedTypefaceListWC;
}

+(TypefaceDescriptor*)selectTypeface {
    NSWindowController * wc  = [TypefaceSelectorWindowController sharedTypefaceListWindowController];
    
    TypefaceDescriptor * faceDesc = nil;
    
    if (NSModalResponseOK == [NSApp runModalForWindow:wc.window]) {
        TypefaceSelectorViewController * vc = (TypefaceSelectorViewController*)wc.contentViewController;
        faceDesc = vc.selectedTypefaceDescriptor;
    };
    
    [wc.window orderOut:nil];
    return faceDesc;
}

- (IBAction)doToggleFeature:(id)sender {
}

- (IBAction)doShowRecents:(id)sender {
    TypefaceSelectorViewController * vc = (TypefaceSelectorViewController*)self.contentViewController;
    [vc showRecentTypeMenu:sender];
}

- (IBAction)doShowMoreOpenTypeFeatures:(id)sender {
    TypefaceSelectorFilterWindowController * wc = (TypefaceSelectorFilterWindowController*)[[NSStoryboard storyboardWithName:@"TypefaceSelectorWindow" bundle:nil] instantiateControllerWithIdentifier:@"typefaceFilterWindowController"];
    TypefaceSelectorFilterViewController * vc = (TypefaceSelectorFilterViewController*)wc.contentViewController;
    wc.filter = self.filter;
    vc.filter = self.filter;
    
    NSModalResponse response = [NSApp runModalForWindow:wc.window];
    if (response == NSModalResponseOK) {
         [[LuaScriptConsoleWindowController sharedWindowController] flushMessages:self];
        
        TypefaceSelectorViewController * sc = (TypefaceSelectorViewController*)self.contentViewController;
        [sc filterTypefaces:self.filter];
    }
    [wc.window orderOut:nil];
}

@end

@interface NSArrayController(TypefaceListViewController)
- (void)removeAllObjects;
@end

@implementation NSArrayController (TypefaceListViewController)

- (void)removeAllObjects {
    NSRange range = NSMakeRange(0, [[self arrangedObjects] count]);
    
    [self removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
}
@end

#pragma mark ##### TypefaceListViewController #####

@implementation TypefaceSelectorViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadTableView];
    self.previewFontSize = 16;

    [self.typefacesArrayController addObjects:[[TypefaceManager defaultManager] availableFaces]];
    [self.typefaceCombobox reloadData];
    self.typefaceCombobox.completes = NO;
    
    [self selectFaceAtIndex:0];
    
    [self selectRecentTypeface:[((TypefaceDocumentController*)[TypefaceDocumentController sharedDocumentController]) mostRecentDocument]
         autoConfirmIfNotFound:NO];
}

- (void)loadTableView {
    self.typefaceDetailsTableView = [[HtmlTableView alloc] initWithFrame:CGRectMake(0, 0, 600, 150)];
    self.typefaceDetailsTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.typefaceDetailsTableView.dataSource = self;
    self.typefaceDetailsTableView.delegate = self;
    [self.typefaceDetailsPlaceholder addSubview:self.typefaceDetailsTableView];
    
    NSDictionary<NSString*, id> * views = @{@"tableView": self.typefaceDetailsTableView};
    [self.typefaceDetailsPlaceholder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:views]];
    [self.typefaceDetailsPlaceholder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:nil views:views]];
}

-(void)viewWillAppear{
    [super viewWillAppear];
    
    [self.typefaceCombobox becomeFirstResponder];
}

#pragma mark *** HtmlTableViewDataSource ****
- (NSUInteger)numberOfRowsInHtmlTableView:(HtmlTableView *)view {
    return self.tableRows.count;
}

-(HtmlTableRow*)htmlTableView:(HtmlTableView*)view rowAtIndex:(NSUInteger)index {
    return [self.tableRows objectAtIndex:index];
}

-(HtmlTableViewAppearance*)appearanceOfHtmlTableView:(HtmlTableView *)view {
    HtmlTableViewAppearance * appearance = [[HtmlTableViewAppearance alloc] init];
    appearance.keyColumnSize = 150;
    appearance.absoluteKeyColumnSize = YES;
    appearance.dark = YES;
    return appearance;
}


#pragma mark *** Actions ****

- (IBAction)cancelTypefaceSelection:(id)sender {
    [NSApp stopModalWithCode:NSModalResponseCancel];
    self.typefacesArrayController.filterPredicate = nil;
}

- (IBAction)confirmTypeFaceSelection:(id)sender {
    [self readSelectedFont];
    if (self.selectedTypefaceDescriptor)
        [NSApp stopModalWithCode:NSModalResponseOK];
    self.typefacesArrayController.filterPredicate = nil;
}

- (IBAction)doQuit:(id)sender {
    [NSApp terminate:self];
}

- (IBAction)showRecentTypeMenu:(id)sender {

    TypefaceDocumentController * docController = (TypefaceDocumentController*)[TypefaceDocumentController sharedDocumentController];
    NSMenu * theMenu = [docController buildRecentMenuWithAction:@selector(openRecentType:)
                                                    clearAction:@selector(clearAllRecents:)];
    [theMenu setFont:self.typefaceCombobox.font];
    
    NSView * view = (NSView*)sender;
    
    [theMenu popUpMenuPositioningItem:nil
                           atLocation:NSMakePoint(view.bounds.size.width-8, view.bounds.size.height-1)
                               inView:view];

    
}

- (IBAction)openRecentType:(id)sender {
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        NSMenuItem * item = (NSMenuItem*)sender;
        TypefaceRecentDocumentInfo * recent = (TypefaceRecentDocumentInfo*)item.representedObject;
        [self selectRecentTypeface:recent autoConfirmIfNotFound:YES];
    }
}

- (IBAction)clearAllRecents:(id)sender {
    [[TypefaceDocumentController sharedDocumentController] clearRecentDocuments:sender];
}

- (IBAction)doIncreasePreviewFontSize:(id)sender {
    self.previewFontSize *= 1.5;
    [self.sampleTextField setFont:[self selectedFont]];
}

- (IBAction)doDecreasePreviewFontSize:(id)sender {
    self.previewFontSize /= 1.5;
    self.previewFontSize = MAX(1, self.previewFontSize);
    
    [self.sampleTextField setFont:[self selectedFont]];
}


#pragma mark **** Filter ***

- (void)filterTypefaces:(TypefaceListFilter*)filter {
    
    if (filter.isEmpty) {
        [self.typefacesArrayController removeAllObjects];
        [self.typefacesArrayController addObjects:[[TypefaceManager defaultManager] availableFaces]];
        [self.typefacesArrayController setFilterPredicate:nil];
    }
    else {
        NSPredicate * predicate = [NSPredicate predicateWithBlock:^BOOL(id  evaluatedObject, NSDictionary<NSString *,id> *  bindings) {
            TMTypeface * face = (TMTypeface*)evaluatedObject;
            return [filter filter:face];
        }];
        
        NSArray<TMTypeface*> * faces = [[[TypefaceManager defaultManager] availableFaces] filteredArrayUsingPredicate:predicate];
        [self.typefacesArrayController removeAllObjects];
        [self.typefacesArrayController addObjects:faces];
        [[LuaScriptConsoleWindowController sharedWindowController] flushMessages:self];
    }
    
    [self.typefaceCombobox reloadData];
    [self selectFaceAtIndex:0];
}

#pragma mark **** Selection ***

- (TMTypeface*)selectedTypeface {
    NSString * faceUIName = nil;
    if (self.typefaceCombobox.indexOfSelectedItem == -1)
        faceUIName = self.typefaceCombobox.stringValue;
    else
        faceUIName = [self.typefaceCombobox itemObjectValueAtIndex:self.typefaceCombobox.indexOfSelectedItem];
    if (!faceUIName)
        return nil;
    
    NSArray<TMTypeface*> * faces = self.typefacesArrayController.arrangedObjects;
    NSUInteger faceIndex = [faces indexOfObjectPassingTest:^BOOL(TMTypeface * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       if ([obj.UIFullName isEqualToString:faceUIName]) {
           *stop = YES;
           return YES;
       }
        return NO;
    }];
    if (faceIndex == NSNotFound)
        return nil;
    return [faces objectAtIndex:faceIndex];
}

- (NSFont*)selectedFont {
    return [self.selectedTypeface createFontWithSize:self.previewFontSize];
}

- (void)readSelectedFont {
    self.selectedTypefaceDescriptor = [self.selectedTypeface createTypefaceDescriptor];
}

- (void)selectFaceAtIndex:(NSUInteger)index {
    [self.typefaceCombobox selectItemAtIndex:index];
    [self updateTypefaceInformation];
}


- (BOOL)selectRecentTypeface:(TypefaceRecentDocumentInfo*)recent autoConfirmIfNotFound:(BOOL)autoConfirmIfNotFound{
    if (!recent)
        return NO;
    
    BOOL matchFound = NO;
    NSArray<TMTypeface*> * faces = self.typefacesArrayController.arrangedObjects;
    for (NSUInteger index = 0; index < faces.count; ++ index) {
        TMTypeface * face = [faces objectAtIndex:index];
        if ([face.familyName isEqualToString:recent.family] && [face.styleName isEqualToString:recent.style]) {
            [self selectFaceAtIndex:index];
            matchFound = YES;
        }
    }
    
    if (!matchFound && autoConfirmIfNotFound) {
        self.selectedTypefaceDescriptor = [TypefaceDescriptor descriptorWithFilePath:recent.file faceIndex:recent.index];
        [NSApp stopModalWithCode:NSModalResponseOK];
    }

    return matchFound;
}

- (void)updateTypefaceInformation {
    TMTypeface * face = [self selectedTypeface];
    self.tableRows = [[HtmlTableRows alloc] init];
    [self.tableRows addRowWithKey:@"UI Name" stringValue:face.UIFullName];
    [self.tableRows addRowWithKey:@"Postscript Name" stringValue:face.attributes.postscriptName];
    [self.tableRows addRowWithKey:@"Num Glyphs" integerValue:face.attributes.numGlyphs];
    [self.tableRows addRowWithKey:@"UPEM" integerValue:face.attributes.UPEM];
    [self.tableRows addRowWithKey:@"Created Date" stringValue:face.attributes.createdDate];
    [self.tableRows addRowWithKey:@"Modified Date" stringValue:face.attributes.modifiedDate];
    [self.tableRows addRowWithKey:@"OpenType Variation" boolValue:face.attributes.isOpenTypeVariation];
    [self.tableRows addRowWithKey:@"Multiple Master" boolValue:face.attributes.isAdobeMultiMaster];
    [self.tableRows addRowWithKey:@"OpenType Scripts" setValue:face.attributes.openTypeScripts delemiter:@", "];
    [self.tableRows addRowWithKey:@"OpenType Languages" setValue:face.attributes.openTypeLanguages delemiter:@", "];
    [self.tableRows addRowWithKey:@"OpenType Features" setValue:face.attributes.openTypeFeatures delemiter:@", "];
    
    [self.tableRows addSection:@"Names"];
    [self.tableRows addRowWithKey:@"Family Name" stringValue:face.familyName];
    [self.tableRows addRowWithKey:@"Style Name" stringValue:face.styleName];
    [self.tableRows addRowWithKey:@"Full Name" stringValue:face.attributes.fullName];
    [self.tableRows addRowWithKey:@"Localized Family Names" dictionaryValue:face.attributes.localizedFamilyNames delemiter:@"</br>"];
    [self.tableRows addRowWithKey:@"Localized Style Names" dictionaryValue:face.attributes.localizedStyleNames delemiter:@"</br>"];
    [self.tableRows addRowWithKey:@"Localized Full Names" dictionaryValue:face.attributes.localizedFullNames delemiter:@"</br>"];
    [self.tableRows addRowWithKey:@"Design Languages" arrayValue:face.attributes.designLanguages delemiter:@", "];
    
    [self.tableRows addSection:@"Meta Data"];
    [self.tableRows addRowWithKey:@"Format" stringValue:face.attributes.format];
    [self.tableRows addRowWithKey:@"IsCID" boolValue:face.attributes.isCID];
    [self.tableRows addRowWithKey:@"Vender" stringValue:face.attributes.vender];
    [self.tableRows addRowWithKey:@"Version" stringValue:face.attributes.version];
    
    [self.typefaceDetailsTableView reloadData];
    [self.sampleTextField setFont:[self selectedFont]];
}

#pragma mark *** NSComboboxDataSource ****
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    if (notification.object == self.typefaceCombobox) {
        [self updateTypefaceInformation];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.typefaceComboboxCell.isPopUpWindowVisible)
            [self.typefacesArrayController setFilterPredicate:nil];
    });
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    // Select first if no selected
    if (!self.selectedTypeface)
        [self selectFaceAtIndex:0];
    [self.typefacesArrayController setFilterPredicate:nil];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSComboBox * object = notification.object;
    [object setCompletes:NO];
    
    NSPredicate * predicate = [NSPredicate predicateWithBlock:^BOOL(id  evaluatedObject, NSDictionary<NSString *,id> *  bindings) {
        TMTypeface * face = (TMTypeface*)evaluatedObject;
        NSMutableArray<NSString*> * names = [[NSMutableArray alloc] init];
        [names addObjectsFromArray:face.attributes.localizedFamilyNames.allValues];
        [names addObject:face.UIFamilyName];
        for (NSString * name in names ) {
            NSRange range = [name rangeOfString:object.stringValue options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound)
                return YES;
        }
        return NO;
    }];
    
    if (object.stringValue.length)
        [self.typefacesArrayController setFilterPredicate:predicate];
    else
        [self.typefacesArrayController setFilterPredicate:nil];
    
    [self.typefaceComboboxCell popUpList];
}

- (NSString *)comboBox:(NSComboBox *)comboBox completedString:(NSString *)string {
    for (TMTypeface * face in self.typefacesArrayController.arrangedObjects) {
        NSRange range = [face.UIFullName rangeOfString:string options:NSAnchoredSearch|NSCaseInsensitiveSearch];
        if (range.location == 0)
            return face.UIFullName;
    }
    return nil;
}
@end 


@implementation TypefaceComboBoxCell
- (void)popUpList {
    id ax = NSAccessibilityUnignoredDescendant(self);
    [ax accessibilitySetValue: [NSNumber numberWithBool:YES]
                 forAttribute: NSAccessibilityExpandedAttribute];
    return;
    if ([self isPopUpWindowVisible])
        return;
    else
        [_buttonCell performClick:nil];
}

- (BOOL)isPopUpWindowVisible {
    return [_popUp isVisible];
}

- (NSString *)completedString:(NSString *)string {
    if ([_delegate isKindOfClass:[NSComboBox class]]) {
        NSComboBox * cb = (NSComboBox*)_delegate;
        if ([cb.delegate respondsToSelector:@selector(comboBox:completedString:)])
            return [cb.delegate performSelector:@selector(comboBox:completedString:) withObject:cb withObject:string];
    }
    return nil;
}
@end

#pragma mark ##### TypefaceSelectorFilterWindowController #####

@implementation TypefaceSelectorFilterWindowController

- (void)windowWillClose:(NSNotification *)notification {
    [NSApp stopModal];
}

- (NSString*)applicationLibraryDirectory {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    NSString *path = [NSString pathWithComponents:@[libraryPath, appName]];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    return path;
}

- (IBAction)doLoad:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"lua"]];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[self applicationLibraryDirectory] isDirectory:YES]];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
            [self.vc.luaScriptEditor setSource:[NSString stringWithContentsOfURL:theDoc
                                                                        encoding:NSUTF8StringEncoding
                                                                           error:NULL]];
            
            self.filePath = theDoc.path;
        }
    }];
}

- (IBAction)doSave:(id)sender {
    NSSavePanel*  panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:@[@"lua"]];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[self applicationLibraryDirectory] isDirectory:YES]];

    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSFileHandlingPanelOKButton) {
            [self.vc.luaScriptEditor.source writeToURL:panel.URL
                                            atomically:YES
                                              encoding:NSUTF8StringEncoding
                                                 error:NULL];
            self.filePath = panel.URL.path;
        }
    }];
}

- (IBAction)doClear:(id)sender {
    self.vc.luaScriptEditor.source = @"";
}

- (IBAction)doOK:(id)sender {
    BOOL loadFromFile = NO;
    if (self.filePath) {
        NSString * fileContent =
        [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:self.filePath isDirectory:NO]
                                 encoding:NSUTF8StringEncoding
                                    error:NULL];
        if ([self.vc.luaScriptEditor.source isEqualToString:fileContent])
            loadFromFile = YES;
    }
    if (loadFromFile)
        [self.filter reloadWithFile:self.filePath];
    else
        [self.filter reloadWithBuffer:self.vc.luaScriptEditor.source];
    
    [NSApp stopModalWithCode:NSModalResponseOK];
}

- (IBAction)doCancel:(id)sender {
    [NSApp stopModalWithCode:NSModalResponseCancel];
}

- (void)setFilePath:(NSString *)filePath {
    _filePath = filePath;
    [self.window setRepresentedFilename:filePath];
    [self.window setTitle:filePath];
}

- (TypefaceSelectorFilterViewController*)vc {
    return (TypefaceSelectorFilterViewController*)self.contentViewController;
}
@end

@implementation TypefaceSelectorFilterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    // setup Lua editor
    [self.luaScriptEditor setLanguage:kSourceTextViewLanguage_Lua];
    NSMutableDictionary* keywords = [SourceTextView keywordColorsFromKeywordsPropertyList:[[NSBundle mainBundle] pathForResource:@"Keyword-Colors/Lua" ofType:@"plist"]];
    [keywords setObject:[NSColor redColor] forKey:@"lua"];
    [self.luaScriptEditor setKeywordColors:keywords];
    
    if (self.filter.luaScriptBuffer)
        [self.luaScriptEditor setSource:self.filter.luaScriptBuffer];
    else if (self.filter.luaScriptFile) {
        self.luaScriptEditor.source = [NSString stringWithContentsOfFile:self.filter.luaScriptFile
                                                                encoding:NSUTF8StringEncoding
                                                                   error:NULL];
        
        self.wc.filePath = self.filter.luaScriptFile;
    }
}

- (TypefaceSelectorFilterWindowController*)wc {
    return (TypefaceSelectorFilterWindowController*)self.view.window.windowController;
}

- (void)showAlertWithMessage:(NSString*)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [self.view.window beginSheet:alert completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

@end
