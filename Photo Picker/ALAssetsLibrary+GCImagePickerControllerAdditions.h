//
//  ALAssetsLibrary+GCImagePickerControllerAdditions.h
//  QuickShot
//
//  Created by Caleb Davenport on 3/9/12.
//  Copyright (c) 2012 GUI Cocoa, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (GCImagePickerControllerAdditions)

/*
 
 Get groups sorted the same as seen in UIImagePickerController
 
 types: Filter group types. Pass ALAssetGroupAll for all groups.
 filter: Filter asset types. Groups with no assets matching the filter will be
 omitted.
 error: Populated if an error occurs.
 
 returns: An array of asset groups.
 
 */
- (NSArray *)assetsGroupsWithTypes:(ALAssetsGroupType)types
                      assetsFilter:(ALAssetsFilter *)filter
                             error:(NSError **)outError;

/*
 
 Get assets belonging to a certain group with the newest asset appearing first.
 
 identifier: The persistent identifier of the group.
 filter: Filter the types of assets returned.
 group: Populated with the resulting group.
 error: Populated if an error occurs.
 
 returns: An array of assets.
 
 */
- (NSArray *)assetsInGroupWithIdentifier:(NSString *)identifier
                                  filter:(ALAssetsFilter *)filter
                                   group:(ALAssetsGroup **)outGroup
                                   error:(NSError **)outError;

@end
