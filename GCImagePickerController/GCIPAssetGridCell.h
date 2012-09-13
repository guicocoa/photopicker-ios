//
//  GCIPAssetGridCell.h
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

#import <UIKit/UIKit.h>

// cell designed to display a grid of assets
@interface GCIPAssetGridCell : UITableViewCell

// number of columns for the cell to display
@property (nonatomic, assign) NSUInteger numberOfColumns;

// set assets to display and pass a set of selected asset urls
- (void)setAssets:(NSArray *)assets selected:(NSSet *)selected;

@end
