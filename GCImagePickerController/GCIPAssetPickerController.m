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

#import <MobileCoreServices/MobileCoreServices.h>

#import "GCIPAssetPickerController.h"
#import "GCIPAssetGridCell.h"
#import "GCImagePickerController.h"

#import "ALAssetsLibrary+GCImagePickerControllerAdditions.h"

@implementation GCIPAssetPickerController {
    NSMutableSet *_selectedAssetURLs;
    ALAssetsGroup *_group;
    NSArray *_assets;
}

#pragma mark - object methods

- (id)init {
    self = [super init];
    if (self) {
        _selectedAssetURLs = [NSMutableSet set];
        self.groupURL = nil;
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
             _group = group;
             _assets = assets;
             [self updateTitle];
             [self.tableView reloadData];
             self.tableView.hidden = ([_assets count] == 0);
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
                      count];
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
    self.navigationItem.leftBarButtonItem = nil;
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

#pragma mark - view lifecycle

- (void)viewDidLoad {
    
    // super
    [super viewDidLoad];
    
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
    GCImagePickerControllerActionBlock block = [self.parentViewController performSelector:@selector(actionBlock)];
    if (block) { block([_selectedAssetURLs copy]); }
    [self cancel];
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)ceilf((float)[_assets count] / 4.0);
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
    if (gesture.state == UIGestureRecognizerStateEnded && gesture.view == self.tableView) {
        CGPoint location = [gesture locationInView:gesture.view];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        if (indexPath == nil) { return; }
        NSUInteger column = location.x / (self.tableView.bounds.size.width / 4);
        NSUInteger index = indexPath.row * 4 + column;
        if (index < [_assets count]) {
            
            // get asset stuff
            ALAsset *asset = [_assets objectAtIndex:index];
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            NSURL *defaultURL = [representation url];
            if (defaultURL == nil) { return; }
            
            // modify set
            if ([_selectedAssetURLs containsObject:defaultURL]) {
                [_selectedAssetURLs removeObject:defaultURL];
            }
            else { [_selectedAssetURLs addObject:defaultURL]; }
            
            // check set count
            if ([_selectedAssetURLs count] == 0) { [self cancel]; }
            else {
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
                [self updateTitle];
                NSArray *paths = [NSArray arrayWithObject:indexPath];
                [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
            }
            
        }
    }
}

@end
