//
//  TypefaceListWindowController.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/23/17.
//
//

#import "TypefaceListWindowController.h"
#import "TypefaceDocumentController.h"
#import "TypefaceManager.h"

static TypefaceListWindowController * sharedTypefaceListWC;

#define TypefaceSerifStyleAny (TypefaceSerifStyleUndefined)
#define TypefaceFormatAny ((TypefaceFormat)-1)

typedef NS_ENUM(NSInteger, TypefaceVariationFlavor) {
    TypefaceVariationFlavorAny,
    TypefaceVariationFlavorOpenType,
    TypefaceVariationFlavorAdobeMM,
};


#pragma mark #### TypefaceListFilter ####
@interface TypefaceListFilter : NSObject<NSMutableCopying>
@property (strong) NSMutableArray<TypefaceTag*> * openTypeScripts;
@property (strong) NSMutableArray<TypefaceTag*> * openTypeLanguages;
@property (strong) NSMutableSet<OpenTypeFeatureTag*> * openTypeFeatures;
@property (strong) NSMutableArray<NSString*> * designLanguages;

@property TypefaceSerifStyle serifStyle;
@property TypefaceFormat format;
@property TypefaceVariationFlavor variationFlavor;
@property NSString * familyName;

- (BOOL)isEmpty;
@end

@implementation TypefaceListFilter
- (instancetype)init {
    if (self = [super init]) {
        self.openTypeScripts = [[NSMutableArray<TypefaceTag*> alloc] init];
        self.openTypeLanguages = [[NSMutableArray<TypefaceTag*> alloc] init];
        self.openTypeFeatures = [[NSMutableSet<OpenTypeFeatureTag*> alloc] init];
        
        self.designLanguages = [[NSMutableArray<NSString*> alloc] init];
        self.serifStyle = TypefaceSerifStyleAny;
        self.format = TypefaceFormatAny;
        self.variationFlavor = TypefaceVariationFlavorAny;
        self.familyName = @"";
    }
    return self;
}

- (BOOL)isEmpty {
    return
    _openTypeScripts.count == 0 &&
    _openTypeLanguages.count == 9 &&
    _openTypeFeatures.count == 0 &&
    _designLanguages.count == 0 &&
    _serifStyle == TypefaceSerifStyleAny &&
    _format == TypefaceFormatAny &&
    _variationFlavor == TypefaceVariationFlavorAny &&
    _familyName.length == 0;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    
    TypefaceListFilter * copy = [[[self class] allocWithZone:zone] init];
    copy.openTypeScripts = [self.openTypeScripts mutableCopyWithZone:zone];
    copy.openTypeLanguages = [self.openTypeLanguages mutableCopyWithZone:zone];
    copy.openTypeFeatures = [self.openTypeFeatures mutableCopyWithZone:zone];
    
    copy.designLanguages = [self.designLanguages mutableCopyWithZone:zone];
    copy.serifStyle = self.serifStyle;
    copy.format = self.format;
    copy.variationFlavor = self.variationFlavor;
    copy.familyName = [self.familyName mutableCopyWithZone:zone];
    return copy;
}
@end


@interface TMTypeface(Filter)
@property (readonly, getter=getLocalizedName) NSString* localizedName;
- (BOOL)filter:(TypefaceListFilter*)filter;
@end


@implementation TMTypeface(Filter)
- (BOOL)filter:(TypefaceListFilter*)filter {
    if (self.attributes.serifStyle != filter.serifStyle)
        return NO;
    
    if (filter.variationFlavor != TypefaceVariationFlavorAny) {
        if ((filter.variationFlavor == TypefaceVariationFlavorOpenType && !self.attributes.isOpenTypeVariable) ||
            (filter.variationFlavor == TypefaceVariationFlavorAdobeMM && !self.attributes.isAdobeMultiMaster))
            return NO;
    }
    
    if ((filter.format != TypefaceFormatAny) && (self.attributes.format != filter.format))
        return NO;
    
    if (filter.openTypeScripts.count && ![[NSSet setWithArray:filter.openTypeScripts] intersectsSet: self.attributes.openTypeScripts])
        return NO;
    if (filter.openTypeLanguages.count && ![[NSSet setWithArray:filter.openTypeLanguages] intersectsSet: self.attributes.openTypeLanguages])
        return NO;
    if (![filter.openTypeFeatures isSubsetOfSet: self.attributes.openTypeFeatures])
        return NO;
    
    if (filter.familyName.length) {
        BOOL contains = NO;
        for (NSString * name in self.attributes.localizedFamilyNames.allValues) {
            if ([name rangeOfString:filter.familyName options:NSCaseInsensitiveSearch].location != NSNotFound) {
                contains = YES;
                break;
            }
        }
        if (!contains)
            return NO;
    }
    
    if (filter.designLanguages.count == 0)
        return YES;
    NSSet * set1 = [NSSet setWithArray:filter.designLanguages];
    NSSet * set2 = [NSSet setWithArray:self.attributes.localizedFamilyNames.allKeys];
    return [set1 intersectsSet:set2];
}

