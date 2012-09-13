//
//  GCIPAssetView.h
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

#import <UIKit/UIKit.h>

@class ALAsset;

@interface GCIPAssetView : UIView

@property (nonatomic, retain) ALAsset *asset;
@property (nonatomic, assign) BOOL selected;

@end
