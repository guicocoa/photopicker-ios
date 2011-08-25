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

#import "ALAssetsLibrary+GCImagePickerControllerAdditions.h"

@implementation ALAssetsLibrary (GCImagePickerControllerAdditions)
- (NSArray *)gc_assetGroupsWithTypes:(ALAssetsGroupType)types assetsFilter:(ALAssetsFilter *)filter error:(NSError **)inError {
    
    // this will be returned
    __block NSMutableArray *groups = nil;
    
    // load groups
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [self
     enumerateGroupsWithTypes:types
     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         if (group) {
             [group setAssetsFilter:filter];
             if ([group numberOfAssets]) {
                 NSNumber *type = [group valueForProperty:ALAssetsGroupPropertyType];
                 NSMutableArray *groupsByType = [dictionary objectForKey:type];
                 if (groupsByType == nil) {
                     groupsByType = [NSMutableArray arrayWithCapacity:1];
                     [dictionary setObject:groupsByType forKey:type];
                 }
                 [groupsByType addObject:group];
             }
         }
         else {
             
             // make our groups array
             groups = [[NSMutableArray alloc] init];
             
             // sort groups into final container
             NSArray *typeNumbers = [NSArray arrayWithObjects:
                                     [NSNumber numberWithUnsignedInteger:ALAssetsGroupSavedPhotos],
                                     [NSNumber numberWithUnsignedInteger:ALAssetsGroupAlbum],
                                     [NSNumber numberWithUnsignedInteger:ALAssetsGroupEvent],
                                     [NSNumber numberWithUnsignedInteger:ALAssetsGroupFaces],
                                     nil];
             for (NSNumber *type in typeNumbers) {
                 NSArray *groupsByType = [dictionary objectForKey:type];
                 [groups addObjectsFromArray:groupsByType];
                 [dictionary removeObjectForKey:type];
             }
             
             // get any groups we do not have contants for
             for (NSNumber *type in [dictionary keysSortedByValueUsingSelector:@selector(compare:)]) {
                 NSArray *groupsByType = [dictionary objectForKey:type];
                 [groups addObjectsFromArray:groupsByType];
                 [dictionary removeObjectForKey:type];
             }
             
         }
     }
     failureBlock:^(NSError *error) {
         if (inError) { *inError = [error retain]; }
         groups = [[NSArray alloc] init];
     }];
    
    // wait
    while (groups == nil) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, NO);
    }
        
    // return
    if (inError) { [*inError autorelease]; }
    return [groups autorelease];
    
}
- (NSArray *)gc_assetsInGroupWithIdentifier:(NSString *)identifier filter:(ALAssetsFilter *)filter group:(ALAssetsGroup **)inGroup error:(NSError **)inError {
    
    // this will be returned
    __block NSMutableArray *assets = nil;
    
    [self
     enumerateGroupsWithTypes:ALAssetsGroupAll
     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         if (group) {
             NSString *groupIdentifier = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
             if ([groupIdentifier isEqualToString:identifier]) {
                 [group setAssetsFilter:filter];
                 assets = [[NSMutableArray alloc] initWithCapacity:[group numberOfAssets]];
                 [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                     if (result) { [assets addObject:result]; }
                 }];
                 if (inGroup) { *inGroup = [group retain]; }
                 *stop = YES;
             }
         }
         else {
             if (assets == nil) {
                 assets = [[NSArray alloc] init];
             }
         }
     }
     failureBlock:^(NSError *error) {
         if (inError) { *inError = [error retain]; }
         assets = [[NSArray alloc] init];
     }];
    
    // wait
    while (assets == nil) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, NO);
    }
    
    // return
    if (inGroup) { [*inGroup autorelease]; }
    if (inError) { [*inError autorelease]; }
    return [assets autorelease];
    
}
@end