- (NSString*)getLocalizedName {
    return self.attributes.preferedLocalizedStyleName;
}
@end


@interface TMTypefaceFamily(Filter)
@property (readonly, getter=getLocalizedName) NSString* localizedName;
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

- (NSString*)getLocalizedName {
    return self.localizedFamilyName;
}

@end

#pragma mark #### TypefaceListWindowController ####

@interface TypefaceListWindowController ()

@property (weak) IBOutlet NSButton *ligaToggle;
@property (weak) IBOutlet NSButton *caltToggle;
@property (weak) IBOutlet NSButton *dligToggle;
@property (weak) IBOutlet NSButton *swshToggle;
@property (weak) IBOutlet NSButton *saltToggle;
@property (weak) IBOutlet NSButton *titlToggle;
@property (weak) IBOutlet NSButton *ordnToggle;
@property (weak) IBOutlet NSButton *fracToggle;
@property (weak) IBOutlet NSButton *moreButton;
@property (strong) CALayer * moreButtonBadgeLayer;

@property (strong) TypefaceListFilter * filter;

@end

@interface TypefaceListViewController ()
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


@interface TypefaceListFilterViewController ()

@property (weak) IBOutlet NSTextField *otScriptsTextField;
@property (weak) IBOutlet NSTextField *otLanguagesTextField;
@property (weak) IBOutlet NSTextField *otFeaturesTextField;

@property (weak) IBOutlet NSTextField *familyNameTextField;
@property (weak) IBOutlet NSSegmentedControl *serifStyleSegments;
@property (weak) IBOutlet NSSegmentedControl *variationSegments;
@property (weak) IBOutlet NSTextField *designLanguagesTextField;
@property (weak) IBOutlet NSSegmentedControl *formatSegments;

@property (strong) TypefaceListFilter * filter;
@end

static uint32_t   toolBarTags[] = {
    MAKE_TAG('liga'), MAKE_TAG('calt'), MAKE_TAG('dlig'), MAKE_TAG('swsh'),
    MAKE_TAG('salt'), MAKE_TAG('titl'), MAKE_TAG('ordn'), MAKE_TAG('frac')};

#pragma mark ##### TypefaceListViewController #####


@implementation TypefaceListWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.window.delegate = self;
    self.filter = [[TypefaceListFilter alloc] init];
    
    self.moreButton.wantsLayer = YES;
    //self.window.titleVisibility = NSWindowTitleHidden;
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] stopModalWithCode: NSModalResponseCancel];
}

+(TypefaceListWindowController*) sharedTypefaceListWindowController {
    if (sharedTypefaceListWC)
        return sharedTypefaceListWC;
    
    sharedTypefaceListWC = [[NSStoryboard storyboardWithName:@"TypefaceListWindow" bundle:nil] instantiateInitialController];
    
    return sharedTypefaceListWC;
}

+(TypefaceDescriptor*)selectTypeface {
    NSWindowController * wc  = [TypefaceListWindowController sharedTypefaceListWindowController];
    
    TypefaceDescriptor * faceDesc = nil;
    
    if (NSModalResponseOK == [NSApp runModalForWindow:wc.window]) {
        TypefaceListViewController * vc = (TypefaceListViewController*)wc.contentViewController;
        faceDesc = vc.selectedTypeface;
    };
    
    [wc.window orderOut:nil];
    return faceDesc;
}

- (IBAction)doToggleFeature:(id)sender {
    NSArray<NSButton*> * toggles = [self toolbarToggleButtons];
    
    for (int i = 0; i < sizeof(toolBarTags)/sizeof(toolBarTags[0]); ++ i) {
        if (sender == [toggles objectAtIndex:i]) {
            OpenTypeFeatureTag * tag = [OpenTypeFeatureTag tagFromCode:toolBarTags[i]];
            if ([toggles objectAtIndex:i].state == NSOnState)
                [self.filter.openTypeFeatures addObject:tag];
            else
                [self.filter.openTypeFeatures removeObject:tag];
            
        }
    }
    
    TypefaceListViewController * vc = (TypefaceListViewController*)self.contentViewController;
    [vc filterTypefaces:self.filter];
}

