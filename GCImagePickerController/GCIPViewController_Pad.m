//
//  GCIPViewController_Pad.m
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "GCIPViewController_Pad.h"
#import "GCImagePickerController.h"
#import "GCIPAssetPickerController.h"

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

#pragma mark - group picker delegate

- (void)groupPicker:(GCIPGroupPickerController *)picker didSelectGroup:(ALAssetsGroup *)group {
    _assetPickerController.groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
}

@end
