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

@interface GCIPAssetPickerController ()
@property (nonatomic, copy) NSArray *allAssets;
@property (nonatomic, retain) NSMutableSet *selectedAssetURLs;
@property (nonatomic, retain) ALAssetsGroup *group;
- (void)updateTitle;
- (void)cancel;
@end

@implementation GCIPAssetPickerController

#pragma mark - object methods

@synthesize groupIdentifier = __groupIdentifier;
@synthesize selectedAssetURLs = __selectedAssets;
@synthesize allAssets = __allAssets;
@synthesize group = __group;

- (id)initWithNibName:(NSString *)nib bundle:(NSBundle *)bundle {
    self = [super initWithNibName:nib bundle:bundle];
    if (self) {
        self.selectedAssetURLs = [NSMutableSet set];
        self.groupIdentifier = nil;
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
    self.tableView.contentOffset = CGPointMake(0.0, -4.0);
    [self.tableView flashScrollIndicators];
}
- (void)reloadAssets {
    
    // no group
    if (self.groupIdentifier == nil) {
        self.allAssets = nil;
        self.group = nil;
    }
    
    // view is loaded
    else if ([self isViewLoaded]) {
        
        // collect variables
        ALAssetsLibrary *library = [self.parentViewController performSelector:@selector(assetsLibrary)];
        ALAssetsFilter *filter = [self.parentViewController performSelector:@selector(assetsFilter)];
        ALAssetsGroup *group = nil;
        NSError *error = nil;
        
        // get assets
        self.allAssets = [library
                          assetsInGroupWithIdentifier:self.groupIdentifier
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
    self.navigationItem.leftBarButtonItem = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                   target:self
                                                   action:@selector(done)]
                                                  autorelease];
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
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
    [tap release];
    
    // reload
    [self reloadAssets];
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    self.allAssets = nil;
}

#pragma mark - button actions
- (void)action {
    GCImagePickerControllerActionBlock block = [self.parentViewController performSelector:@selector(actionBlock)];
    if (block) { block([[self.selectedAssetURLs copy] autorelease]); }
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)ceilf((float)[self.allAssets count] / 4.0);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CellIdentifier";
    GCIPAssetGridCell *cell = (GCIPAssetGridCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[GCIPAssetGridCell alloc] initWithStyle:0 reuseIdentifier:identifier] autorelease];
        cell.numberOfColumns = 4;
    }
    NSUInteger start = indexPath.row * 4;
    NSUInteger length = MIN([self.allAssets count] - start, 4);
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
        NSUInteger column = location.x / (self.tableView.bounds.size.width / 4);
        NSUInteger index = indexPath.row * 4 + column;
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
            if ([self.selectedAssetURLs count] == 0) {
                [self cancel];
            }
            else {
                NSString *title = [self.parentViewController performSelector:@selector(actionTitle)];
                UIBarButtonItem *item = [[[UIBarButtonItem alloc]
                                          initWithTitle:title
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
                [self updateTitle];
                NSArray *paths = [NSArray arrayWithObject:indexPath];
                [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
            }
            
        }
    }
}

@end
