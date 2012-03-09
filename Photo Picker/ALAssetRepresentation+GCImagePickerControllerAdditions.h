//
//  ALAssetRepresentation+GCImagePickerControllerAdditions.h
//  QuickShot
//
//  Created by Caleb Davenport on 3/9/12.
//  Copyright (c) 2012 GUI Cocoa, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetRepresentation (GCImagePickerControllerAdditions)

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;

@end
