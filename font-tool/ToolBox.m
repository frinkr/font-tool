//
//  ToolBox.m
//  tx-research
//
//  Created by Yuqing Jiang on 6/23/17.
//
//

#import "ToolBox.h"

@interface ToolBox ()
@property NSMutableSet<NSWindowController*> * windowControllers;
@end

static ToolBox * instance;

@implementation ToolBox

- (instancetype)init {
    if (self = [super init]) {
        _windowControllers = [[NSMutableSet<NSWindowController*> alloc] init];
    }
    return self;
}

- (void)showWindowController:(NSString*)storyboardIdentifier dark:(BOOL)dark {
    NSWindowController * wc = [[NSStoryboard storyboardWithName:@"ToolBox" bundle:nil] instantiateControllerWithIdentifier:storyboardIdentifier];
    if (dark)
        wc.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    [wc showWindow:nil];
    
    [self addWindowController:wc];
}

- (void)showWindowController:(NSString*)storyboardIdentifier {
    return [self showWindowController:storyboardIdentifier dark:NO];
}

- (void)addWindowController:(NSWindowController*)windowController {
    if ([self.windowControllers containsObject:windowController])
        return;
    
    [self.windowControllers addObject:windowController];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:windowController.window];
    
}

- (void)windowWillClose:(NSNotification*)notification {
    if ([notification.name isEqualToString:NSWindowWillCloseNotification]) {
        NSWindow * window = notification.object;
        [self removeWindowController:window.windowController];
    }
}

- (void)removeWindowController:(NSWindowController*)windowController {
    if (![self.windowControllers containsObject:windowController])
        return;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSWindowWillCloseNotification
                                                  object:windowController.window];
    
    [self.windowControllers removeObject:windowController];
}

+ (void)showNSColorWindow {
    [[ToolBox sharedToolBox] showWindowController: @"NSColorConstantsWindowController" dark:NO];
}

+ (void)showNSColorDarkWindow {
    [[ToolBox sharedToolBox] showWindowController: @"NSColorConstantsWindowController" dark:YES];
}

+ (void)showNSColorHUDWindow {
    [[ToolBox sharedToolBox] showWindowController: @"NSColorConstantsHUDWindowController"];

}

+ (void)showNSImageStandardImages {
    [[ToolBox sharedToolBox] showWindowController: @"NSImageStandardImages"];
}

+ (void)showGlyphMetricsImages {
    [[ToolBox sharedToolBox] showWindowController:@"glyphMetricsWindowController"];
}

+ (ToolBox*)sharedToolBox {
    if (!instance) {
        instance = [[ToolBox alloc] init];
    }
    return instance;
}



@end


@implementation NSColor (MyCategories)
- (NSColor *)inverted
{
    NSColor * original = [self colorUsingColorSpaceName:
                          NSCalibratedRGBColorSpace];
    return [NSColor colorWithCalibratedRed:(1.0 - [original redComponent])
                                     green:(1.0 - [original greenComponent])
                                      blue:(1.0 - [original blueComponent])
                                     alpha:[original alphaComponent]];
}
- (NSColor*) rgbColor {
    NSColor * original = [self colorUsingColorSpaceName:
                          NSCalibratedRGBColorSpace];
    return [NSColor colorWithCalibratedRed:[original redComponent]
                                     green:[original greenComponent]
                                      blue:[original blueComponent]
                                     alpha:[original alphaComponent]];
}
@end

