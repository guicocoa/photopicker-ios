//
//  ALAssetRepresentation+GCImagePickerControllerAdditions.h
//  QuickShot
//
//  Created by Caleb Davenport on 3/9/12.
//  Copyright (c) 2012 GUI Cocoa, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetRepresentation (GCImagePickerControllerAdditions)

/*
 
 Write the receiver to the given file. Optionally write to a temporary location
 then move into place atomically.
 
 */
- (BOOL)gcip_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;

@end
