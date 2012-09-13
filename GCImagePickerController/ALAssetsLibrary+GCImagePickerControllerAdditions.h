//
//  ALAssetsLibrary+GCImagePickerControllerAdditions.h
//
//  Created by Caleb Davenport on 3/9/12.
//  Copyright (c) 2012 Caleb Davenport.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (GCImagePickerControllerAdditions)

/*
 
 Get groups sorted the same as seen in UIImagePickerController
 
 types: Filter group types. Pass ALAssetGroupAll for all groups.
 filter: Filter asset types. Groups with no assets matching the filter will be
    omitted.
 completion: Called on the main thread with an array of groups.
 failure: Called on the main thread with an error.
 
 */
- (void)gcip_assetsGroupsWithTypes:(ALAssetsGroupType)types
                      assetsFilter:(ALAssetsFilter *)filter
                        completion:(void (^) (NSArray *groups))completion
                           failure:(void (^) (NSError *error))failure;

/*
 
 Get assets belonging to a certain group with the newest asset appearing first.
 
 url: The URL that identifies the desired group.
 filter: Filter the types of assets returned.
 completion: Called on the main thread with an array of assets and a reference
    to the selected group.
 failure: Called on the main thread with an error.
 
 */
- (void)gcip_assetsInGroupGroupWithURL:(NSURL *)URL
                          assetsFilter:(ALAssetsFilter *)filter
                            completion:(void (^) (ALAssetsGroup *group, NSArray *assets))completion
                               failure:(void (^) (NSError *error))failure;

@end