- (IBAction)doShowRecents:(id)sender {
    TypefaceListViewController * vc = (TypefaceListViewController*)self.contentViewController;
    [vc showRecentTypeMenu:sender];
}

- (IBAction)doShowMoreOpenTypeFeatures:(id)sender {
    NSWindowController * wc = [[NSStoryboard storyboardWithName:@"TypefaceListWindow" bundle:nil] instantiateControllerWithIdentifier:@"openTypeFeaturesWindowController"];
    TypefaceListFilterViewController * vc = (TypefaceListFilterViewController*)wc.contentViewController;
    vc.filter = [self.filter mutableCopy];
    [self.window beginSheet:wc.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            self.filter = vc.filter;
            TypefaceListViewController * vc = (TypefaceListViewController*)self.contentViewController;
            [self updateToobarButtons];
            [vc filterTypefaces:self.filter];
        }
    }];
}

- (void)updateToobarButtons {
    NSArray<NSButton*> * toggles = [self toolbarToggleButtons];
    
    NSMutableSet<OpenTypeFeatureTag*> * toggleTags = [[NSMutableSet<OpenTypeFeatureTag*> alloc] init];
    
    // update toggle states
    for (int i = 0; i < sizeof(toolBarTags)/sizeof(toolBarTags[0]); ++ i) {
        OpenTypeFeatureTag * tag = [OpenTypeFeatureTag tagFromCode:toolBarTags[i]];
        BOOL featureOn = [self.filter.openTypeFeatures containsObject:tag];
        if (featureOn != ([toggles objectAtIndex:i].state == NSOnState)) {
            [[toggles objectAtIndex:i] setState:featureOn? NSOnState: NSOffState];
        }
        if (featureOn)
            [toggleTags addObject:tag];
    }
    
    // badge on the more button
    BOOL showBadge = NO;
    showBadge = (self.filter.serifStyle != TypefaceSerifStyleAny) ||
    (self.filter.format != TypefaceFormatAny) ||
    (self.filter.variationFlavor != TypefaceVariationFlavorAny) ||
    (self.filter.designLanguages.count != 0) ||
    (self.filter.openTypeScripts.count != 0) ||
    (self.filter.openTypeLanguages.count != 0) ||
    (self.filter.familyName.length);
    
    if (!showBadge) {
        NSMutableSet<OpenTypeFeatureTag*>* moreTags = [self.filter.openTypeFeatures mutableCopy];
        [moreTags minusSet:toggleTags];
        
        showBadge = (moreTags.count != 0);
    }
    if (!self.moreButtonBadgeLayer && showBadge) {
        self.moreButtonBadgeLayer = [CALayer layer];
        self.moreButtonBadgeLayer.cornerRadius = 2;
        self.moreButtonBadgeLayer.backgroundColor = [NSColor redColor].CGColor;
        
        CGSize size = self.moreButton.bounds.size;
        self.moreButtonBadgeLayer.frame = CGRectMake(size.width - 4, size.height - 4, 4, 4);
    }
    if (showBadge)
        [self.moreButton.layer addSublayer:self.moreButtonBadgeLayer];
    else
        [self.moreButtonBadgeLayer removeFromSuperlayer];
}

