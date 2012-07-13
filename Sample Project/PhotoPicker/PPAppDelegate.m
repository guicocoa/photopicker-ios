//
//  PPAppDelegate.m
//  PhotoPicker
//
//  Created by Caleb Davenport on 7/13/12.
//  Copyright (c) 2012 Caleb Davenport. All rights reserved.
//

#import "PPAppDelegate.h"

#import "GCImagePickercontroller.h"

@implementation PPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        GCImagePickerController *picker = [GCImagePickerController picker];
        picker.finishBlock = ^{
            
        };
    });
    return YES;
}

@end
