//
//  GCIPViewController.h
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

#import <UIKit/UIKit.h>

@class ALAssetsLibrary;

/*
 
 Defines an abstract base class for view controllers that show items from the
 assets library.
 
 */
@interface GCIPViewController : UIViewController

/*
 
 Perform a reload of the assets we are displaying. The default implementation of
 this method does nothing and should only serve as a template for how subclasses
 should perform reloading. You do not need to call super.
 
 */
- (void)reloadAssets;

@end
