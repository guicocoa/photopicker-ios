//
//  ALAssetRepresentation+GCImagePickerControllerAdditions.m
//  QuickShot
//
//  Created by Caleb Davenport on 3/9/12.
//  Copyright (c) 2012 GUI Cocoa, LLC. All rights reserved.
//

#import "ALAssetRepresentation+GCImagePickerControllerAdditions.h"

@implementation ALAssetRepresentation (GCImagePickerControllerAdditions)

- (BOOL)gcip_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // return if the file exists already
    if ([manager fileExistsAtPath:path]) {
        return NO;
    }
    
    // get path for writing
	NSString *writePath = path;
	if (useAuxiliaryFile) {
        NSString *unique = [[NSProcessInfo processInfo] globallyUniqueString];
        writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:unique];
        writePath = [writePath stringByAppendingPathComponent:[path lastPathComponent]];
	}
    
    // return if we cannot create a file handle
    if (![manager createFileAtPath:writePath contents:nil attributes:nil]) { return NO; }
    
    // create file handle and return if unsuccessful
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:writePath];
    if (!handle) { return NO; }
    
    // do writing
	long long size = [self size];
    long long offset = 0;
	while (offset < size) {
		uint8_t buffer[512];
        NSError *error = nil;
        NSUInteger written = [self getBytes:buffer fromOffset:offset length:512 error:&error];
        if (error) {
            NSLog(@"%@", error);
            [handle closeFile];
            [manager removeItemAtPath:writePath error:nil];
            return NO;
        }
        NSData *data = [NSData dataWithBytes:buffer length:written];
        [handle writeData:data];
        offset += written;
	}
	[handle closeFile];
    
    // move file into place
	if (useAuxiliaryFile) {
		if (![manager moveItemAtPath:writePath toPath:path error:nil]) {
            [manager removeItemAtPath:writePath error:nil];
            return NO;
        }
	}
    
    // it worked!
    return YES;
    
}

@end
