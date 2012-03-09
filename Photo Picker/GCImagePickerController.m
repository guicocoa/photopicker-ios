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

#import "GCImagePickerController.h"
#import "GCIPViewController_Pad.h"
#import "GCIPGroupPickerController.h"

@interface GCImagePickerController ()
@property (nonatomic, readwrite, retain) ALAssetsLibrary *assetsLibrary;
- (void)reloadChildren;
@end

@implementation GCImagePickerController

#pragma mark - class methods

+ (NSString *)localizedString:(NSString *)key {
    return [[NSBundle mainBundle] localizedStringForKey:key value:nil table:NSStringFromClass(self)];
}
+ (void)failedToLoadAssetsWithError:(NSError *)error {
    NSLog(@"%@", error);
    NSInteger code = [error code];
    if (code == ALAssetsLibraryAccessUserDeniedError || code == ALAssetsLibraryAccessGloballyDeniedError) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[self localizedString:@"ERROR"]
                              message:[self localizedString:@"PHOTO_ROLL_LOCATION_ERROR"]
                              delegate:nil
                              cancelButtonTitle:[self localizedString:@"OK"]
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[self localizedString:@"ERROR"]
                              message:[self localizedString:@"UNKNOWN_LIBRARY_ERROR"]
                              delegate:nil
                              cancelButtonTitle:[self localizedString:@"OK"]
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - object methods

@synthesize assetsLibrary   = __assetsLibrary;
@synthesize actionBlock     = __actionBlock;
@synthesize actionTitle     = __actionTitle;
@synthesize assetsFilter    = __assetsFilter;

- (id)initWithRootViewController:(UIViewController *)root {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        GCIPViewController_Pad *controller = [[GCIPViewController_Pad alloc] initWithNibName:nil bundle:nil];
        self = [super initWithRootViewController:controller];
        controller.parent = self;
        [controller release];
    }
    else {
        GCIPGroupPickerController *controller = [[GCIPGroupPickerController alloc] initWithNibName:nil bundle:nil];
        self = [super initWithRootViewController:controller];
        controller.parent = self;
        [controller release];
    }
    if (self) {
        self.modalPresentationStyle = UIModalPresentationPageSheet;
        self.assetsLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
        [self.assetsLibrary writeImageToSavedPhotosAlbum:nil metadata:nil completionBlock:nil];
        self.assetsFilter = [ALAssetsFilter allAssets];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(assetsLibraryDidChange:)
         name:ALAssetsLibraryChangedNotification
         object:self.assetsLibrary];
    }
    return self;
}
- (void)dealloc {
    
    // clear notifs
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:ALAssetsLibraryChangedNotification
     object:self.assetsLibrary];
    
    // clear properties
    self.assetsLibrary = nil;
    self.actionBlock = nil;
    self.actionTitle = nil;
    self.assetsFilter = nil;
    
    // super
    [super dealloc];
    
}
- (void)reloadChildren {
    [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[GCIPViewController class]]) {
            [(GCIPViewController *)obj reloadAssets];
        }
    }];
}
- (void)assetsLibraryDidChange:(NSNotification *)notif {
    [self reloadChildren];
}

@end
