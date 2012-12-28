//
//  GCImagePickerController.h
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

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

/*
 
 Create a picker and present it with a certain group displayed instead of the
 main group list. This is only valid on an iPhone or similar form factor.
 
 */
+ (GCImagePickerController *)pickerForGroupWithURL:(NSURL *)URL;

/*
 
 Helper to get the saved photos (camera roll) assets group
 
 */

// internal
@property (nonatomic, readonly) ALAssetsLibrary *assetsLibrary;
+ (NSString *)localizedString:(NSString *)key;
+ (void)failedToLoadAssetsWithError:(NSError *)error;

@end
