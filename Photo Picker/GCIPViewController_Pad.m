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

@synthesize assetPickerController = __assetPickerController;
@synthesize groupPickerController = __groupPickerController;

#pragma mark - object methods

- (id)initWithNibName:(NSString *)nib bundle:(NSBundle *)bundle {
    self = [super initWithNibName:nib bundle:bundle];
    if (self) {
        
        // create group picker controller
        GCIPGroupPickerController *groupPicker = [[[GCIPGroupPickerController alloc] initWithNibName:nil bundle:nil] autorelease];
        groupPicker.clearsSelectionOnViewWillAppear = NO;
        groupPicker.showDisclosureIndicators = NO;
        groupPicker.delegate = self;
        [groupPicker addObserver:self forKeyPath:@"groups" options:0 context:0];
        self.title = groupPicker.title;
        [self addChildViewController:groupPicker];
        [groupPicker didMoveToParentViewController:self];
        self.groupPickerController = groupPicker;
        
        // create asset picker
        GCIPAssetPickerController *assetPicker = [[[GCIPAssetPickerController alloc] initWithNibName:nil bundle:nil] autorelease];
        [self addChildViewController:assetPicker];
        [assetPicker didMoveToParentViewController:self];
        self.assetPickerController = assetPicker;
        
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

- (id)forwardingTargetForSelector:(SEL)selector {
    UIViewController *parent = self.parentViewController;
    if ([parent respondsToSelector:selector]) {
        return parent;
    }
    else {
        return nil;
    }
}

- (void)reloadAssets {
    [self.childViewControllers makeObjectsPerformSelector:@selector(reloadAssets)];
}

- (UINavigationItem *)navigationItem {
    return self.assetPickerController.navigationItem;
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
