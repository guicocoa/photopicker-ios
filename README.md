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

    // create picker
    GCImagePickerController *picker = [[GCImagePickerController alloc] initWithRootViewController:nil];
    
    // set custom action title and block
    picker.actionTitle = @"Upload";
    picker.actionBlock = ^(NSURL *URL, BOOL *stop) {
        // block to perform on each selected item
    }
    
    // show and release
    [self presentModalViewController:picker animated:YES];
    [picker release];
    