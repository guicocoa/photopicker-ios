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

#import "GCIPGroupPickerController.h"
#import "GCIPAssetPickerController.h"

@implementation PPViewController

- (void)presentPhotoPickerForGroupWithURL:(NSURL *)URL {
    GCImagePickerController *picker = [GCImagePickerController pickerForGroupWithURL:URL];
    picker.actionTitle = @"Upload";
    picker.selectedItemsBlock = ^(NSSet *URLs) {
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

- (IBAction)custom:(id)sender {
    GCImagePickerController *picker = [GCImagePickerController picker];
    picker.appearenceDelegate = self;
    picker.actionTitle = @"Select Photos";
    picker.selectedItemsBlock = ^(NSSet *URLs) {
        NSLog(@"%@", URLs);
    };
    picker.finishBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)openCamera {
    NSLog(@"open camera");
}

- (void)groupPickerController:(GCIPGroupPickerController *)groupPickerController setNavigationItemWithRightAction:(SEL)rightAction {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button setBackgroundImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
    [button addTarget:groupPickerController action:rightAction forControlEvents:UIControlEventTouchUpInside];
    
    groupPickerController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button setBackgroundImage:[UIImage imageNamed:@"CameraButton"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openCamera) forControlEvents:UIControlEventTouchUpInside];
    
    groupPickerController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)assetPickerController:(GCIPAssetPickerController *)assetPickerController leftBarButtonItemWithAction:(SEL)backAction {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button setBackgroundImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
    [button addTarget:assetPickerController action:backAction forControlEvents:UIControlEventTouchUpInside];
    
    assetPickerController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)assetPickerControllerDidSelectedPhoto:(GCIPAssetPickerController *)assetPickerController
    updateNavigationBarButtonWithCancelAction:(SEL)cancelAction
                                   doneAction:(SEL)doneAction {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button setBackgroundImage:[UIImage imageNamed:@"SaveButton"] forState:UIControlStateNormal];
    [button addTarget:assetPickerController action:doneAction forControlEvents:UIControlEventTouchUpInside];
    
    assetPickerController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
