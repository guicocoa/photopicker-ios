# USAGE

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
    