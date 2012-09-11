//
//  PPViewController.m
//  PhotoPicker
//
//  Created by Caleb Davenport on 9/11/12.
//  Copyright (c) 2012 Caleb Davenport. All rights reserved.
//

#import "PPViewController.h"

#import "GCImagePickercontroller.h"

@implementation PPViewController

- (IBAction)showPhotoPicker:(id)sender {
    GCImagePickerController *picker = [GCImagePickerController picker];
    picker.finishBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:picker animated:YES completion:nil];
}

@end
