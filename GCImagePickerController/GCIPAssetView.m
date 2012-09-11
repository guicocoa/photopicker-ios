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

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "GCIPAssetView.h"

@implementation GCIPAssetView {
    UIImageView *_thumbnailView;
    UIImageView *_videoIconView;
    UIImageView *_selectedIconView;
}

#pragma mark - object methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // base properties
        self.layer.borderColor = [[UIColor colorWithWhite:0.0 alpha:0.25] CGColor];
        self.layer.borderWidth = 1.0;
        self.autoresizesSubviews = NO;
        
        // thumbnail view
        _thumbnailView = [[UIImageView alloc] initWithImage:nil];
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailView.clipsToBounds = YES;
        
        // video icon view
        _videoIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GCImagePickerControllerVideoAsset"]];
        _videoIconView.layer.backgroundColor = [[UIColor colorWithWhite:0.0 alpha:0.25] CGColor];
        _videoIconView.contentMode = UIViewContentModeLeft;
        
        // selected icon view
        _selectedIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GCImagePickerControllerCheckGreen"]];
        _selectedIconView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        _selectedIconView.contentMode = UIViewContentModeBottomRight;
        
        // add subviews
        [self addSubview:_thumbnailView];
        [self addSubview:_videoIconView];
        [self addSubview:_selectedIconView];
        
    }
    return self;
}

- (void)setAsset:(ALAsset *)asset {
    
    // check for duplicate
    if ([asset isEqual:_asset]) { return; }
    
    // save asset
    _asset = asset;
    
    // set views
    if (_asset) {
        
        // self
        self.hidden = NO;
        
        // thumbnail view
        _thumbnailView.image = [UIImage imageWithCGImage:[asset thumbnail]];
        
        // video view
        NSString *assetType = [asset valueForProperty:ALAssetPropertyType];
        _videoIconView.hidden = ![assetType isEqualToString:ALAssetTypeVideo];
        
    }
    
    // clear views
    else {
        self.hidden = YES;
    }
    
}

- (void)setSelected:(BOOL)selected {
    _selectedIconView.hidden = !selected;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // thumbnail view
    _thumbnailView.frame = self.bounds;
    
    // video view
    UIImage *videoIcon = _videoIconView.image;
    _videoIconView.frame = CGRectMake(1.0,
                                      self.bounds.size.height - videoIcon.size.height - 1.0,
                                      self.bounds.size.width - 2.0,
                                      videoIcon.size.height);
    
    // selected view
    _selectedIconView.frame = CGRectMake(1.0,
                                         1.0, 
                                         self.bounds.size.width - 2.0,
                                         self.bounds.size.height - 2.0);
    
}

@end
