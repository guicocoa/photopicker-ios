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

/*
 
 This block will be called with a set of URLs that correspond to the selected
 photo library assets. These assets can be fetched using methods on
 ALAssetLibrary.
 
 */
typedef void (^GCImagePickerControllerActionBlock) (NSSet *set);

/*
 
 Block called when the "Done" button is pressed. Dismiss the picker here.
 
 */
typedef void (^GCImagePickerControllerDidFinishBlock) ();

@interface GCImagePickerController : UINavigationController

/*
 
 Properties that allow you customize the functionality of the image picker. It
 is best that these properties be set before the view loads.
 
 */
@property (nonatomic, retain) ALAssetsFilter *assetsFilter;
@property (nonatomic, copy) NSString *actionTitle;
@property (nonatomic, copy) GCImagePickerControllerActionBlock actionBlock;
@property (nonatomic, copy) GCImagePickerControllerDidFinishBlock didFinishBlock;

// internal resources
@property (nonatomic, readonly, retain) ALAssetsLibrary *assetsLibrary;
+ (NSString *)localizedString:(NSString *)key;
+ (void)failedToLoadAssetsWithError:(NSError *)error;

@end
