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

@interface GCIPAssetPickerController ()
@property (nonatomic, copy) NSArray *allAssets;
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, retain) NSMutableSet *selectedAssetURLs;
@property (nonatomic, retain) ALAssetsGroup *group;
- (void)updateTitle;
- (void)cancel;
@end

@implementation GCIPAssetPickerController

#pragma mark - object methods

@synthesize groupIdentifier = __groupIdentifier;
@synthesize selectedAssetURLs = __selectedAssets;
@synthesize numberOfColumns = __numberOfColumns;
@synthesize allAssets = __allAssets;
@synthesize group = __group;

- (id)initWithNibName:(NSString *)nib bundle:(NSBundle *)bundle {
    self = [super initWithNibName:nib bundle:bundle];
    if (self) {
        self.numberOfColumns = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 5 : 4;
        self.selectedAssetURLs = [NSMutableSet set];
    }
    return self;
}
- (void)dealloc {
    self.groupIdentifier = nil;
    self.selectedAssetURLs = nil;
    self.allAssets = nil;
    self.group = nil;
    [super dealloc];
}
- (void)setGroupIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:__groupIdentifier]) {
        return;
    }
    [__groupIdentifier release];
    __groupIdentifier = [identifier copy];
    [self cancel];
    [self reloadAssets];
}
- (void)reloadAssets {
    
    // no group
    if (self.groupIdentifier == nil) {
        self.allAssets = nil;
        self.group = nil;
    }
    
    // view is loaded
    else if ([self isViewLoaded]) {
        
        // cache vars
        ALAssetsLibrary *library = self.parent.assetsLibrary;
        ALAssetsFilter *filter = self.parent.assetsFilter;
        ALAssetsGroup *group = nil;
        NSError *error = nil;
        
        // get assets
        self.allAssets = [GCImagePickerController
                          assetsInLibary:library
                          groupWithIdentifier:self.groupIdentifier
                          filter:filter
                          group:&group
                          error:&error];
        self.group = group;
        if (error) {
            [GCImagePickerController failedToLoadAssetsWithError:error];
        }
        
    }
    
    // refresh view
    [self updateTitle];
    [self.tableView reloadData];
    self.tableView.hidden = (![self.allAssets count]);
    
}
- (void)updateTitle {
    NSUInteger count = [self.selectedAssetURLs count];
    if (count == 1) {
        self.title = [GCImagePickerController localizedString:@"PHOTO_COUNT_SINGLE"];
    }
    else if (count > 1) {
        self.title = [NSString stringWithFormat:
                      [GCImagePickerController localizedString:@"PHOTO_COUNT_MULTIPLE"],
                      count];
    }
    else {
        self.title = [self.group valueForProperty:ALAssetsGroupPropertyName];
    }
}
- (void)done {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)cancel {
    self.selectedAssetURLs = [NSMutableSet set];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    [self.tableView reloadData];
    [self updateTitle];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    
    // super
    [super viewDidLoad];
    
    // table view
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 140.0 : 79.0;
    self.tableView.contentInset = UIEdgeInsetsMake(4.0, 0.0, 0.0, 0.0);
    self.tableView.contentOffset = CGPointMake(0.0, -4.0);
    
    // gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tableDidReceiveTap:)];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [self.tableView addGestureRecognizer:tap];
    [tap release];
    
    // reload
    [self reloadAssets];
    
    // scroll to bottom for certain albums
    NSNumber *type = [self.group valueForProperty:ALAssetsGroupPropertyType];
    if ([type unsignedIntegerValue] & ALAssetsGroupSavedPhotos ||
        [type unsignedIntegerValue] & ALAssetsGroupPhotoStream) {
        self.tableView.contentOffset = CGPointMake(0.0, self.tableView.contentSize.height);
    }
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    self.allAssets = nil;
}

#pragma mark - button actions
- (void)action {
    self.parent.actionBlock([[self.selectedAssetURLs copy] autorelease]);
    [self cancel];
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)ceilf((float)[self.allAssets count] / (float)self.numberOfColumns);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CellIdentifier";
    GCIPAssetGridCell *cell = (GCIPAssetGridCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[GCIPAssetGridCell alloc] initWithStyle:0 reuseIdentifier:identifier] autorelease];
    }
    cell.numberOfColumns = self.numberOfColumns;
    NSUInteger start = indexPath.row * self.numberOfColumns;
    NSUInteger length = MIN([self.allAssets count] - start, self.numberOfColumns);
    NSRange range = NSMakeRange(start, length);
    [cell
     setAssets:[self.allAssets subarrayWithRange:range]
     selected:self.selectedAssetURLs];
    return cell;
}

#pragma mark - gestures
- (void)tableDidReceiveTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded && gesture.view == self.tableView) {
        CGPoint location = [gesture locationInView:gesture.view];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        if (indexPath == nil) { return; }
        NSUInteger column = location.x / (self.tableView.bounds.size.width / self.numberOfColumns);
        NSUInteger index = indexPath.row * self.numberOfColumns + column;
        if (index < [self.allAssets count]) {
            
            // get asset stuff
            ALAsset *asset = [self.allAssets objectAtIndex:index];
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            NSURL *defaultURL = [representation url];
            if (defaultURL == nil) { return; }
            
            // modify set
            if ([self.selectedAssetURLs containsObject:defaultURL]) {
                [self.selectedAssetURLs removeObject:defaultURL];
            }
            else {
                [self.selectedAssetURLs addObject:defaultURL];
            }
            
            // check set count
            if ([self.selectedAssetURLs count]) {
                UIBarButtonItem *item = [[[UIBarButtonItem alloc]
                                          initWithTitle:self.parent.actionTitle
                                          style:UIBarButtonItemStyleDone
                                          target:self
                                          action:@selector(action)]
                                         autorelease];
                self.navigationItem.rightBarButtonItem = item;
                item = [[[UIBarButtonItem alloc]
                         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                         target:self
                         action:@selector(cancel)]
                        autorelease];
                item.style = UIBarButtonItemStyleBordered;
                self.navigationItem.leftBarButtonItem = item;
            }
            else {
                self.navigationItem.rightBarButtonItem = nil;
                self.navigationItem.leftBarButtonItem = nil;
            }
            
            // reload
            [self updateTitle];
            NSArray *paths = [NSArray arrayWithObject:indexPath];
            [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
            
        }
    }
}

@end
