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
@property NSString * scriptText;

- (instancetype)initWithLuaScript:(NSString*)script;
- (BOOL)filter:(TMTypeface*)face;
@end

@implementation TypefaceListFilter

- (instancetype)initWithLuaScript:(NSString*)script{
    if (self = [super init]) {
        [self reloadWithLuaScript:script];
    }
    return self;
}

- (BOOL)reloadWithLuaScript:(NSString*) script {
    NSString *trimmedText = [script stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedText.length == 0) {
        self.scriptText = trimmedText;
        self.luaScript = nil;
    }
    else {
        self.scriptText = script;
        self.luaScript = [[LuaScript alloc] initWithString:script];
    }

    return true;
}

- (BOOL)filter:(TMTypeface *)face {
    if (self.isEmpty)
        return YES;
    return [self.luaScript runWithFont:face];
}

- (BOOL)isEmpty {
    return !self.scriptText;
}
@end


@interface TMTypeface(Filter)
- (BOOL)filter:(TypefaceListFilter*)filter;
@end

@implementation TMTypeface(Filter)
- (BOOL)filter:(TypefaceListFilter*)filter {
    return [filter filter:self];
}

@end


@interface TMTypefaceFamily(Filter)
- (BOOL)filter:(TypefaceListFilter*)filter;
@end

@implementation TMTypefaceFamily(Filter)

- (BOOL)filter:(TypefaceListFilter*)filter {
    for (TMTypeface * face in self.faces) {
        if ([face filter:filter])
            return YES;
    }
    return NO;
}

@end

#pragma mark #### TypefaceListWindowController ####

@interface TypefaceSelectorWindowController ()
@property (weak) IBOutlet NSButton *moreButton;
@property (strong) CALayer * moreButtonBadgeLayer;

@property (strong) TypefaceListFilter * filter;

@end

@interface TypefaceSelectorViewController ()
@property (assign) IBOutlet NSComboBox *familyCombobox;
@property (assign) IBOutlet NSComboBox *styleCombobox;
@property (weak) IBOutlet NSTextField *designLanguagesTextField;
@property (weak) IBOutlet NSTextField *featuresTextField;
@property (weak) IBOutlet NSTextField *familiesTextField;
@property (weak) IBOutlet NSTextField *styleTextField;
@property (assign) IBOutlet NSTextField *sampleTextField;
@property (assign) IBOutlet NSButton *recentsButton;
@property (strong) TypefaceDescriptor * selectedTypeface;

@property (assign) IBOutlet NSArrayController *familiesArrayController;
@property (assign) IBOutlet NSArrayController *membersArrayController;

@property (nonatomic) CGFloat previewFontSize;

- (void)filterTypefaces:(TypefaceListFilter*)filter;
- (IBAction)showRecentTypeMenu:(id)sender;
@end

@interface TypefaceSelectorFilterWindowController()
@property (strong) TypefaceListFilter * filter;
@end

@interface TypefaceSelectorFilterViewController ()
@property (unsafe_unretained) IBOutlet SourceTextView *luaScriptEditor;
@property (strong) TypefaceListFilter * filter;
@end


#pragma mark ##### TypefaceListViewController #####

@implementation TypefaceSelectorWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.window.delegate = self;
    
    NSString * script = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SampleScripts/kern" ofType:@"lua"]
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    self.filter = [[TypefaceListFilter alloc] initWithLuaScript:script];
    
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
        faceDesc = vc.selectedTypeface;
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
        TypefaceSelectorViewController * cc = (TypefaceSelectorViewController*)self.contentViewController;
        [cc filterTypefaces:self.filter];
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
    
    self.previewFontSize = 16;

    
    [self.familiesArrayController addObjects:[[TypefaceManager defaultManager] availableTypefaceFamilies]];
    [self.familyCombobox reloadData];
    [self selectFamilyAtIndex:0];
    
    [self selectRecentTypeface:[((TypefaceDocumentController*)[TypefaceDocumentController sharedDocumentController]) mostRecentDocument]
         autoConfirmIfNotFound:NO];
}

-(void)viewWillAppear{
    [super viewWillAppear];
    
    [self.familyCombobox becomeFirstResponder];
}

#pragma mark *** Actions ****

- (IBAction)cancelTypefaceSelection:(id)sender {
    [NSApp stopModalWithCode:NSModalResponseCancel];
}

