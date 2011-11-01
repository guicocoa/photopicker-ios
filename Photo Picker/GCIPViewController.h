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

#import <UIKit/UIKit.h>

@class GCImagePickerController;

/*
 
 defines an abstract base class for view
 controllers that show items from the
 assets library.
 
 */
@interface GCIPViewController : UIViewController {
    
}

// object for which we get data and listen for changes
@property (nonatomic, readonly, assign) GCImagePickerController *imagePickerController;

// designated initializer
- (id)initWithImagePickerController:(GCImagePickerController *)controller;

/*
 
 perform a reload of the assets we are displaying.
 the default implementation of this method does
 nothing and should only serve as a template for
 how subclasses should perform reloading. you do
 not need to call super.
 
 */
- (void)reloadAssets;

@end
