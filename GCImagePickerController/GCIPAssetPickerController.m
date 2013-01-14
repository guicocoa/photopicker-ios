//
//  GCIPAssetPickerController.m
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

#import "GCIPAssetPickerController.h"
#import "GCIPAssetGridCell.h"
#import "GCImagePickerController.h"
#import "GCIPAssetView.h"

#import "ALAssetsLibrary+GCImagePickerControllerAdditions.h"

#import "GCImagePickerAppearenceDelegate.h"

@implementation GCIPAssetPickerController {
    NSMutableSet *_selectedAssetURLs;
    ALAssetsGroup *_group;
    NSArray *_assets;
    BOOL _needsFirstLoad;
}

#pragma mark - object methods

- (id)init {
    self = [super init];
    if (self) {
        self.title = [GCImagePickerController localizedString:@"PHOTO_LIBRARY"];
        self.groupURL = nil;
        _selectedAssetURLs = [NSMutableSet set];
        _needsFirstLoad = YES;
    }
    return self;
}

- (void)setGroupURL:(NSURL *)URL {
    if ([URL isEqual:_groupURL]) { return; }
    _groupURL = [URL copy];
    [self cancel];
    [self reloadAssets];
    self.tableView.contentOffset = CGPointMake(0.0, -4.0);
    [self.tableView flashScrollIndicators];
}

- (void)reloadAssets {
    
    // no group
    if (self.groupURL == nil) {
        _assets = nil;
        _group = nil;
    }
    
    // view is loaded
    else if ([self isViewLoaded]) {
        ALAssetsLibrary *library = [self.parentViewController performSelector:@selector(assetsLibrary)];
        ALAssetsFilter *filter = [self.parentViewController performSelector:@selector(assetsFilter)];
        [library
         gcip_assetsInGroupGroupWithURL:self.groupURL
         assetsFilter:filter
         completion:^(ALAssetsGroup *group, NSArray *assets) {
             
             // save ivars
             _group = group;
             _assets = assets;
             [self updateTitle];
             [self.tableView reloadData];
             self.tableView.hidden = ([_assets count] == 0);
             
             // scroll to bottom if this is camera roll and and we have rows we haven't done that yet
             if ([[_group valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue] == ALAssetsGroupSavedPhotos && _needsFirstLoad) {
                 NSInteger rows = [self numberOfRowsInGridView];
                 if (rows > 0) {
                     _needsFirstLoad = NO;
                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(rows - 1) inSection:0];
                     [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                 }
             }
             
         }
         failure:^(NSError *error) {
             [GCImagePickerController failedToLoadAssetsWithError:error];
         }];
    }
    
}

- (void)updateTitle {
    NSUInteger count = [_selectedAssetURLs count];
    if (count == 1) {
        self.title = [GCImagePickerController localizedString:@"PHOTO_COUNT_SINGLE"];
    }
    else if (count > 1) {
        self.title = [NSString stringWithFormat:
                      [GCImagePickerController localizedString:@"PHOTO_COUNT_MULTIPLE"],
                      [NSNumberFormatter localizedStringFromNumber:@(count) numberStyle:NSNumberFormatterDecimalStyle]];
    }
    else if (_group) {
        self.title = [_group valueForProperty:ALAssetsGroupPropertyName];
    }
}

- (void)done {
    GCImagePickerControllerDidFinishBlock block = [self.parentViewController performSelector:@selector(finishBlock)];
    if (block) { block(); }
    else { [self dismissViewControllerAnimated:YES completion:nil]; }
}

- (void)cancel {
    _selectedAssetURLs = [NSMutableSet set];
    [self showBackButton];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(done)];
    }
    else { self.navigationItem.rightBarButtonItem = nil; }
    [self.tableView reloadData];
    [self updateTitle];
}

- (NSInteger)numberOfRowsInGridView {
    return (NSInteger)ceilf((float)[_assets count] / 4.0);
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    
    // super
    [super viewDidLoad];
    
    [_selectedAssetURLs unionSet:[self.parentViewController performSelector:@selector(selectedPhotoUrls)]];
    
    // table view
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 109.0 : 79.0;
    self.tableView.contentInset = UIEdgeInsetsMake(4.0, 0.0, 0.0, 0.0);
    
    // gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tableDidReceiveTap:)];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [self.tableView addGestureRecognizer:tap];
    
    // reload
    [self reloadAssets];
    
    [self showBackButton];
}

