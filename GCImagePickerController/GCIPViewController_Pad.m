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

#import <AssetsLibrary/AssetsLibrary.h>

#import "GCIPViewController_Pad.h"
#import "GCImagePickerController.h"
#import "GCIPAssetPickerController.h"

static int GCIPGroupPickerControllerGroupsContext = 0;

@implementation GCIPViewController_Pad {
    GCIPAssetPickerController *_assetPickerController;
    GCIPGroupPickerController *_groupPickerController;
}

#pragma mark - object methods

- (id)init {
    self = [super init];
    if (self) {
        
        // create group picker controller
        _groupPickerController = [[GCIPGroupPickerController alloc] init];
        _groupPickerController.clearsSelectionOnViewWillAppear = NO;
        _groupPickerController.showDisclosureIndicators = NO;
        _groupPickerController.delegate = self;
        [_groupPickerController
         addObserver:self
         forKeyPath:@"groups"
         options:0
         context:&GCIPGroupPickerControllerGroupsContext];
        self.title = _groupPickerController.title;
        [self addChildViewController:_groupPickerController];
        [_groupPickerController didMoveToParentViewController:self];
        
        // create asset picker
        _assetPickerController = [[GCIPAssetPickerController alloc] init];
        [self addChildViewController:_assetPickerController];
        [_assetPickerController didMoveToParentViewController:self];
        
    }
    return self;
}

- (void)dealloc {
    [_groupPickerController
     removeObserver:self
     forKeyPath:@"groups"
     context:&GCIPGroupPickerControllerGroupsContext];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    UIViewController *parent = self.parentViewController;
    if ([parent respondsToSelector:selector]) {
        return parent;
    }
    else { return nil; }
}

- (void)reloadAssets {
    [self.childViewControllers makeObjectsPerformSelector:@selector(reloadAssets)];
}

- (UINavigationItem *)navigationItem {
    return _assetPickerController.navigationItem;
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self
    self.view.backgroundColor = [UIColor blackColor];
    
    // placeholder
    UIView *view;
    
    // group picker
    view = _groupPickerController.view;
    view.frame = CGRectMake(0.0, 0.0, 320.0, self.view.bounds.size.height);
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:view];
    
    // asset picker
    view = _assetPickerController.view;
    view.frame = CGRectMake(321.0, 0.0, self.view.bounds.size.width - 321.0, self.view.bounds.size.height);
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:view];
    
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &GCIPGroupPickerControllerGroupsContext) {
        if (!_assetPickerController.groupIdentifier && [_groupPickerController.groups count] > 0) {
            ALAssetsGroup *group = [_groupPickerController.groups objectAtIndex:0];
            [self groupPicker:_groupPickerController didSelectGroup:group];
            [_groupPickerController.tableView reloadData];
            [_groupPickerController.tableView
             selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
             animated:NO
             scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

#pragma mark - group picker delegate

- (void)groupPicker:(GCIPGroupPickerController *)picker didSelectGroup:(ALAssetsGroup *)group {
    NSString *identifier = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
    _assetPickerController.groupIdentifier = identifier;
}

@end
