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

#import "GCIPTableViewController.h"

@class GCIPGroupPickerController;
@class ALAssetsGroup;

// group picker delegate
@protocol GCIPGroupPickerControllerDelegate <NSObject>
@required

// callback for group selection
- (void)groupPicker:(GCIPGroupPickerController *)groupPicker didSelectGroup:(ALAssetsGroup *)group;

@end

// select a group (album, faces group, camera roll, etc)
@interface GCIPGroupPickerController : GCIPTableViewController {
    
}

// group picker delegate
@property (nonatomic, assign) id<GCIPGroupPickerControllerDelegate> groupPickerDelegate;

// list of groups
@property (nonatomic, readonly, copy) NSArray *groups;

// show or hide disclosure indicators
@property (nonatomic, assign) BOOL showDisclosureIndicators;

@end
