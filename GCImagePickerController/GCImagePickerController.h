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

#import <UIKit/UIKit.h>

@class ALAssetsLibrary;
@class ALAssetsFilter;

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
 is best that these properties be set before presenting the view. Changing them
 after the fact will result in unknown behavior.
 
 */
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;

/*
 
 Indicate what to do with items that have been selected. The title should
 be localized. The block receives an `NSSet` of asset URLs.
 
 */
@property (nonatomic, copy) NSString *actionTitle;
@property (nonatomic, copy) GCImagePickerControllerActionBlock actionBlock;

/*
 
 Customize the behavior of the "Done" button. Leaving this property `nil` will
 result in the done button dismissing the modal view controller. Set this
 property if you need more control over it.
 
 */
@property (nonatomic, copy) GCImagePickerControllerDidFinishBlock finishBlock;

/*
 
 Create a new picker which should be shown as a modal view controller.
 
 */
+ (GCImagePickerController *)picker;

// internal
@property (nonatomic, readonly) ALAssetsLibrary *assetsLibrary;
+ (NSString *)localizedString:(NSString *)key;
+ (void)failedToLoadAssetsWithError:(NSError *)error;

@end
