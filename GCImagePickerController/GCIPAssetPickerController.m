//
//  GCIPAssetPickerController.m
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

#import "GCIPAssetPickerController.h"
#import "GCIPAssetGridCell.h"
#import "GCImagePickerController.h"
#import "GCIPAssetView.h"

#import "ALAssetsLibrary+GCImagePickerControllerAdditions.h"

@interface GCIPAssetPickerController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation GCIPAssetPickerController {
    NSMutableSet *_selectedAssetURLs;
    ALAssetsGroup *_group;
    NSArray *_assets;
}

#pragma mark - object methods

- (id)init {
    self = [super init];
    if (self) {
        self.title = [GCImagePickerController localizedString:@"PHOTO_LIBRARY"];
        self.groupURL = nil;
        _selectedAssetURLs = [NSMutableSet set];
    }
    return self;
}

- (void)setGroupURL:(NSURL *)URL {
    if ([URL isEqual:_groupURL]) { return; }
    _groupURL = [URL copy];
    [self cancel];
    [self reloadAssets];
    self.collectionView.contentOffset = CGPointMake(0.0, 0.0);
    [self.collectionView flashScrollIndicators];
}

- (void)reloadAssets {
    
    // no group
    if (self.groupURL == nil) {
        _assets = nil;
        _group = nil;
    }
    
    // view is loaded
    else if ([self isViewLoaded]) {
        ALAssetsLibrary *library = [self.parentViewController performSelector:@selector(assetsLibrary)];
        ALAssetsFilter *filter = [self.parentViewController performSelector:@selector(assetsFilter)];
        [library
         gcip_assetsInGroupGroupWithURL:self.groupURL
         assetsFilter:filter
         completion:^(ALAssetsGroup *group, NSArray *assets) {
             _group = group;
             _assets = assets;
             [self updateTitle];
             [self.collectionView reloadData];
             self.collectionView.hidden = ([_assets count] == 0);
         }
         failure:^(NSError *error) {
             [GCImagePickerController failedToLoadAssetsWithError:error];
         }];
    }
    
}

- (void)updateTitle {
    NSUInteger count = [_selectedAssetURLs count];
    if (count == 1) {
        self.title = [GCImagePickerController localizedString:@"PHOTO_COUNT_SINGLE"];
    }
    else if (count > 1) {
        self.title = [NSString stringWithFormat:
                      [GCImagePickerController localizedString:@"PHOTO_COUNT_MULTIPLE"],
                      [NSNumberFormatter localizedStringFromNumber:@(count) numberStyle:NSNumberFormatterDecimalStyle]];
    }
    else if (_group) {
        self.title = [_group valueForProperty:ALAssetsGroupPropertyName];
    }
}

- (void)done {
    GCImagePickerControllerDidFinishBlock block = [self.parentViewController performSelector:@selector(finishBlock)];
    if (block) { block(); }
    else { [self dismissViewControllerAnimated:YES completion:nil]; }
}

- (void)cancel {
    _selectedAssetURLs = [NSMutableSet set];
    self.navigationItem.leftBarButtonItem = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(done)];
    }
    else { self.navigationItem.rightBarButtonItem = nil; }
    [self.collectionView reloadData];
    [self updateTitle];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    
    // super
    [super viewDidLoad];
    
    // self
    self.view.backgroundColor = [UIColor whiteColor];
    
    // collection view
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
    layout.minimumInteritemSpacing = 4.0;
    layout.minimumLineSpacing = 4.0;
    if (screenBounds.size.height > 400.0) {
        layout.itemSize = CGSizeMake(101.0, 101.0);
    }
    else {
        layout.itemSize = CGSizeMake(75.0, 75.0);
    }
    UICollectionView *collectionView = [[UICollectionView alloc]
                                        initWithFrame:self.view.bounds
                                        collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    collectionView.hidden = YES;
    collectionView.backgroundView = nil;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.bounces = YES;
    collectionView.alwaysBounceVertical = YES;
    collectionView.allowsMultipleSelection = YES;
    [collectionView registerClass:[GCIPAssetView class] forCellWithReuseIdentifier:@"AssetCell"];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    // reload
    [self reloadAssets];
    
}

- (void)didReceiveMemoryWarning {
    if (![self isViewLoaded]) {
        _assets = nil;
        _group = nil;
    }
    [super didReceiveMemoryWarning];
}

#pragma mark - button actions

- (void)action {
    GCImagePickerControllerSelectedItemsBlock block = [self.parentViewController performSelector:@selector(selectedItemsBlock)];
    if (block) { block([_selectedAssetURLs copy]); }
    [self cancel];
}

#pragma mark - collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_assets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GCIPAssetView *view = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    view.asset = [_assets objectAtIndex:indexPath.row];
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // get asset stuff
    ALAsset *asset = [_assets objectAtIndex:indexPath.row];
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    NSURL *defaultURL = [representation url];
    if (defaultURL) { [_selectedAssetURLs addObject:defaultURL]; }
    
    // check if multiple selection is allowed
    BOOL allowsMultipleSelection = (BOOL)[self.parentViewController performSelector:@selector(allowsMultipleSelection)];
    if (!allowsMultipleSelection) {
        GCImagePickerControllerSelectedItemsBlock block = [self.parentViewController performSelector:@selector(selectedItemsBlock)];
        if (block) { block([NSSet setWithObject:defaultURL]); }
        return;
    }
    
    // view stuff
    [self updateTitle];
    if ([[collectionView indexPathsForSelectedItems] count] == 1) {
        NSString *title = [self.parentViewController performSelector:@selector(actionTitle)];
        UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                 initWithTitle:title
                                 style:UIBarButtonItemStyleDone
                                 target:self
                                 action:@selector(action)];
        self.navigationItem.rightBarButtonItem = item;
        item = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                target:self
                action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = item;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = [_assets objectAtIndex:indexPath.row];
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    NSURL *defaultURL = [representation url];
    if (defaultURL) { [_selectedAssetURLs removeObject:defaultURL]; }
    [self updateTitle];
    if ([[collectionView indexPathsForSelectedItems] count] == 0) {
        [self cancel];
    }
}

@end
