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

#import "GCIPViewController.h"

@implementation GCIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)reloadAssets {
    if ([self isViewLoaded]) {
        
        // do reloading here
        
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? YES :  (orientation == UIInterfaceOrientationPortrait);
}
- (id)performSelectorInViewHierarchy:(SEL)action {
    if ([self respondsToSelector:action]) {
        return [self performSelector:action];
    }
    else if ([self.parentViewController respondsToSelector:action]) {
        return [self.parentViewController performSelector:action];
    }
    else if ([self.parentViewController respondsToSelector:_cmd]) {
        return [self.parentViewController performSelector:_cmd];
    }
    else {
        return nil;
    }
}

@end
