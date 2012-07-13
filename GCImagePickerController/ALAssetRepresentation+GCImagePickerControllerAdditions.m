//
//  ALAssetRepresentation+GCImagePickerControllerAdditions.m
//  QuickShot
//
//  Created by Caleb Davenport on 3/9/12.
//  Copyright (c) 2012 GUI Cocoa, LLC. All rights reserved.
//

#import "ALAssetRepresentation+GCImagePickerControllerAdditions.h"

@implementation ALAssetRepresentation (GCImagePickerControllerAdditions)

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile {
    
    // return if the file exists already
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return NO;
    }
    
    // get write path
	NSString *writePath = path;
	if (useAuxiliaryFile) {
		writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[path lastPathComponent]];
	}
    
    // return if we cannot create a file handle
    if (![[NSFileManager defaultManager] createFileAtPath:writePath contents:nil attributes:nil]) {
        return NO;
    }
    
    // create file handle and return if unsuccessful
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:writePath];
    if (!handle) { return NO; }
    
    // do writing
	long long size = [self size];
    long long offset = 0;
	while (offset < size) {
		uint8_t buffer[1024];
        NSError *error = nil;
        NSUInteger written = [self getBytes:buffer fromOffset:offset length:1024 error:&error];
        if (error) {
            NSLog(@"%@", error);
            [handle closeFile];
            [[NSFileManager defaultManager] removeItemAtPath:writePath error:nil];
            return NO;
        }
        NSData *toWrite = [[NSData alloc] initWithBytes:buffer length:written];
        [handle writeData:toWrite];
        [toWrite release];
        offset += written;
	}
	[handle closeFile];
    
    // move file into place
	if (useAuxiliaryFile) {
		if (![[NSFileManager defaultManager] moveItemAtPath:writePath toPath:path error:nil]) {
            [[NSFileManager defaultManager] removeItemAtPath:writePath error:nil];
            return NO;
        }
	}
    
    // it worked!
    return YES;
    
}

@end
