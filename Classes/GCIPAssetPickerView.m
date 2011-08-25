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

#import "GCIPAssetPickerView.h"

@interface GCIPAssetPickerView()
@property (nonatomic, retain) UIImageView *thumbnailView;
@property (nonatomic, retain) UIImageView *videoIconView;
@property (nonatomic, retain) UIImageView *selectedIconView;
@end

@implementation GCIPAssetPickerView

@synthesize asset               = __asset;
@synthesize selected            = __selected;
@synthesize thumbnailView       = __thumbnailView;
@synthesize videoIconView       = __videoIconView;
@synthesize selectedIconView    = __selectedIconView;

#pragma mark - object methods
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // variables
        UIImageView *imageView;
        
        // base properties
        self.layer.borderColor = [[UIColor colorWithWhite:0.0 alpha:0.25] CGColor];
        self.layer.borderWidth = 1.0;
        self.autoresizesSubviews = NO;
        
        // thumbnail view
        imageView = [[UIImageView alloc] initWithImage:nil];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        self.thumbnailView = imageView;
        [imageView release];
        
        // video icon view
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GCImagePickerControllerVideoAsset"]];
        imageView.layer.backgroundColor = [[UIColor colorWithWhite:0.0 alpha:0.25] CGColor];
        imageView.contentMode = UIViewContentModeLeft;
        self.videoIconView = imageView;
        [imageView release];
        
        // selected icon view
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GCImagePickerControllerCheckGreen"]];
        imageView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        imageView.contentMode = UIViewContentModeBottomRight;
        self.selectedIconView = imageView;
        [imageView release];
        
        // add subviews
        [self addSubview:self.thumbnailView];
        [self addSubview:self.videoIconView];
        [self addSubview:self.selectedIconView];
        
    }
    return self;
}
- (void)dealloc {
    self.asset = nil;
    self.thumbnailView = nil;
    self.selectedIconView = nil;
    self.videoIconView = nil;
    [super dealloc];
}
- (void)setAsset:(ALAsset *)asset {
    
    // check for duplicate
    if ([asset isEqual:__asset]) {
        return;
    }
    
    // save asset
    [__asset release];
    __asset = [asset retain];
    
    // set views
    if (__asset) {
        
        // self
        self.hidden = NO;
        
        // thumbnail view
        UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:[asset thumbnail]];
        self.thumbnailView.image = thumbnailImage;
        [thumbnailImage release];
        
        // video view
        NSString *assetType = [asset valueForProperty:ALAssetPropertyType];
        self.videoIconView.hidden = ![assetType isEqualToString:ALAssetTypeVideo];
        
    }
    
    // clear views
    else {
        self.hidden = YES;
    }
    
}
- (void)setSelected:(BOOL)selected {
    self.selectedIconView.hidden = !selected;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // thumbnail view
    self.thumbnailView.frame = self.bounds;
    
    // video view
    UIImage *videoIcon = self.videoIconView.image;
    self.videoIconView.frame = CGRectMake(1.0,
                                          self.bounds.size.height - videoIcon.size.height - 1.0,
                                          self.bounds.size.width - 2.0,
                                          videoIcon.size.height);
    
    // selected view
    self.selectedIconView.frame = CGRectMake(1.0,
                                             1.0, 
                                             self.bounds.size.width - 2.0,
                                             self.bounds.size.height - 2.0);
}

@end
