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
#import "GCIPAssetPickerController.h"

@interface GCIPViewController_Pad ()
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, copy) NSArray *childViewControllers;
@property (nonatomic, retain) GCIPAssetPickerController *assetPickerController;
@property (nonatomic, retain) GCIPGroupPickerController *groupPickerController;
@end

@interface GCIPViewController_Pad (private)

// class methods
+ (void)dismissPopover:(UIPopoverController *)popover animated:(BOOL)animated;

// object methods
- (void)layoutViews;
- (void)layoutViewsForOrientation:(UIInterfaceOrientation)orientation;
- (void)updateToolbarItems;
- (void)updateToolbarItemsForOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation GCIPViewController_Pad (private)
+ (void)dismissPopover:(UIPopoverController *)popover animated:(BOOL)animated {
    [popover dismissPopoverAnimated:animated];
    [popover.delegate popoverControllerDidDismissPopover:popover];
}
- (void)layoutViews {
    [self layoutViewsForOrientation:self.interfaceOrientation];
}
- (void)layoutViewsForOrientation:(UIInterfaceOrientation)orientation {
    UIViewController *left = [self.childViewControllers objectAtIndex:0];
    UIViewController *right = [self.childViewControllers objectAtIndex:1];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        left.view.frame = CGRectMake(-320.0, 0, 320.0, self.view.bounds.size.height);
        self.toolbar.frame = CGRectMake(0.0, 0.0,
                                        self.view.bounds.size.width,
                                        self.toolbar.bounds.size.height);
        right.view.frame = CGRectMake(0.0, self.toolbar.bounds.size.height,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height - self.toolbar.bounds.size.height);
    }
    else {
        CGFloat width = self.view.bounds.size.width - 321.0;
        left.view.frame = CGRectMake(0.0, 0.0, 320.0, self.view.bounds.size.height);
        self.toolbar.frame = CGRectMake(321.0, 0.0, width, self.toolbar.bounds.size.height);
        right.view.frame = CGRectMake(self.toolbar.frame.origin.x,
                                      self.toolbar.bounds.size.height,
                                      self.toolbar.bounds.size.width,
                                      self.view.bounds.size.height - self.toolbar.bounds.size.height);
    }
}
- (void)updateToolbarItems {
    [self updateToolbarItemsForOrientation:self.interfaceOrientation];
}
- (void)updateToolbarItemsForOrientation:(UIInterfaceOrientation)orientation {
    
    // setup items
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:4];
    
    // if we are in portrait mode...
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        
        // ...add popover button
        UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                 initWithTitle:[[self.childViewControllers objectAtIndex:0] title]
                                 style:UIBarButtonItemStyleBordered 
                                 target:self
                                 action:@selector(popover:)];
        [items addObject:item];
        [item release];
        
    }
    
    // space
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                              target:nil 
                              action:nil];
    [items addObject:space];
    [space release];
    
    // left nav button
    if (self.assetPickerController.navigationItem.leftBarButtonItem) {
        [items addObject:self.assetPickerController.navigationItem.leftBarButtonItem];
    }
    
    // right nav button
    if (self.assetPickerController.navigationItem.rightBarButtonItem) {
        [items addObject:self.assetPickerController.navigationItem.rightBarButtonItem];
    }
    else {
        
        // done button
        UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:self
                                 action:@selector(done)];
        [items addObject:item];
        [item release];
        
    }
    
    // set items
    self.toolbar.items = items;
    [items release];
    
}
@end

@implementation GCIPViewController_Pad

// local properties
@synthesize toolbar                 = __toolbar;
@synthesize popover                 = __popover;
@synthesize childViewControllers    = __childViewControllers;
@synthesize assetPickerController   = __assetPickerController;
@synthesize groupPickerController   = __groupPickerController;