- (IBAction)confirmTypeFaceSelection:(id)sender {
    [self readSelectedFont];
    [NSApp stopModalWithCode:NSModalResponseOK];
}

- (IBAction)doQuit:(id)sender {
    [NSApp terminate:self];
}

- (IBAction)showRecentTypeMenu:(id)sender {
    TypefaceDocumentController * docController = (TypefaceDocumentController*)[TypefaceDocumentController sharedDocumentController];
    NSMenu * theMenu = [docController buildRecentMenuWithAction:@selector(openRecentType:)
                                                    clearAction:@selector(clearAllRecents:)];
    [theMenu setFont:self.styleCombobox.font];
    
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

- (IBAction)doIncreasePreviewFontSize:(id)sender {
    self.previewFontSize *= 1.5;
    [self.sampleTextField setFont:[self selectedFont]];
}

- (IBAction)doDecreasePreviewFontSize:(id)sender {
    self.previewFontSize /= 1.5;
    self.previewFontSize = MAX(1, self.previewFontSize);
    
    [self.sampleTextField setFont:[self selectedFont]];
}

- (IBAction)clearAllRecents:(id)sender {
    [[TypefaceDocumentController sharedDocumentController] clearRecentDocuments:sender];
}

#pragma mark **** Filter ***

- (void)filterTypefaces:(TypefaceListFilter*)filter {
    
    if (filter.isEmpty) {
        [self.familiesArrayController setFilterPredicate:nil];
    }
    else {
        NSPredicate * predicate = [NSPredicate predicateWithBlock:^BOOL(id  evaluatedObject, NSDictionary<NSString *,id> *  bindings) {
            TMTypefaceFamily * family = (TMTypefaceFamily*)evaluatedObject;
            return [family filter:filter];
        }];
        [self.familiesArrayController setFilterPredicate:predicate];
    }
    
    [self.familyCombobox reloadData];
    [self selectFamilyAtIndex:0];
}

#pragma mark **** Selection ***

- (TMTypeface*)selectedTypefaceEntry {
    
    NSString * familyName = self.familyCombobox.stringValue;
    NSString * styleName = self.styleCombobox.stringValue;
    
    NSArray<TMTypefaceFamily*> * families = self.familiesArrayController.arrangedObjects;
    
    NSUInteger familyIndex = [families indexOfObjectPassingTest:^BOOL(TMTypefaceFamily * obj, NSUInteger idx, BOOL * stop) {
        if ([obj.localizedFamilyName isEqualToString:familyName]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (familyIndex == NSNotFound)
        return nil;
    
    TMTypefaceFamily * family = [families objectAtIndex:familyIndex];
    
    NSUInteger styleIndex = [family.faces indexOfObjectPassingTest:^BOOL(TMTypeface *  obj, NSUInteger idx, BOOL *  stop) {
        if ([obj.localizedStyleName isEqualToString:styleName]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (styleIndex == NSNotFound)
        return nil;
    return [family.faces objectAtIndex:styleIndex];
}

- (NSFont*)selectedFont {
    return [self.selectedTypefaceEntry createFontWithSize:self.previewFontSize];
}

- (void)readSelectedFont {
    self.selectedTypeface = [self.selectedTypefaceEntry createTypefaceDescriptor];
}

- (void)selectFamilyAtIndex:(NSUInteger)index {
    if (index >= [self.familiesArrayController.arrangedObjects count]) {
        [self.membersArrayController removeAllObjects];
        [self.styleCombobox reloadData];
    }
    else {
        [self.familyCombobox selectItemAtIndex:index];
        
        TMTypefaceFamily * family = [self.familiesArrayController.arrangedObjects objectAtIndex:index];
        
        [self.membersArrayController removeAllObjects];
        [self.membersArrayController addObjects:family.faces];
        
        [self.styleCombobox reloadData];
        
        // Select Regular automatically
        NSUInteger index = [self.styleCombobox indexOfItemWithObjectValue:@"Regular"];
        if (index == NSNotFound)
            index = 0;
        [self selectStyleAtIndex:index];
    }
}

- (void)selectStyleAtIndex:(NSUInteger)index {
    if (index == -1) // nothing selected
        return;
    
    [self.membersArrayController setSelectionIndex:index];
    [self.styleCombobox selectItemAtIndex:index];
    
    [self updateTypefaceInformation];
}

- (BOOL)selectRecentTypeface:(TypefaceRecentDocumentInfo*)recent autoConfirmIfNotFound:(BOOL)autoConfirmIfNotFound{
    if (!recent)
        return NO;
    
    BOOL matchFound = NO;
    
    NSArray<TMTypefaceFamily*>* families = self.familiesArrayController.arrangedObjects;
    for (NSUInteger familyIndex = 0; familyIndex < [families count]; ++ familyIndex) {
        TMTypefaceFamily * family = [families objectAtIndex:familyIndex];
        if ([family.familyName isEqualToString:recent.family]) {
            [self selectFamilyAtIndex:familyIndex];
            
            NSArray<TMTypeface *> * members = self.membersArrayController.arrangedObjects;
            for (NSUInteger memberIndex = 0; memberIndex < members.count; ++ memberIndex) {
                TMTypeface * member = [members objectAtIndex:memberIndex];
                if ([member.styleName isEqualToString:recent.style]) {
                    [self selectStyleAtIndex:memberIndex];
                    matchFound = YES;
                }
            }
        }
    }
    
    if (!matchFound && autoConfirmIfNotFound) {
        self.selectedTypeface = [TypefaceDescriptor descriptorWithFilePath:recent.file faceIndex:recent.index];
        [NSApp stopModalWithCode:NSModalResponseOK];
    }
    return matchFound;
}

- (void)updateTypefaceInformation {
    TMTypeface * face = [self selectedTypefaceEntry];
    self.designLanguagesTextField.stringValue = [face.attributes.designLanguages componentsJoinedByString:@", "];
    self.featuresTextField.stringValue = [face.attributes.openTypeFeatures.allObjects componentsJoinedByString:@", "];
    
    NSString * (^generateNameString)(NSDictionary<NSString*, NSString*>*) = ^(NSDictionary<NSString*, NSString*>* names) {
        NSMutableArray<NSString*> * array = [[NSMutableArray<NSString*> alloc] init];
        for (NSString * lang in names)
            [array addObject:[NSString stringWithFormat:@"%@(%@)", [names objectForKey:lang], lang]];
        return [array componentsJoinedByString:@", "];
    };
    
    self.familiesTextField.stringValue = generateNameString(face.attributes.localizedFamilyNames);
    self.styleTextField.stringValue = generateNameString(face.attributes.localizedStyleNames);
    
    [self.sampleTextField setFont:[face createFontWithSize:self.previewFontSize]];
}

#pragma mark *** NSComboboxDataSource ****
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    if (notification.object == self.familyCombobox) {
        [self selectFamilyAtIndex:self.familyCombobox.indexOfSelectedItem];
    }
    else if (notification.object == self.styleCombobox) {
        [self selectStyleAtIndex:self.styleCombobox.indexOfSelectedItem];
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    if (notification.object == self.familyCombobox) {
        NSString * text = self.familyCombobox.stringValue;
        NSInteger index = [self.familyCombobox indexOfItemWithObjectValue:text];
        if (index != -1)
            [self selectFamilyAtIndex:index];
    }
}

@end 

@implementation TypefaceSelectorFilterWindowController

- (void)windowWillClose:(NSNotification *)notification {
    [NSApp stopModal];
}

- (IBAction)doLoad:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"lua"]];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
            [self.vc.luaScriptEditor setSource:[NSString stringWithContentsOfURL:theDoc
                                                                        encoding:NSUTF8StringEncoding error:NULL]];
            
            [self.window setRepresentedFilename:theDoc.path];
            [self.window setTitle:theDoc.path];
        }
    }];
}


- (IBAction)doSave:(id)sender {
    NSSavePanel*  panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:@[@"lua"]];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSFileHandlingPanelOKButton) {
            [self.vc.luaScriptEditor.source writeToURL:panel.URL
                                            atomically:YES
                                              encoding:NSUTF8StringEncoding
                                                 error:NULL];
        }
    }];
}

- (IBAction)doOK:(id)sender {
    [self.filter reloadWithLuaScript:self.vc.luaScriptEditor.source];
    [NSApp stopModalWithCode:NSModalResponseOK];
}

- (IBAction)doCancel:(id)sender {
    [NSApp stopModalWithCode:NSModalResponseCancel];
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
    
    if (self.filter.scriptText)
        [self.luaScriptEditor setSource:self.filter.scriptText];
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
