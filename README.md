# About

This library is designed to mimick the core functionality of `UIImagePickerController`. It also has a few unique features not found Apple's implementation.

- Full-screen library browser for the iPad
- Preserves all item metadata (including location data)

# Requirements

This library requires the presence of the following frameworks:

- `AssetsLibrary.framework`
- `QuartzCore.framework`

The project must be built against the iOS 5.0 SDK or higher.

If your project is not setup to use ARC, add `-fobjc-arc` to all source files for this library in your target's "Compile Sources" build phase.

# Usage

Add the "GCImagePickerController" folder to your project. Import the main header where you intend to use the picker.

```objc
#import "GCImagePickerController.h"
```

Use the picker.

```objc
// create picker
GCImagePickerController *picker = [GCImagePickerController picker];

// set custom action title and block
picker.actionTitle = @"Upload";
picker.actionBlock = ^(NSSet *URLs) {
    NSLog(@"%@", URLs);
};

// finish up and present
picker.finishBlock = ^{ // this is optional
    [self dismissViewControllerAnimated:YES completion:nil];
};
[self presentViewController:picker animated:YES completion:nil];
````
