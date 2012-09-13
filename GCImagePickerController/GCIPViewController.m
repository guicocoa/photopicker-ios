//
//  GCIPViewController.m
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "GCIPViewController.h"

@implementation GCIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)reloadAssets {
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) { return YES; }
    else { return (orientation == UIInterfaceOrientationPortrait); }
}

@end