- (void)didReceiveMemoryWarning {
    if (![self isViewLoaded]) {
        _assets = nil;
        _group = nil;
    }
    [super didReceiveMemoryWarning];
}

#pragma mark - button actions

- (void)action {
    GCImagePickerControllerSelectedItemsBlock block = [self.parentViewController performSelector:@selector(selectedItemsBlock)];
    if (block) { block([_selectedAssetURLs copy]); }
    [self cancel];
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsInGridView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"Cell";
    GCIPAssetGridCell *cell = (GCIPAssetGridCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[GCIPAssetGridCell alloc] initWithStyle:0 reuseIdentifier:identifier];
        cell.numberOfColumns = 4;
    }
    NSUInteger start = indexPath.row * 4;
    NSUInteger length = MIN([_assets count] - start, 4);
    NSRange range = NSMakeRange(start, length);
    [cell
     setAssets:[_assets subarrayWithRange:range]
     selected:_selectedAssetURLs];
    return cell;
}

#pragma mark - gestures

- (void)tableDidReceiveTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        
        // calculate stuff
        CGPoint location = [gesture locationInView:gesture.view];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        if (indexPath == nil) { return; }
        NSUInteger column = location.x / (self.tableView.bounds.size.width / 4);
        NSUInteger index = indexPath.row * 4 + column;
        
        // bounds check
        if (index >= [_assets count]) { return; }
        
        // get asset stuff
        ALAsset *asset = [_assets objectAtIndex:index];
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSURL *defaultURL = [representation url];
        if (defaultURL == nil) { return; }
        
        // check if multiple selection is allowed
        BOOL allowsMultipleSelection = (BOOL)[self.parentViewController performSelector:@selector(allowsMultipleSelection)];
        if (!allowsMultipleSelection) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            dispatch_async(dispatch_get_main_queue(), ^{
                GCIPAssetGridCell *cell = (id)[self.tableView cellForRowAtIndexPath:indexPath];
                GCIPAssetView *assetView = [cell assetViewAtColumn:column];
                [assetView setHighlighted:YES];
                GCImagePickerControllerSelectedItemsBlock block = [self.parentViewController performSelector:@selector(selectedItemsBlock)];
                if (block) { block([NSSet setWithObject:defaultURL]); }
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            });
            return;
        }
        
        // modify set
        if ([_selectedAssetURLs containsObject:defaultURL]) {
            [_selectedAssetURLs removeObject:defaultURL];
        }
        else { [_selectedAssetURLs addObject:defaultURL]; }
        
        // check set count
        if ([_selectedAssetURLs count] == 0) { [self cancel]; }
        else {
            [self updateNavigationBarButton];
            [self updateTitle];
            NSArray *paths = [NSArray arrayWithObject:indexPath];
            [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }
}

#pragma mark - custom navigation bar items

- (void)updateNavigationBarButton {
    
    GCImagePickerController *imagePickerController = (GCImagePickerController *)self.parentViewController;
    
    if (imagePickerController.appearenceDelegate != nil &&
        [imagePickerController.appearenceDelegate respondsToSelector:@selector(assetPickerControllerDidSelectedPhoto:updateNavigationBarButtonWithCancelAction:doneAction:)] ) {
        
        [imagePickerController.appearenceDelegate assetPickerControllerDidSelectedPhoto:self
                                              updateNavigationBarButtonWithCancelAction:@selector(cancel)
                                                                             doneAction:@selector(action)];
    } else {
        NSString *title = [self.parentViewController performSelector:@selector(actionTitle)];
        UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                 initWithTitle:title
                                 style:UIBarButtonItemStyleDone
                                 target:self
                                 action:@selector(action)];
        self.navigationItem.rightBarButtonItem = item;
        item = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                target:self
                action:@selector(cancel)];
        item.style = UIBarButtonItemStyleBordered;
        self.navigationItem.leftBarButtonItem = item;
    }
}

- (void)showBackButton {
    GCImagePickerController *imagePickerController = (GCImagePickerController *)self.parentViewController;
    
    if (imagePickerController.appearenceDelegate != nil &&
        [imagePickerController.appearenceDelegate respondsToSelector:@selector(assetPickerController:leftBarButtonItemWithAction:)] ) {
        
        [imagePickerController.appearenceDelegate assetPickerController:self leftBarButtonItemWithAction:@selector(back)];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
