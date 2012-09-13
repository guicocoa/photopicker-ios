//
//  GCIPAssetView.m
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

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
