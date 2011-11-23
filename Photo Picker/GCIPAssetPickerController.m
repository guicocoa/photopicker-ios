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

// clear with view
@property (nonatomic, copy) NSArray *allAssets;
@property (nonatomic, retain) NSMutableSet *selectedAssetURLs;
@property (nonatomic, retain) ALAssetsGroup *group;
@property (nonatomic, retain) UIActionSheet *sheet;

// clear normally
@property (nonatomic, assign) NSUInteger numberOfColumns;

// reload view title
- (void)updateTitle;

@end

@implementation GCIPAssetPickerController

@synthesize groupIdentifier     = __groupIdentifier;
@synthesize selectedAssetURLs   = __selectedAssets;
@synthesize numberOfColumns     = __numberOfColumns;
@synthesize allAssets           = __allAssets;
@synthesize group               = __group;
@synthesize sheet               = __sheet;

#pragma mark - object methods
- (id)initWithNibName:(NSString *)nib bundle:(NSBundle *)bundle {
    self = [super initWithNibName:nib bundle:bundle];
    if (self) {
        self.numberOfColumns = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 5 : 4;
    }
    return self;
}
- (void)dealloc {
    self.groupIdentifier = nil;
    self.selectedAssetURLs = nil;
    self.allAssets = nil;
    self.group = nil;
    self.sheet = nil;
    [super dealloc];
}
- (void)reloadAssets {
    
    // no group
    if (self.groupIdentifier == nil) {
        self.allAssets = nil;
        self.group = nil;
    }
    
    // if view loaded
    else if ([self isViewLoaded]) {
        ALAssetsGroup *group = nil;
        NSError *error = nil;
        ALAssetsLibrary *library = [self performSelectorInViewHierarchy:@selector(assetsLibrary)];
        ALAssetsFilter *filter = [self performSelectorInViewHierarchy:@selector(assetsFilter)];
        self.allAssets = [GCImagePickerController
                          assetsInLibary:library
                          groupWithIdentifier:self.groupIdentifier
                          filter:filter
                          group:&group
                          error:&error];
        if (error) {
            [GCImagePickerController failedToLoadAssetsWithError:error];
        }
        self.group = group;
    }
    
    // table visibility
    self.tableView.hidden = (![self.allAssets count]);
    
    // trigger a reload
    self.editing = NO;
    
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

#pragma mark - accessors
- (void)setGroupIdentifier:(NSString *)identifier {
    
    // make sure it isn't the same
    if ([identifier isEqualToString:__groupIdentifier]) {
        return;
    }
    
    // get new value
    [__groupIdentifier release];
    __groupIdentifier = [identifier copy];
    
    // reload assets
    [self reloadAssets];
    
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    
    // super
    [super viewDidLoad];
    
    // table view
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = (GC_IS_IPAD) ? 140.0 : 79.0;
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
    if ([type unsignedIntegerValue] & ALAssetsGroupSavedPhotos) {
        self.tableView.contentOffset = CGPointMake(0.0, self.tableView.contentSize.height);
    }
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    self.selectedAssetURLs = nil;
    self.allAssets = nil;
    self.group = nil;
    self.sheet = nil;
}

#pragma mark - button actions
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    // update model and buttons
    if (editing) {
        self.selectedAssetURLs = [NSMutableSet set];
        UIBarButtonItem *item = [[[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                  target:self
                                  action:@selector(action:)]
                                 autorelease];
        item.style = UIBarButtonItemStyleBordered;
        [self.navigationItem setRightBarButtonItem:item animated:animated];
        item = [[[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                 target:self
                 action:@selector(cancel)]
                autorelease];
        item.style = UIBarButtonItemStyleBordered;
        [self.navigationItem setLeftBarButtonItem:item animated:animated];
        
    }
    else {
        self.selectedAssetURLs = nil;
        UIBarButtonItem *item = nil;
        if (GC_IS_IPAD) {
            item = [[[UIBarButtonItem alloc]
                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                     target:self
                     action:@selector(done)]
                    autorelease];
        }
        [self.navigationItem setRightBarButtonItem:item animated:animated];
        [self.navigationItem setLeftBarButtonItem:nil animated:animated];
    }
    
    // reload stuff
    [self updateTitle];
    [self.tableView reloadData];
    
    // clear sheet
    if (self.sheet) {
        [self.sheet
         dismissWithClickedButtonIndex:self.sheet.cancelButtonIndex
         animated:animated];
        self.sheet = nil;
    }
    
}
- (void)action:(UIBarButtonItem *)sender {
    if (!self.sheet) {
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:nil
                                delegate:self
                                cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                otherButtonTitles:nil];
        NSString *title = [self performSelectorInViewHierarchy:@selector(actionTitle)];
        if (title && [self performSelectorInViewHierarchy:@selector(actionBlock)]) {
            [sheet addButtonWithTitle:title];
        }
        if ([self.selectedAssetURLs count] < 6 && [MFMailComposeViewController canSendMail]) {
            [sheet addButtonWithTitle:[GCImagePickerController localizedString:@"EMAIL"]];
        }
        if ([self.selectedAssetURLs count] < 6) {
            [sheet addButtonWithTitle:[GCImagePickerController localizedString:@"COPY"]];
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [sheet showFromBarButtonItem:sender animated:YES];
        }
        else {
            [sheet addButtonWithTitle:[GCImagePickerController localizedString:@"CANCEL"]];
            sheet.cancelButtonIndex = (sheet.numberOfButtons - 1);
            [sheet showInView:self.view];
        }
        self.sheet = sheet;
        [sheet release];
    }
}
- (void)cancel {
    self.editing = NO;
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
        NSUInteger column = location.x / (self.tableView.bounds.size.width / self.numberOfColumns);
        NSUInteger index = indexPath.row * self.numberOfColumns + column;
        if (index < [self.allAssets count]) {
            
            // get asset stuff
            ALAsset *asset = [self.allAssets objectAtIndex:index];
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            NSURL *defaultURL = [representation url];
            
            // enter select mode
            if (!self.editing) {
                self.editing = YES;
            }
            
            // modify set
            if ([self.selectedAssetURLs containsObject:defaultURL]) {
                [self.selectedAssetURLs removeObject:defaultURL];
            }
            else {
                [self.selectedAssetURLs addObject:defaultURL];
            }
            
            // check set count
            if ([self.selectedAssetURLs count]) {
                NSString *title = [self performSelectorInViewHierarchy:@selector(actionTitle)];
                id block = [self performSelectorInViewHierarchy:@selector(actionBlock)];
                BOOL action = (title && block);
                BOOL count = ([self.selectedAssetURLs count] < 6);
                self.navigationItem.rightBarButtonItem.enabled = (action || count);
            }
            else {
                self.editing = NO;
            }
            
            // reload
            [self updateTitle];
            NSArray *paths = [NSArray arrayWithObject:indexPath];
            [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
            
        }
    }
}

#pragma mark - mail compose
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result != MFMailComposeResultFailed && result != MFMailComposeResultCancelled) {
        self.editing = NO;
    }
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark - action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // release sheet
    self.sheet = nil;
    
    // cancel
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    // bounds check
    if (buttonIndex < 0 || buttonIndex >= actionSheet.numberOfButtons) {
        return;
    }
    
    // get resources
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    // copy
    if ([title isEqualToString:[GCImagePickerController localizedString:@"COPY"]]) {
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:[self.selectedAssetURLs count]];
        [self.selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            [[self performSelectorInViewHierarchy:@selector(assetsLibrary)]
             assetForURL:obj
             resultBlock:^(ALAsset *asset) {
                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                 UIImage *image = [[UIImage alloc] initWithCGImage:[rep fullScreenImage]];
                 [images addObject:image];
                 [image release];
             }
             failureBlock:^(NSError *error) {
                 NSLog(@"%@", error);
             }];
        }];
        [[UIPasteboard generalPasteboard] setImages:images];
        [images release];
        self.editing = NO;
    }
    
    // email
    else if ([title isEqualToString:[GCImagePickerController localizedString:@"EMAIL"]]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        mail.modalPresentationStyle = UIModalPresentationPageSheet;
        __block NSUInteger index = 0;
        [self.selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            [[self performSelectorInViewHierarchy:@selector(assetsLibrary)]
             assetForURL:obj
             resultBlock:^(ALAsset *asset) {
                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                 NSData *data = [GCImagePickerController dataForAssetRepresentation:rep];
                 [mail
                  addAttachmentData:data
                  mimeType:[GCImagePickerController MIMETypeForAssetRepresentation:rep]
                  fileName:[NSString stringWithFormat:@"Item %lu", index++]];
             }
             failureBlock:^(NSError *error) {
                 NSLog(@"%@", error);
             }];
        }];
        [self presentModalViewController:mail animated:YES];
        [mail release];
    }
    
    // action
    else if ([title isEqualToString:[self performSelectorInViewHierarchy:@selector(actionTitle)]]) {
        GCImagePickerControllerActionBlock block = [self performSelectorInViewHierarchy:@selector(actionBlock)];
        [self.selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            block(obj, stop);
        }];
        self.editing = NO;
    }
    
}

@end
