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
    #error "This project uses features only available in iPhone SDK 5.0 and later."
#endif

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

// block to be called on each selected asset
typedef void (^GCImagePickerControllerActionBlock) (NSSet *set);

@interface GCImagePickerController : UINavigationController

#pragma mark - properties

// used to load assets
@property (nonatomic, readonly, retain) ALAssetsLibrary *assetsLibrary;

// filter assets
@property (nonatomic, retain) ALAssetsFilter *assetsFilter;

// title of custom action button
@property (nonatomic, copy) NSString *actionTitle;

// action to perform with set of selected asset URLs
@property (nonatomic, copy) GCImagePickerControllerActionBlock actionBlock;

#pragma mark - class methods

// get a localized string from the library
+ (NSString *)localizedString:(NSString *)key;

// called when assets fail to load
+ (void)failedToLoadAssetsWithError:(NSError *)error;

@end
