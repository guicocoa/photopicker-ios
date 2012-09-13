//
//  GCIPTableViewController.h
//
//  Copyright (c) 2011-2012 Caleb Davenport.
//

#import "GCIPViewController.h"

/*
 
 Defines an abstract base class for view controllers that show items from the
 assets library in a table format.
 
 */
@interface GCIPTableViewController : GCIPViewController <UITableViewDelegate, UITableViewDataSource>

// table view - this should be hidden when there are no assets
@property (nonatomic, weak) UITableView *tableView;

// set whether the table should clear selection
@property (nonatomic, assign) BOOL clearsSelectionOnViewWillAppear;

@end
