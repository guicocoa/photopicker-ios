//
//  PPViewController.m
//  PhotoPicker
//
//  Created by Caleb Davenport on 9/11/12.
//  Copyright (c) 2012 Caleb Davenport. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "PPViewController.h"

#import "GCImagePickercontroller.h"

#import "ALAssetsLibrary+GCImagePickerControllerAdditions.h"

@implementation PPViewController

- (void)presentPhotoPickerForGroupWithURL:(NSURL *)URL {
    GCImagePickerController *picker = [GCImagePickerController pickerForGroupWithURL:URL];
    picker.actionTitle = @"Upload";
    picker.actionBlock = ^(NSSet *URLs) {
        NSLog(@"%@", URLs);
    };
    picker.finishBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)browseEntireLibrary:(id)sender {
    [self presentPhotoPickerForGroupWithURL:nil];
}

- (IBAction)browseCameraRoll:(id)sender {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library
     enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         if (group != nil) {
             NSURL *URL = [group valueForProperty:ALAssetsGroupPropertyURL];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self presentPhotoPickerForGroupWithURL:URL];
             });
             *stop = YES;
         }
     }
     failureBlock:^(NSError *error) {
         [GCImagePickerController failedToLoadAssetsWithError:error];
     }];
}

@end
