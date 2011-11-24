/*
 
 Copyright (C) 2011 GUI Cocoa, LLC.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "GCIPViewController_Pad.h"
#import "GCImagePickerController.h"
#import "GCIPAssetPickerController.h"

@interface GCIPViewController_Pad ()
@property (nonatomic, retain) GCIPAssetPickerController *assetPickerController;
@property (nonatomic, retain) GCIPGroupPickerController *groupPickerController;
@end

@implementation GCIPViewController_Pad

#pragma mark - object methods

@synthesize assetPickerController   = __assetPickerController;
@synthesize groupPickerController   = __groupPickerController;

- (id)initWithNibName:(NSString *)nib bundle:(NSBundle *)bundle {
    self = [super initWithNibName:nib bundle:bundle];
    if (self) {
        
        // create group picker controller
        GCIPGroupPickerController *groupPicker = [[GCIPGroupPickerController alloc] initWithNibName:nil bundle:nil];
        groupPicker.clearsSelectionOnViewWillAppear = NO;
        groupPicker.showDisclosureIndicators = NO;
        groupPicker.delegate = self;
        [groupPicker addObserver:self forKeyPath:@"groups" options:0 context:0];
        self.title = groupPicker.title;
        self.groupPickerController = groupPicker;
        [groupPicker release];
        
        // create asset picker
        GCIPAssetPickerController *assetPicker = [[GCIPAssetPickerController alloc] initWithNibName:nil bundle:nil];
        self.assetPickerController = assetPicker;
        [assetPicker release];
        
        // set parent controllers
        @try {
            [self.assetPickerController setValue:self forKey:@"parentViewController"];
            [self.groupPickerController setValue:self forKey:@"parentViewController"];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        
    }
    return self;
}
- (void)dealloc {
    
    // clear view controllers
    self.assetPickerController = nil;
    [self.groupPickerController
     removeObserver:self
     forKeyPath:@"groups"];
    self.groupPickerController = nil;
    
    // super
    [super dealloc];
    
}
- (void)reloadAssets {
    [self.groupPickerController reloadAssets];
    [self.assetPickerController reloadAssets];
}
- (UINavigationItem *)navigationItem {
    return self.assetPickerController.navigationItem;
}
- (void)setParent:(GCImagePickerController *)parent {
    [super setParent:parent];
    self.groupPickerController.parent = parent;
    self.assetPickerController.parent = parent;
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self
    self.view.backgroundColor = [UIColor blackColor];
    
    // placeholder
    UIView *view;
    
    // group picker
    view = self.groupPickerController.view;
    view.frame = CGRectMake(0.0, 0.0, 320.0, self.view.bounds.size.height);
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:view];
    
    // asset picker
    view = self.assetPickerController.view;
    view.frame = CGRectMake(321.0, 0.0, self.view.bounds.size.width - 321.0, self.view.bounds.size.height);
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:view];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.groupPickerController viewWillAppear:animated];
    [self.assetPickerController viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.groupPickerController viewDidAppear:animated];
    [self.assetPickerController viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.groupPickerController viewWillDisappear:animated];
    [self.assetPickerController viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.groupPickerController viewDidDisappear:animated];
    [self.assetPickerController viewDidDisappear:animated];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsLandscape(orientation);
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.groupPickerController && [keyPath isEqualToString:@"groups"]) {
        if (!self.assetPickerController.groupIdentifier && [self.groupPickerController.groups count]) {
            ALAssetsGroup *group = [self.groupPickerController.groups objectAtIndex:0];
            [self groupPicker:self.groupPickerController didSelectGroup:group];
            [self.groupPickerController.tableView reloadData];
            [self.groupPickerController.tableView
             selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
             animated:NO
             scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

#pragma mark - group picker delegate
- (void)groupPicker:(GCIPGroupPickerController *)picker didSelectGroup:(ALAssetsGroup *)group {
    NSString *identifier = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
    self.assetPickerController.groupIdentifier = identifier;
}

@end
