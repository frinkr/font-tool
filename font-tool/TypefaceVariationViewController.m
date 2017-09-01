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

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self.namedVariantsCombobox reloadData];
    
    TypefaceVariation * current = self.typeface.currentVariation;
    for (NSUInteger i = 0; i < self.typeface.namedVariations.count; ++ i) {
        TypefaceNamedVariation * variation = [self.typeface.namedVariations objectAtIndex:i];
        if ([variation isEqualTo:current]) {
            [self.namedVariantsCombobox selectItemAtIndex:i+1];
            break;
        }
    }
    
    if ([self.namedVariantsCombobox indexOfSelectedItem] == NSNotFound) {
        [self.namedVariantsCombobox selectItemAtIndex:0];
    }
}


- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    return self.typeface.namedVariations.count + 1;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    if (index == 0)
        return @"<CURRENT>";
    return [self.typeface.namedVariations objectAtIndex:index - 1].name;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    NSInteger index = self.namedVariantsCombobox.indexOfSelectedItem;
    
    if (index != 0) {
        TypefaceVariation * variation = [self.typeface.namedVariations objectAtIndex:index - 1];
        [self.typeface selectVariation:variation];
    }
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