#pragma mark - object methods
- (id)initWithImagePickerController:(GCImagePickerController *)controller {
    self = [super initWithImagePickerController:controller];
    if (self) {
        
        // create group picker controller
        GCIPGroupPickerController *groupPicker = [[GCIPGroupPickerController alloc] initWithImagePickerController:controller];
        [groupPicker
         addObserver:self
         forKeyPath:@"groups"
         options:0
         context:0];
        groupPicker.groupPickerDelegate = self;
        groupPicker.showDisclosureIndicators = NO;
        self.groupPickerController = groupPicker;
        [groupPicker release];
        
        // create asset picker
        GCIPAssetPickerController *assetPicker = [[GCIPAssetPickerController alloc] initWithImagePickerController:controller];
        [assetPicker
         addObserver:self
         forKeyPath:@"navigationItem.leftBarButtonItem"
         options:0
         context:0];
        [assetPicker
         addObserver:self
         forKeyPath:@"navigationItem.rightBarButtonItem"
         options:0
         context:0];
        self.assetPickerController = assetPicker;
        [assetPicker release];
        
        // set parent controllers
        @try {
            [groupPicker setValue:self forKey:@"parentViewController"];
            [assetPicker setValue:self forKey:@"parentViewController"];
        }
        @catch (NSException *exception) {
            GC_LOG_ERROR(@"unable to set parent view controller\n%@", exception);
        }
        
        // save child controllers
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.groupPickerController];
        self.childViewControllers = [NSArray arrayWithObjects:nav, self.assetPickerController, nil];
        [nav release];
        
    }
    return self;
}
- (void)dealloc {
    
    // clear properties
    self.toolbar = nil;
    
    // dismiss popover
    [GCIPViewController_Pad dismissPopover:self.popover animated:NO];
    
    // clear view controllers
    self.childViewControllers = nil;
    [self.assetPickerController
     removeObserver:self
     forKeyPath:@"navigationItem.rightBarButtonItem"];
    [self.assetPickerController
     removeObserver:self
     forKeyPath:@"navigationItem.leftBarButtonItem"];
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

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // toolbar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:toolbar];
    [toolbar sizeToFit];
    self.toolbar = toolbar;
    [toolbar release];
    
    // views
    self.view.backgroundColor = [UIColor blackColor];
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.view addSubview:[(UIViewController *)obj view]];
    }];
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    self.toolbar = nil;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIViewController *)obj viewWillAppear:animated];
    }];
    [self layoutViews];
    [self updateToolbarItems];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIViewController *)obj viewDidAppear:animated];
    }];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIViewController *)obj viewWillDisappear:animated];
    }];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIViewController *)obj viewDidDisappear:animated];
    }];
}

#pragma mark - view rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return GC_SHOULD_ALLOW_ORIENTATION(orientation);
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIViewController *)obj willRotateToInterfaceOrientation:orientation duration:duration];
    }];
    if (UIInterfaceOrientationIsPortrait(orientation) == UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return;
    }
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [GCIPViewController_Pad dismissPopover:self.popover animated:NO];
    }
    [self updateToolbarItemsForOrientation:orientation];
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIViewController *)obj willAnimateRotationToInterfaceOrientation:orientation duration:duration];
    }];
    [self layoutViewsForOrientation:orientation];
}
- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIViewController *)obj willAnimateFirstHalfOfRotationToInterfaceOrientation:orientation duration:duration];
    }];
}
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIViewController *)obj willAnimateSecondHalfOfRotationFromInterfaceOrientation:orientation duration:duration];
    }];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIViewController *)obj didRotateFromInterfaceOrientation:orientation];
    }];
}

#pragma mark - button actions
- (void)popover:(UIBarButtonItem *)sender {
    if (!self.popover) {
        UIViewController *controller = [self.childViewControllers objectAtIndex:0];
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        popover.delegate = self;
        [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.popover = popover;
        [popover release];
    }
}
- (void)done {
    [GCIPViewController_Pad dismissPopover:self.popover animated:NO];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // left button
    if (object == self.assetPickerController && [keyPath isEqualToString:@"navigationItem.rightBarButtonItem"]) {
        [self updateToolbarItems];
    }
    
    // right button
    else if (object == self.assetPickerController && [keyPath isEqualToString:@"navigationItem.leftBarButtonItem"]) {
        [self updateToolbarItems];
    }
    
    // groups
    else if (object == self.groupPickerController && [keyPath isEqualToString:@"groups"]) {
        if (!self.assetPickerController.groupIdentifier && [self.groupPickerController.groups count]) {
            ALAssetsGroup *group = [self.groupPickerController.groups objectAtIndex:0];
            [self groupPicker:self.groupPickerController didSelectGroup:group];
        }
        else if (![self.groupPickerController.groups count]) {
            
        }
    }
    
}

#pragma mark - popover delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover {
    if (popover == self.popover) {
        self.popover = nil;
        UIViewController *controller = [self.childViewControllers objectAtIndex:0];
        [self.view addSubview:controller.view];
        [self layoutViews];
    }
}

#pragma mark - group picker delegate
- (void)groupPicker:(GCIPGroupPickerController *)groupPicker didSelectGroup:(ALAssetsGroup *)group {
    
    // get identifier
    NSString *identifier = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
    
    // set new identifier
    self.assetPickerController.groupIdentifier = identifier;
    
    // deselect cell
    NSIndexPath *indexPath = [groupPicker.tableView indexPathForSelectedRow];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [groupPicker.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        [GCIPViewController_Pad dismissPopover:self.popover animated:YES];
        [groupPicker.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
}

@end
