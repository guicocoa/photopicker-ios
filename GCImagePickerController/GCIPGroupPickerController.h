//
//  GCIPGroupPickerController.h
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

#import "GCIPTableViewController.h"

@class GCIPGroupPickerController;
@class ALAssetsGroup;

/*
 
 Delegate protocol that allows customization of the action that will be
 performed when a group is selected from the provided controller.
 
 */
@protocol GCIPGroupPickerControllerDelegate <NSObject>
@required

// callback for group selection
- (void)groupPicker:(GCIPGroupPickerController *)picker didSelectGroup:(ALAssetsGroup *)group;

@end

// select a group from the assets library
@interface GCIPGroupPickerController : GCIPTableViewController

// group picker delegate
@property (nonatomic, assign) id<GCIPGroupPickerControllerDelegate> delegate;

// list of groups
@property (nonatomic, readonly, copy) NSArray *groups;

// show or hide disclosure indicators
@property (nonatomic, assign) BOOL showDisclosureIndicators;

@end
