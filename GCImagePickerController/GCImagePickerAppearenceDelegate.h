//
//  GCImagePickerAppearenceDelegate.h
//
//  Created by foxling on 13-1-4.
//

#import <Foundation/Foundation.h>

@class GCIPGroupPickerController;
@class GCIPAssetPickerController;

@protocol GCImagePickerAppearenceDelegate <NSObject>

@optional

- (void)groupPickerController:(GCIPGroupPickerController *)groupPickerController setNavigationItemWithRightAction:(SEL)rightAction;

- (void)assetPickerController:(GCIPAssetPickerController *)assetPickerController leftBarButtonItemWithAction:(SEL)backAction;

- (void)assetPickerControllerDidSelectedPhoto:(GCIPAssetPickerController *)assetPickerController
    updateNavigationBarButtonWithCancelAction:(SEL)cancelAction
                                   doneAction:(SEL)doneAction;

@end
