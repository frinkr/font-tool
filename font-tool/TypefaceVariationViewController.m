//
//  TypefaceVariationViewController.m
//  tx-master
//
//  Created by Yuqing Jiang on 8/31/17.
//
//

#import "TypefaceVariationViewController.h"
#import "TypefaceDocument.h"

@interface TypefaceVariationAxisViewController : NSViewController
@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSSlider *valueSlider;
@property (weak) IBOutlet NSTextField *valueTextField;
@property Fixed axisValue;

- (void)loadFromAxis:(TypefaceAxis*)axis;
@end

@implementation TypefaceVariationAxisViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addObserver:self forKeyPath:@"axisValue" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"axisValue"]) {
        self.valueSlider.floatValue = FixedToFloat(self.axisValue);
        self.valueTextField.floatValue = self.valueSlider.floatValue;
    }
}

- (void)loadFromAxis:(TypefaceAxis *)axis {
    [self loadView];
    
    self.nameLabel.stringValue = axis.name;
    self.valueSlider.minValue = FixedToFloat(axis.minValue);
    self.valueSlider.maxValue = FixedToFloat(axis.maxValue);
}

- (IBAction)onSliderValueChanged:(id)sender {
    self.valueTextField.floatValue = self.valueSlider.floatValue;
    self.axisValue = FloatToFixed(self.valueSlider.floatValue);
}

@end

@interface TypefaceVariationViewController ()
@property (weak) IBOutlet NSComboBox *namedVariantsCombobox;
@property (weak) IBOutlet NSStackView *axisesStackView;
@property (strong) TypefaceDocument * document;
@property (strong) NSPopover *popover;
@property (strong) NSMutableArray<TypefaceVariationAxisViewController*> * axisesViewControllers;
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
    
    // Load axixes
    self.axisesViewControllers = [[NSMutableArray<TypefaceVariationAxisViewController*> alloc] init];
    
    for (TypefaceAxis * axis in self.typeface.axises) {
        TypefaceVariationAxisViewController * vc = [[NSStoryboard storyboardWithName:@"TypefaceVariation" bundle:nil] instantiateControllerWithIdentifier:@"variationAxisViewController"];
        
        [vc loadFromAxis:axis];
        
        [vc addObserver:self forKeyPath:@"axisValue" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.axisesViewControllers addObject:vc];
        [self.axisesStackView addArrangedSubview:vc.view];
    }
    
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"axisValue"]) {
        [self.typeface selectVariation:[self variationFromSliders]];
    }
}

- (TypefaceVariation *)variationFromSliders {
    TypefaceVariation * varation = [[TypefaceVariation alloc] init];
    NSMutableArray<NSNumber*> * coords = [[NSMutableArray<NSNumber*> alloc] init];
    for (TypefaceVariationAxisViewController * vc in self.axisesViewControllers) {
        [coords addObject:@(vc.axisValue)];
    }
    varation.coordinates = coords;
    return varation;
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
        
        for (NSUInteger i = 0; i < variation.coordinates.count; ++ i) {
            TypefaceVariationAxisViewController * vc = [self.axisesViewControllers objectAtIndex:i];
            vc.axisValue = [variation.coordinates objectAtIndex:i].integerValue;
        }
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
        self.popover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
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
    TypefaceVariationViewController * vc = [[NSStoryboard storyboardWithName:@"TypefaceVariation" bundle:nil] instantiateControllerWithIdentifier:@"variationViewController"];
    [vc forceLoadView];
    return vc;
}


@end
