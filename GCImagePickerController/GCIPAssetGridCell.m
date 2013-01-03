//
//  GCIPAssetGridCell.m
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "GCIPAssetGridCell.h"
#import "GCIPAssetView.h"

@implementation GCIPAssetGridCell

#pragma mark - object methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) { self.selectionStyle = UITableViewCellSelectionStyleNone; }
    return self;
}

- (void)setNumberOfColumns:(NSUInteger)count {
    if (count == _numberOfColumns) { return; }
    _numberOfColumns = count;
    [self setNeedsLayout];
}

- (NSUInteger)tagForColumn:(NSUInteger)column {
    return column + 1;
}

- (GCIPAssetView *)assetViewAtColumn:(NSUInteger)column {
    NSUInteger tag = [self tagForColumn:column];
    return (id)[self.contentView viewWithTag:tag];
}

- (void)setAssets:(NSArray *)assets selected:(NSSet *)selected {
    NSUInteger count = [assets count];
    for (NSUInteger index = 0; index < self.numberOfColumns; index++) {
        
        // get view
        GCIPAssetView *assetView = [self assetViewAtColumn:index];
        
        // create view if we need one
        if (assetView == nil && index < count) {
            assetView = [[GCIPAssetView alloc] initWithFrame:CGRectZero];
            assetView.tag = [self tagForColumn:index];
            [self.contentView addSubview:assetView];
        }
        
        // setup view
        ALAsset *asset = nil;
        if (index < count) {
            asset = [assets objectAtIndex:index];
            NSURL *assetURL = [[asset defaultRepresentation] url];
            [assetView setSelected:[selected containsObject:assetURL]];
        }
        [assetView setAsset:asset];
        
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize viewSize = self.contentView.bounds.size;
    CGSize tileSize = CGSizeMake(0.0, viewSize.height - 4.0);
    NSUInteger columns = self.numberOfColumns;
    NSUInteger spaces = columns + 1;
    CGFloat totalSpace = (CGFloat)spaces * 4.0;
    tileSize.width = floorf((viewSize.width - totalSpace) / (CGFloat)columns);
    CGFloat occupiedWidth = tileSize.width * 4;
    CGFloat extraSpace = viewSize.width - occupiedWidth - totalSpace;
    [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        CGRect frame = CGRectMake(4.0 + (4.0 + tileSize.width) * (CGFloat)idx, 0.0, tileSize.width, tileSize.height);
        if (idx == columns - 1) { frame.size.width += extraSpace; }
        [(UIView *)obj setFrame:frame];
    }];
}

@end
