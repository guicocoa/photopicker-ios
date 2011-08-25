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

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (GCImagePickerControllerAdditions)


/*
 get assets groups sorted the same as seen in UIImagePickerController
 
 types: filter group types. pass ALAssetGroupAll for all groups.
 filter: filter the types of assets shown. groups with no assets
    matching the filter will be omitted.
 error: will be populated if no groups can be loaded.
 
 returns: an array of groups.
 */
- (NSArray *)gc_assetGroupsWithTypes:(ALAssetsGroupType)types assetsFilter:(ALAssetsFilter *)filter error:(NSError **)error;

/*
 get assets belonging to a certain group.
 
 identifier: the persistent identifier of the group.
 filter: filter the types of assets returned.
 group: will be populated with the resulting group.
 error: will be populated if loading assets fails.
 
 returns: an array of groups.
 */
- (NSArray *)gc_assetsInGroupWithIdentifier:(NSString *)identifier filter:(ALAssetsFilter *)filter group:(ALAssetsGroup **)inGroup error:(NSError **)inError;

@end
