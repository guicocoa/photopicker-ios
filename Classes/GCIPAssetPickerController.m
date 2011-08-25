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
#import "GCIPAssetPickerCell.h"

#import "GCImagePickerController.h"

#import "ALAssetsLibrary+GCImagePickerControllerAdditions.h"

@interface GCIPAssetPickerController ()

// asset resources
@property (nonatomic, copy) NSArray *allAssets;
@property (nonatomic, retain) NSMutableSet *selectedAssetURLs;
@property (nonatomic, copy) NSString *groupName;

// ui resources
@property (nonatomic, retain) UIActionSheet *sheet;
@property (nonatomic, assign) NSUInteger numberOfColumns;

@end

@interface GCIPAssetPickerController (private)
- (void)updateTitle;
@end

@implementation GCIPAssetPickerController (private)
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
        self.title = self.groupName;
    }
}
@end

@implementation GCIPAssetPickerController

@synthesize allAssets           = __allAssets;
@synthesize selectedAssetURLs   = __selectedAssets;
@synthesize groupName           = __groupName;
@synthesize groupIdentifier     = __groupIdentifier;

@synthesize sheet               = __sheet;
@synthesize numberOfColumns     = __numberOfColumns;

#pragma mark - object methods
- (id)initWithImagePickerController:(GCImagePickerController *)controller {
    self = [super initWithImagePickerController:controller];
    if (self) {
        self.numberOfColumns = (GC_IS_IPAD) ? 5 : 4;
        self.editing = NO;
    }
    return self;
}
- (void)dealloc {
    
    // clear properties
    self.selectedAssetURLs = nil;
    self.groupIdentifier = nil;
    self.allAssets = nil;
    self.groupName = nil;
    [self.sheet dismissWithClickedButtonIndex:self.sheet.cancelButtonIndex animated:NO];
    
    // super
    [super dealloc];
    
}
- (void)reloadAssets {
    
    // no group
    if (!self.groupIdentifier) {
        self.allAssets = nil;
        self.groupName = nil;
    }
    
    // view loaded
    else if ([self isViewLoaded]) {
        
        // load assets
        ALAssetsGroup *group = nil;
        NSError *error = nil;
        self.allAssets = [self.imagePickerController.assetsLibrary
                          gc_assetsInGroupWithIdentifier:self.groupIdentifier
                          filter:[ALAssetsFilter allAssets]
                          group:&group
                          error:&error];
        if (error) {
            [GCImagePickerController failedToLoadAssetsWithError:error];
        }
        
        // get group name
        self.groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        
    }
    
    // table visibility
    self.tableView.hidden = (![self.allAssets count]);
    
    // trigger a reload
    self.editing = NO;
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
    self.tableView.contentOffset = CGPointMake(0.0, -4.0);
    
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tableDidReceiveTap:)];
    [self.tableView addGestureRecognizer:tap];
    [tap release];
    
    // reload
    [self reloadAssets];
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    self.allAssets = nil;
    self.groupName = nil;
    [self.sheet dismissWithClickedButtonIndex:self.sheet.cancelButtonIndex animated:NO];
    self.editing = NO;
}

#pragma mark - button actions
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (editing) {
        
        // create stuff
        self.selectedAssetURLs = [NSMutableSet set];
        UIBarButtonItem *item;
        item = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                target:self
                action:@selector(action:)];
        item.style = UIBarButtonItemStyleBordered;
        self.navigationItem.rightBarButtonItem = item;
        [item release];
        item = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                target:self
                action:@selector(cancel)];
        item.style = UIBarButtonItemStyleBordered;
        self.navigationItem.leftBarButtonItem = item;
        [item release];
        
    }
    else {
        
        // release stuff
        self.selectedAssetURLs = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        
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
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        GCImagePickerController *controller = self.imagePickerController;
        if (controller.actionBlock && controller.actionTitle) {
            [sheet addButtonWithTitle:controller.actionTitle];
        }
        if ([self.selectedAssetURLs count] < 6 && [MFMailComposeViewController canSendMail]) {
            [sheet addButtonWithTitle:[GCImagePickerController localizedString:@"EMAIL"]];
        }
        if ([self.selectedAssetURLs count] < 6) {
            [sheet addButtonWithTitle:[GCImagePickerController localizedString:@"COPY"]];
        }
        if (GC_IS_IPAD) {
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
    GCIPAssetPickerCell *cell = (GCIPAssetPickerCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[GCIPAssetPickerCell alloc] initWithStyle:0 reuseIdentifier:identifier] autorelease];
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
        NSUInteger row = location.y / self.tableView.rowHeight;
        NSUInteger column = location.x / (self.tableView.bounds.size.width / self.numberOfColumns);
        NSUInteger index = row * self.numberOfColumns + column;
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
            if (![self.selectedAssetURLs count]) {
                self.editing = NO;
            }
            else {
                GCImagePickerController *controller = self.imagePickerController;
                BOOL action = (controller.actionBlock && controller.actionTitle);
                BOOL count = ([self.selectedAssetURLs count] < 6);
                self.navigationItem.rightBarButtonItem.enabled = (action || count);
            }
            
            // reload
            [self updateTitle];
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]];
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
    GCImagePickerController *controller = self.imagePickerController;
    
    // copy
    if ([title isEqualToString:[GCImagePickerController localizedString:@"COPY"]]) {
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:[self.selectedAssetURLs count]];
        [self.selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            [controller.assetsLibrary
             assetForURL:obj
             resultBlock:^(ALAsset *asset) {
                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                 UIImage *image = [[UIImage alloc] initWithCGImage:[rep fullScreenImage]];
                 [images addObject:image];
                 [image release];
             }
             failureBlock:^(NSError *error) {
                 GC_LOG_NSERROR(error);
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
            [controller.assetsLibrary
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
    else if ([title isEqualToString:controller.actionTitle]) {
        [self.selectedAssetURLs enumerateObjectsUsingBlock:controller.actionBlock];
        self.editing = NO;
    }
    
}

@end
