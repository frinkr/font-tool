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
