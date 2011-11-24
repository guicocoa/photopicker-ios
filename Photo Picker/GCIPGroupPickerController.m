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

#import "GCIPGroupPickerController.h"
#import "GCIPAssetPickerController.h"
#import "GCImagePickerController.h"

@interface GCIPGroupPickerController ()
@property (nonatomic, readwrite, copy) NSArray *groups;
@property (nonatomic, retain) NSNumberFormatter *numberFormatter;
@end

@implementation GCIPGroupPickerController

#pragma mark - object methods

@synthesize delegate                    = __delegate;
@synthesize showDisclosureIndicators    = __showDisclosureIndicators;
@synthesize groups                      = __groups;
@synthesize numberFormatter             = __numberFormatter;

- (id)initWithNibName:(NSString *)nib bundle:(NSBundle *)bundle {
    self = [super initWithNibName:nib bundle:bundle];
    if (self) {
        self.title = [GCImagePickerController localizedString:@"PHOTO_LIBRARY"];
        self.showDisclosureIndicators = YES;
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                   target:self
                                                   action:@selector(done)]
                                                  autorelease];
    }
    return self;
}
- (void)dealloc {
    self.groups = nil;
    self.numberFormatter = nil;
    [super dealloc];
}
- (void)reloadAssets {
    if ([self isViewLoaded]) {
        NSError *error = nil;
        self.groups = [GCImagePickerController
                       assetsGroupsInLibary:self.parent.assetsLibrary
                       withTypes:ALAssetsGroupAll
                       assetsFilter:self.parent.assetsFilter
                       error:&error];
        if (error) {
            [GCImagePickerController failedToLoadAssetsWithError:error];
        }
        self.tableView.hidden = ([self.groups count] == 0);
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView reloadData];
        if (indexPath && indexPath.row < [self.groups count]) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.numberFormatter = formatter;
    [formatter release];
    self.tableView.rowHeight = 60.0;
    [self reloadAssets];
}
- (void)viewDidUnload {
    [super viewDidUnload];
    self.groups = nil;
    self.numberFormatter = nil;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

#pragma mark - button actions
- (void)done {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.groups count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
        cell.accessoryType = (self.showDisclosureIndicators) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    }
    ALAssetsGroup *group = [self.groups objectAtIndex:indexPath.row];
	cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
	cell.imageView.image = [UIImage imageWithCGImage:[group posterImage]];
    NSNumber *count = [NSNumber numberWithInteger:[group numberOfAssets]];
    cell.detailTextLabel.text = [self.numberFormatter stringFromNumber:count];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *group = [self.groups objectAtIndex:indexPath.row];
    if (self.delegate) {
        [self.delegate groupPicker:self didSelectGroup:group];
    }
    else {
        GCIPAssetPickerController *assetPicker = [[GCIPAssetPickerController alloc] initWithNibName:nil bundle:nil];
        assetPicker.parent = self.parent;
        assetPicker.groupIdentifier = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
        [self.navigationController pushViewController:assetPicker animated:YES];
        [assetPicker release];
    }
}

@end
