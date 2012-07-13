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

#ifndef __IPHONE_5_0
#error This project uses features only available in iOS SDK 5.0 and later.
#endif
#if !__has_feature(objc_arc)
#error This project requires ARC.
#endif

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "GCImagePickerController.h"
#import "GCIPViewController_Pad.h"
#import "GCIPGroupPickerController.h"

@implementation GCImagePickerController

@synthesize actionBlock = _actionBlock;
@synthesize actionTitle = _actionTitle;
@synthesize assetsFilter = _assetsFilter;
@synthesize finishBlock = _didFinishBlock;
@synthesize assetsLibrary = _assetsLibrary;

#pragma mark - class methods

+ (NSString *)localizedString:(NSString *)key {
    return [[NSBundle mainBundle] localizedStringForKey:key value:nil table:NSStringFromClass(self)];
}

+ (void)failedToLoadAssetsWithError:(NSError *)error {
    NSInteger code = [error code];
    UIAlertView *alert = nil;
    if (code == ALAssetsLibraryAccessUserDeniedError || code == ALAssetsLibraryAccessGloballyDeniedError) {
        alert = [[UIAlertView alloc]
                 initWithTitle:[self localizedString:@"ERROR"]
                 message:[self localizedString:@"PHOTO_ROLL_LOCATION_ERROR"]
                 delegate:nil
                 cancelButtonTitle:[self localizedString:@"OK"]
                 otherButtonTitles:nil];

    }
    else {
        alert = [[UIAlertView alloc]
                 initWithTitle:[self localizedString:@"ERROR"]
                 message:[self localizedString:@"UNKNOWN_LIBRARY_ERROR"]
                 delegate:nil
                 cancelButtonTitle:[self localizedString:@"OK"]
                 otherButtonTitles:nil];
    }
    [alert show];
}

+ (GCImagePickerController *)picker {
    
    // create root controller
    UIViewController *controller = nil;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        GCIPViewController_Pad *controller = [[GCIPViewController_Pad alloc] initWithNibName:nil bundle:nil];
//        self = [super initWithRootViewController:controller];
//        [controller release];
//    }
//    else {
//        GCIPGroupPickerController *controller = [[GCIPGroupPickerController alloc] initWithNibName:nil bundle:nil];
//        self = [super initWithRootViewController:controller];
//        [controller release];
//    }
    
    // create picker
    GCImagePickerController *picker = [[GCImagePickerController alloc] initWithRootViewController:controller];
    picker.modalPresentationStyle = UIModalPresentationPageSheet;
    picker.assetsFilter = [ALAssetsFilter allAssets];
    
    // assets library
    picker->_assetsLibrary = [[ALAssetsLibrary alloc] init];
    [picker->_assetsLibrary writeImageToSavedPhotosAlbum:nil metadata:nil completionBlock:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:picker
     selector:@selector(assetsLibraryDidChange:)
     name:ALAssetsLibraryChangedNotification
     object:picker->_assetsLibrary];
    
    // return
    return picker;
    
}

#pragma mark - object methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:ALAssetsLibraryChangedNotification
     object:self.assetsLibrary];
}

- (void)assetsLibraryDidChange:(NSNotification *)notif {
    [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[GCIPViewController class]]) {
            [(GCIPViewController *)obj reloadAssets];
        }
    }];
}

@end