#define ADD_COLOR_NAMED(name) \
do { \
[_colors addObject:[[NSColor name] rgbColor]];\
[_names addObject:[NSString stringWithUTF8String:#name]]; \
} while (0)


#define GET_COLOR_NAMED(name, name2) \
do {\
if ([name isEqualToString:[NSString stringWithUTF8String:#name2]]) { \
color = [NSColor name2]; \
} \
} while (0)


@interface NSColorConstantView : NSImageView
@property NSString * name;
@end

@implementation NSColorConstantView

- (void)drawRect:(NSRect)dirtyRect {
    NSColor * color;
    
    GET_COLOR_NAMED(_name, controlShadowColor);
    GET_COLOR_NAMED(_name, controlDarkShadowColor);
    GET_COLOR_NAMED(_name, controlColor);
    GET_COLOR_NAMED(_name, controlHighlightColor);
    GET_COLOR_NAMED(_name, controlLightHighlightColor);
    GET_COLOR_NAMED(_name, controlTextColor);
    GET_COLOR_NAMED(_name, controlBackgroundColor);
    GET_COLOR_NAMED(_name, selectedControlColor);
    GET_COLOR_NAMED(_name, secondarySelectedControlColor);
    GET_COLOR_NAMED(_name, selectedControlTextColor);
    GET_COLOR_NAMED(_name, disabledControlTextColor);
    GET_COLOR_NAMED(_name, textColor);
    GET_COLOR_NAMED(_name, textBackgroundColor);
    GET_COLOR_NAMED(_name, selectedTextColor);
    GET_COLOR_NAMED(_name, selectedTextBackgroundColor);
    GET_COLOR_NAMED(_name, gridColor);
    GET_COLOR_NAMED(_name, keyboardFocusIndicatorColor);
    GET_COLOR_NAMED(_name, windowBackgroundColor);
    GET_COLOR_NAMED(_name, underPageBackgroundColor);
    GET_COLOR_NAMED(_name, labelColor);
    GET_COLOR_NAMED(_name, secondaryLabelColor);
    GET_COLOR_NAMED(_name, tertiaryLabelColor);
    GET_COLOR_NAMED(_name, quaternaryLabelColor);
    GET_COLOR_NAMED(_name, scrollBarColor);
    GET_COLOR_NAMED(_name, knobColor);
    GET_COLOR_NAMED(_name, selectedKnobColor);
    GET_COLOR_NAMED(_name, windowFrameColor);
    GET_COLOR_NAMED(_name, windowFrameTextColor);
    GET_COLOR_NAMED(_name, selectedMenuItemColor);
    GET_COLOR_NAMED(_name, selectedMenuItemTextColor);
    GET_COLOR_NAMED(_name, highlightColor);
    GET_COLOR_NAMED(_name, shadowColor);
    GET_COLOR_NAMED(_name, headerColor);
    GET_COLOR_NAMED(_name, headerTextColor);
    GET_COLOR_NAMED(_name, alternateSelectedControlColor);
    GET_COLOR_NAMED(_name, alternateSelectedControlTextColor);
    GET_COLOR_NAMED(_name, scrubberTexturedBackgroundColor);
    
    NSBezierPath * path = [NSBezierPath bezierPathWithRect:self.bounds];
    [color setFill];
    [path fill];
}

@end


@interface NSColorConstantsViewController : NSViewController<NSCollectionViewDataSource>
{
    NSMutableArray<NSColor*>  * _colors;
    NSMutableArray<NSString*> * _names;
    __weak IBOutlet NSCollectionView *_collectionView;
}
@end

@implementation NSColorConstantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _colors = [[NSMutableArray<NSColor*> alloc] init];
    _names = [[NSMutableArray<NSString*> alloc] init];
    
    ADD_COLOR_NAMED(controlShadowColor);
    ADD_COLOR_NAMED(controlDarkShadowColor);
    ADD_COLOR_NAMED(controlColor);
    ADD_COLOR_NAMED(controlHighlightColor);
    ADD_COLOR_NAMED(controlLightHighlightColor);
    ADD_COLOR_NAMED(controlTextColor);
    ADD_COLOR_NAMED(controlBackgroundColor);
    ADD_COLOR_NAMED(selectedControlColor);
    ADD_COLOR_NAMED(secondarySelectedControlColor);
    ADD_COLOR_NAMED(selectedControlTextColor);
    ADD_COLOR_NAMED(disabledControlTextColor);
    ADD_COLOR_NAMED(textColor);
    ADD_COLOR_NAMED(textBackgroundColor);
    ADD_COLOR_NAMED(selectedTextColor);
    ADD_COLOR_NAMED(selectedTextBackgroundColor);
    ADD_COLOR_NAMED(gridColor);
    ADD_COLOR_NAMED(keyboardFocusIndicatorColor);
    ADD_COLOR_NAMED(windowBackgroundColor);
    ADD_COLOR_NAMED(underPageBackgroundColor);
    ADD_COLOR_NAMED(labelColor);
    ADD_COLOR_NAMED(secondaryLabelColor);
    ADD_COLOR_NAMED(tertiaryLabelColor);
    ADD_COLOR_NAMED(quaternaryLabelColor);
    ADD_COLOR_NAMED(scrollBarColor);
    ADD_COLOR_NAMED(knobColor);
    ADD_COLOR_NAMED(selectedKnobColor);
    ADD_COLOR_NAMED(windowFrameColor);
    ADD_COLOR_NAMED(windowFrameTextColor);
    ADD_COLOR_NAMED(selectedMenuItemColor);
    ADD_COLOR_NAMED(selectedMenuItemTextColor);
    ADD_COLOR_NAMED(highlightColor);
    ADD_COLOR_NAMED(shadowColor);
    ADD_COLOR_NAMED(headerColor);
    ADD_COLOR_NAMED(headerTextColor);
    ADD_COLOR_NAMED(alternateSelectedControlColor);      
    ADD_COLOR_NAMED(alternateSelectedControlTextColor);
    ADD_COLOR_NAMED(scrubberTexturedBackgroundColor);
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _colors.count;
}

- (NSCollectionViewItem*)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSCollectionViewItem* item = [collectionView makeItemWithIdentifier:@"TBColorConstantsViewItem" forIndexPath:indexPath];
    NSUInteger index = indexPath.item;
    item.textField.stringValue = [_names objectAtIndex:index];
    NSColorConstantView * view = (NSColorConstantView*)item.imageView;
    view.name = [_names objectAtIndex:index];
    //item.imageView.layer.backgroundColor = [[_colors objectAtIndex:index] CGColor];
    item.textField.stringValue = [_names objectAtIndex:index];
    item.textField.drawsBackground = YES;
    item.textField.textColor = [NSColor whiteColor];
    item.textField.backgroundColor = [NSColor darkGrayColor];
    return item;
}

@end



#define ADD_NSIMAGE_STANDARD_NAME(name) \
do { \
[_constants addObject:name];\
[_names addObject:[NSString stringWithUTF8String:#name]]; \
} while (0)

@interface NSImageStandardNamesViewController : NSViewController<NSCollectionViewDataSource>
{
    
    NSMutableArray<NSString*>  * _names;
    NSMutableArray<NSString*> * _constants;
}
@end

@implementation NSImageStandardNamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _names = [[NSMutableArray<NSString*> alloc] init];
    _constants = [[NSMutableArray<NSString*> alloc] init];

    ADD_NSIMAGE_STANDARD_NAME(NSImageNameQuickLookTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameBluetoothTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameIChatTheaterTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameSlideshowTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameActionTemplate );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameSmartBadgeTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameIconViewTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameListViewTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameColumnViewTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameFlowViewTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNamePathTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameInvalidDataFreestandingTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameLockLockedTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameLockUnlockedTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameGoForwardTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameGoBackTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameGoRightTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameGoLeftTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameRightFacingTriangleTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameLeftFacingTriangleTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameAddTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameRemoveTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameRevealFreestandingTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameFollowLinkFreestandingTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameEnterFullScreenTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameExitFullScreenTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameStopProgressTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameStopProgressFreestandingTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameRefreshTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameRefreshFreestandingTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameBonjour);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameComputer);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameFolderBurnable);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameFolderSmart);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameFolder );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameNetwork);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameDotMac);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameMobileMe );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameMultipleDocuments);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameUserAccounts);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNamePreferencesGeneral);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameAdvanced);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameInfo);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameFontPanel);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameColorPanel);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameUser);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameUserGroup);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameEveryone  );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameUserGuest );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameMenuOnStateTemplate );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameMenuMixedStateTemplate );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameApplicationIcon );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTrashEmpty );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTrashFull );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameHomeTemplate );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameBookmarksTemplate );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameCaution );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameStatusAvailable );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameStatusPartiallyAvailable );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameStatusUnavailable );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameStatusNone );
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameShareTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarAddDetailTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarAddTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarAlarmTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarAudioInputMuteTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarAudioInputTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarAudioOutputMuteTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarAudioOutputVolumeHighTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarAudioOutputVolumeLowTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarAudioOutputVolumeMediumTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarAudioOutputVolumeOffTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarBookmarksTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarColorPickerFill);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarColorPickerFont);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarColorPickerStroke);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarCommunicationAudioTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarCommunicationVideoTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarComposeTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarDeleteTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarDownloadTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarEnterFullScreenTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarExitFullScreenTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarFastForwardTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarFolderCopyToTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarFolderMoveToTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarFolderTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarGetInfoTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarGoBackTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarGoDownTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarGoForwardTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarGoUpTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarHistoryTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarIconViewTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarListViewTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarMailTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarNewFolderTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarNewMessageTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarOpenInBrowserTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarPauseTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarPlayheadTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarPlayPauseTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarPlayTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarQuickLookTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarRecordStartTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarRecordStopTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarRefreshTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarRewindTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarRotateLeftTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarRotateRightTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarSearchTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarShareTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarSidebarTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarSkipAhead15SecondsTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarSkipAhead30SecondsTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarSkipAheadTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarSkipBack15SecondsTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarSkipBack30SecondsTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarSkipBackTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarSkipToEndTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarSkipToStartTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarSlideshowTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarTagIconTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarTextBoldTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarTextBoxTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarTextCenterAlignTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarTextItalicTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarTextJustifiedAlignTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarTextLeftAlignTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarTextListTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarTextRightAlignTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarTextStrikethroughTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarTextUnderlineTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarUserAddTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarUserGroupTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarUserTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarVolumeDownTemplate);
    ADD_NSIMAGE_STANDARD_NAME(NSImageNameTouchBarVolumeUpTemplate);

}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _names.count;
}

- (NSCollectionViewItem*)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSCollectionViewItem* item = [collectionView makeItemWithIdentifier:@"StandardCollectionViewItem" forIndexPath:indexPath];
    NSUInteger index = indexPath.item;
    item.textField.stringValue = [_names objectAtIndex:index];
    item.imageView.image = [NSImage imageNamed:[_constants objectAtIndex:index]];
    return item;
}

@end

@interface GlyphMetircsViewController : NSViewController
@end
@implementation GlyphMetircsViewController
- (IBAction)doOpenWebpage:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.freetype.org/freetype2/docs/glyphs/glyphs-3.html#section-1"]];
}

@end