- (NSArray<NSButton*>*)toolbarToggleButtons {
    return @[_ligaToggle, _caltToggle, _dligToggle, _swshToggle,
             _saltToggle, _titlToggle, _ordnToggle, _fracToggle];
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

@implementation TypefaceListViewController

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

@implementation TypefaceListFilterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    // serif style
    [self.serifStyleSegments setSelected:YES forSegment:self.filter.serifStyle];
    
    [self.formatSegments setSelected:YES forSegment:self.filter.format + 1];
    
    [self.variationSegments setSelected:YES forSegment:self.filter.variationFlavor];

    
    // let's make an order. toolbar ligatures on first row, others are in second row and sorted
    
    NSMutableArray<OpenTypeFeatureTag*> * sortedTags = [[NSMutableArray<OpenTypeFeatureTag*> alloc] init];
    
    for (int i = 0; i < sizeof(toolBarTags)/sizeof(toolBarTags[0]); ++ i) {
        OpenTypeFeatureTag * tag = [OpenTypeFeatureTag tagFromCode:toolBarTags[i]];
        if ([self.filter.openTypeFeatures containsObject:tag]) {
            [sortedTags addObject:tag];
        }
    }
    
    NSMutableSet<OpenTypeFeatureTag*> * secondRowTags = [self.filter.openTypeFeatures mutableCopy];
    [secondRowTags minusSet:[NSSet setWithArray:sortedTags]];
    
    NSMutableArray<OpenTypeFeatureTag*>* secondPart = [secondRowTags.allObjects mutableCopy];
    [secondPart sortUsingComparator:^NSComparisonResult(OpenTypeFeatureTag *   obj1, OpenTypeFeatureTag *   obj2) {
        return [obj1.text compare:obj2.text];
    }];
    
    [sortedTags addObjectsFromArray:[secondRowTags allObjects]];
    [self.otFeaturesTextField setStringValue:[sortedTags componentsJoinedByString:@", "]];
    
    // family name
    self.familyNameTextField.stringValue = self.filter.familyName;
    
    // design langauges
    self.designLanguagesTextField.stringValue = [self.filter.designLanguages componentsJoinedByString:@", "];
    
    // ot scripts
    self.otScriptsTextField.stringValue = [self.filter.openTypeScripts componentsJoinedByString:@", "];
    
    // ot languages
    self.otLanguagesTextField.stringValue = [self.filter.openTypeLanguages componentsJoinedByString:@", "];
}

- (void)cancelOperation:(id)sender {
    [self.view.window.sheetParent endSheet:self.view.window returnCode:NSModalResponseCancel];
}

- (IBAction)doConfirmFeatures:(id)sender {
    
    [self.filter.openTypeScripts removeAllObjects];
    [self.filter.openTypeLanguages removeAllObjects];
    [self.filter.openTypeFeatures removeAllObjects];
    
    [self.filter.designLanguages removeAllObjects];
    
    self.filter.serifStyle = (TypefaceSerifStyle)self.serifStyleSegments.selectedSegment;
    self.filter.format = (TypefaceFormat)(self.formatSegments.selectedSegment - 1);
    self.filter.variationFlavor = (TypefaceVariationFlavor)(self.variationSegments.selectedSegment);
    self.filter.familyName = self.familyNameTextField.stringValue;
    
    // OpenType scripts
    for (NSString * tagStr0 in [self.otScriptsTextField.stringValue componentsSeparatedByString:@","]) {
        NSString * tagStr = [tagStr0 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (tagStr.length == 0)
            continue;
        
        NSUInteger code = [TypefaceTag textToCode:tagStr];
        if (code == -1) {
            [self showAlertWithMessage:[NSString stringWithFormat:@"Can't pass code of %@", tagStr]];
            return;
        }
        TypefaceTag * tag = [TypefaceTag tagFromCode:code];
        [self.filter.openTypeScripts addObject:tag];
    }
    
    // OpenType Languages
    for (NSString * tagStr0 in [self.otLanguagesTextField.stringValue componentsSeparatedByString:@","]) {
        NSString * tagStr = [tagStr0 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (tagStr.length == 0)
            continue;
        
        NSUInteger code = [TypefaceTag textToCode:tagStr];
        if (code == -1) {
            [self showAlertWithMessage:[NSString stringWithFormat:@"Can't pass code of %@", tagStr]];
            return;
        }
        TypefaceTag * tag = [TypefaceTag tagFromCode:code];
        [self.filter.openTypeLanguages addObject:tag];
    }
    
    // OpenType features
    for (NSString * tagStr0 in [self.otFeaturesTextField.stringValue componentsSeparatedByString:@","]) {
        NSString * tagStr = [tagStr0 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (tagStr.length == 0)
            continue;
        
        NSUInteger code = [OpenTypeFeatureTag textToCode:tagStr];
        if (code == -1) {
            [self showAlertWithMessage:[NSString stringWithFormat:@"Can't pass code of %@", tagStr]];
            return;
        }
        OpenTypeFeatureTag * tag = [OpenTypeFeatureTag tagFromCode:code];
        [self.filter.openTypeFeatures addObject:tag];
    }
    

    
    // Languages
    if (self.designLanguagesTextField.stringValue.length)
        self.filter.designLanguages = [[self.designLanguagesTextField.stringValue componentsSeparatedByString:@","] mutableCopy];
    
    [self.view.window.sheetParent endSheet:self.view.window returnCode:NSModalResponseOK];
}

- (IBAction)doOpenWikipedia:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://en.wikipedia.org/wiki/List_of_typographic_features"]];
}

- (void)showAlertWithMessage:(NSString*)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert runModal];
}

@end
