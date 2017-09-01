//
//  TypefaceVariationViewController.m
//  tx-master
//
//  Created by Yuqing Jiang on 8/31/17.
//
//

#import "TypefaceVariationViewController.h"
#import "TypefaceDocument.h"

@interface TypefaceVariationViewController ()
@property (weak) IBOutlet NSComboBox *namedVariantsCombobox;
@property (strong) TypefaceDocument * document;
@property (strong) NSPopover *popover;
@end

@implementation TypefaceVariationViewController


- (void)forceLoadView {
    if (!self.view)
        [self loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    return self.typeface.namedVariations.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    return [self.typeface.namedVariations objectAtIndex:index].name;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    TypefaceVariation * variation = [self.typeface.namedVariations objectAtIndex:self.namedVariantsCombobox.indexOfSelectedItem];
    
    [self.typeface selectVariation:variation];
}

- (Typeface*)typeface {
    return self.document.typeface;
}

- (void)showPopoverRelativeToRect:(NSRect)rect
                           ofView:(NSView*)view
                    preferredEdge:(NSRectEdge)preferredEdge
                        withDocument:(TypefaceDocument*)document {
    
    if (!self.popover) {
        self.popover = [[NSPopover alloc] init];
        self.popover.contentViewController = self;
        self.popover.delegate = self;
        self.popover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        self.popover.behavior = NSPopoverBehaviorTransient;
    }
    
    self.document = document;
    
    [self.popover showRelativeToRect:rect
                              ofView:view
                       preferredEdge:preferredEdge];
}


- (void)popoverWillClose:(NSNotification *)notification {
    self.popover.contentViewController = nil;
    self.popover = nil;
}

+ (instancetype)createViewController {
    TypefaceVariationViewController * vc = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"variationViewController"];
    [vc forceLoadView];
    return vc;
}


@end
