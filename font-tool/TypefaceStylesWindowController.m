//
//  TypefaceStylesWindowController.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/17/17.
//
//

#import "TypefaceStylesWindowController.h"
#import "Typeface.h"
#import "TypefaceManager.h"
@interface TypefaceStylesWindowController()
@end

@interface TypefaceStylesViewController ()
@property (assign) IBOutlet NSTableView *faceListView;
@property (assign) IBOutlet NSTextField *fontFileLabel;
@property (nonatomic, strong) NSArray<NSString*> * faces;
@end

@implementation TypefaceStylesWindowController

-(void)windowDidLoad {
    [super windowDidLoad];
}

+ (NSInteger)selectTypefaceOfFile:(NSURL *)url {
    NSArray<NSString*> * faces = [TypefaceStylesWindowController facesOfFontFile:url];
    if ([faces count] == 1)
        return 0;
    
    TypefaceStylesWindowController * wc =  [[NSStoryboard storyboardWithName:@"TypefaceStylesWindow" bundle:nil] instantiateInitialController];
    
    TypefaceStylesViewController * vc = (TypefaceStylesViewController*)wc.contentViewController;
    vc.faces = faces;
    vc.fontFileLabel.stringValue = url.path;
    return [NSApp runModalForWindow:wc.window];
}

+ (NSArray<NSString*> *)facesOfFontFile:(NSURL*)url {
    return [[TypefaceManager defaultManager] listFacesOfURL:url];
}

@end

@implementation TypefaceStylesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.faceListView setDoubleAction:@selector(confirmTypeFaceSelection:)];
}

- (void) setFaces:(NSArray<NSString *> *)faces {
    _faces = faces;
    [self.faceListView reloadData];
}

- (IBAction)cancelTypefaceSelection:(id)sender {
    [NSApp stopModalWithCode:-1];
}

- (IBAction)confirmTypeFaceSelection:(id)sender {
    [NSApp stopModalWithCode:self.faceListView.selectedRow];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.faces count];
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextField *textEdit = [tableView makeViewWithIdentifier:@"Face TextEdit" owner:self];
    
    // There is no existing cell to reuse so create a new one
    if (textEdit == nil) {
        
        // Create the new NSTextField with a frame of the {0,0} with the width of the table.
        // Note that the height of the frame is not really relevant, because the row height will modify the height.
        textEdit = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 50)];
        
        // The identifier of the NSTextField instance is set to MyView.
        // This allows the cell to be reused.
        textEdit.identifier = @"Face TextEdit";
        [textEdit setBezeled:NO];
        [textEdit setDrawsBackground:NO];
        [textEdit setEditable:NO];
        [textEdit setSelectable:NO];
    }
    
    textEdit.stringValue = [self.faces objectAtIndex:row];
    textEdit.drawsBackground = NO;
    return textEdit;
}

@end
