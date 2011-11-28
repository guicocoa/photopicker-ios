/*
 
 Copyright (C) 2011 GUI Cocoa, LLC.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <AssetsLibrary/AssetsLibrary.h>

#import "GCIPAssetGridCell.h"
#import "GCIPAssetView.h"

@implementation GCIPAssetGridCell

@synthesize numberOfColumns = __numberOfColumns;

#pragma mark - object methods
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
- (void)setNumberOfColumns:(NSUInteger)count {
    if (count == __numberOfColumns) {
        return;
    }
    __numberOfColumns = count;
    [self setNeedsLayout];
}
- (void)setAssets:(NSArray *)assets selected:(NSSet *)selected {
    NSUInteger count = [assets count];
    for (NSUInteger index = 0; index < self.numberOfColumns; index++) {
        
        // get view
        NSUInteger tag = index + 1;
        GCIPAssetView *assetView = (GCIPAssetView *)[self.contentView viewWithTag:tag];
        
        // create view if we need one
        if (assetView == nil && index < count) {
            assetView = [[GCIPAssetView alloc] initWithFrame:CGRectZero];
            assetView.tag = tag;
            [self.contentView addSubview:assetView];
            [assetView release];
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
