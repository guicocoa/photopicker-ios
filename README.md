# About

This library is designed to mimick the core functionality of `UIImagePickerController`. It has a few unique features not found in the Apple implementation.

- Full-screen library browser for the iPad
- Ability to email and copy items from the photo library
- Preserves all item metadata (including location data)

# Requirements

This library requires the presence of the following frameworks:

- MobileCoreServices.framework
- MessageUI.framework
- AssetsLibrary.framework

It requires the project to be built against 4.0 or higher.

# Usage

Drag the "Photo Picker" folder into your project. Import the main header where you intent to use the picker.

````objc
#import "GCImagePickerController.h"
````

Use the picker.

````objc
// create picker
GCImagePickerController *picker = [[GCImagePickerController alloc] initWithRootViewController:nil];

// set custom action title and block
picker.actionTitle = @"Upload"; // add custom action button
picker.actionBlock = ^(NSURL *URL, BOOL *stop) {
    // special action to perform on each selected item
}

// show and release
[self presentModalViewController:picker animated:YES];
[picker release];
````
