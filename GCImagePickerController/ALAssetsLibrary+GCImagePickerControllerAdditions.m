//
//  ALAssetsLibrary+GCImagePickerControllerAdditions.m
//  QuickShot
//
//  Created by Caleb Davenport on 3/9/12.
//  Copyright (c) 2012 GUI Cocoa, LLC. All rights reserved.
//

#import "ALAssetsLibrary+GCImagePickerControllerAdditions.h"

@implementation ALAssetsLibrary (GCImagePickerControllerAdditions)

- (NSArray *)assetsGroupsWithTypes:(ALAssetsGroupType)types
                      assetsFilter:(ALAssetsFilter *)filter
                             error:(NSError **)outError {
    
    // load groups
    __block BOOL wait = YES;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSMutableArray *array = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self
         enumerateGroupsWithTypes:types
         usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
             if (group) {
                 [group setAssetsFilter:filter];
                 if ([group numberOfAssets]) {
                     NSNumber *type = [group valueForProperty:ALAssetsGroupPropertyType];
                     NSMutableArray *groups = [dictionary objectForKey:type];
                     if (groups == nil) {
                         groups = [NSMutableArray arrayWithCapacity:1];
                         [dictionary setObject:groups forKey:type];
                     }
                     [groups addObject:group];
                 }
             }
             else {
                 
                 // sort known groups into final container
                 NSArray *types = [NSArray arrayWithObjects:
                                   [NSNumber numberWithUnsignedInteger:ALAssetsGroupSavedPhotos],
                                   [NSNumber numberWithUnsignedInteger:ALAssetsGroupPhotoStream],
                                   [NSNumber numberWithUnsignedInteger:ALAssetsGroupLibrary],
                                   [NSNumber numberWithUnsignedInteger:ALAssetsGroupAlbum],
                                   [NSNumber numberWithUnsignedInteger:ALAssetsGroupEvent],
                                   [NSNumber numberWithUnsignedInteger:ALAssetsGroupFaces],
                                   nil];
                 for (NSNumber *typeNumber in types) {
                     NSArray *groups = [dictionary objectForKey:typeNumber];
                     ALAssetsGroupType type = [typeNumber unsignedIntegerValue];
                     if (type != ALAssetsGroupEvent) {
                         groups = [groups sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                             NSString *name1 = [obj1 valueForProperty:ALAssetsGroupPropertyName];
                             NSString *name2 = [obj2 valueForProperty:ALAssetsGroupPropertyName];
                             return [name1 localizedCompare:name2];
                         }];
                     }
                     [array addObjectsFromArray:groups];
                     [dictionary removeObjectForKey:typeNumber];
                 }
                 
                 // get any groups we do not have contants for
                 for (NSNumber *type in [dictionary keysSortedByValueUsingSelector:@selector(compare:)]) {
                     NSArray *groups = [dictionary objectForKey:type];
                     groups = [groups sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                         NSString *name1 = [obj1 valueForProperty:ALAssetsGroupPropertyName];
                         NSString *name2 = [obj2 valueForProperty:ALAssetsGroupPropertyName];
                         return [name1 localizedCompare:name2];
                     }];
                     [array addObjectsFromArray:groups];
                     [dictionary removeObjectForKey:type];
                 }
                 
                 // unlock
                 wait = NO;
                 
             }
         }
         failureBlock:^(NSError *error) {
             if (outError) { *outError = [error retain]; }
             wait = NO;
         }];
    });
    
    // spin
    if ([self respondsToSelector:@selector(addAssetsGroupAlbumWithName:resultBlock:failureBlock:)]) {
        while (wait) {
            [NSThread sleepForTimeInterval:0.1];
        }
    }
    else {
        while (wait) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    
    
    // wait
    if (outError) { [*outError autorelease]; }
    return array;
    
}

- (NSArray *)assetsInGroupWithIdentifier:(NSString *)identifier
                                  filter:(ALAssetsFilter *)filter
                                   group:(ALAssetsGroup **)outGroup
                                   error:(NSError **)outError {
    
    // load assets
    __block BOOL wait = YES;
    NSMutableArray *assets = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self
         enumerateGroupsWithTypes:ALAssetsGroupAll
         usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
             if (group) {
                 NSString *groupID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
                 if ([groupID isEqualToString:identifier]) {
                     [group setAssetsFilter:filter];
                     [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                         if (result) { [assets addObject:result]; }
                     }];
                     if (outGroup) { *outGroup = [group retain]; }
                     *stop = YES;
                     wait = NO;
                 }
             }
             else {
                 wait = NO;
             }
         }
         failureBlock:^(NSError *error) {
             if (outError) { *outError = [error retain]; }
             wait = NO;
         }];
    });
    
    // wait
    if ([self respondsToSelector:@selector(addAssetsGroupAlbumWithName:resultBlock:failureBlock:)]) {
        while (wait) {
            [NSThread sleepForTimeInterval:0.1];
        }
    }
    else {
        while (wait) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    
    // return
    if (outGroup) { [*outGroup autorelease]; }
    if (outError) { [*outError autorelease]; }
    return assets;
    
}

@end
