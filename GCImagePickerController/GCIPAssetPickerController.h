//
//  GCIPAssetPickerController.h
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

#import "GCIPViewController.h"

// select an asset from a given group
@interface GCIPAssetPickerController : GCIPViewController

// the group to browse
@property (nonatomic, copy) NSURL *groupURL;

@end
