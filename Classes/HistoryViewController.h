
/*
     File: RootViewController.h
 Abstract: The table view controller responsible for displaying the list of events, supporting additional functionality:
 * Addition of new new events;
 * Deletion of existing events using UITableView's tableView:commitEditingStyle:forRowAtIndexPath: method.
 * Editing an event's name.
 
  Version: 1.1
 
 
 
 Copyright (C) 2010 LJApps. All Rights Reserved.
 
 */

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <EventKitUI/EventKitUI.h>

@class EventTableViewCell;

@interface HistoryViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate, EKEventEditViewDelegate, EKCalendarChooserDelegate, UIActionSheetDelegate> {
	
    NSMutableArray *eventsArray;
    NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
	NSManagedObjectContext *managedObjectContext;	    

    CLLocationManager *locationManager;
    UIBarButtonItem *addButton;
	
	EventTableViewCell *__weak eventTableViewCell;
    
    // The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;

}

@property (nonatomic, strong) NSMutableArray *eventsArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;	    

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIBarButtonItem *addButton;

@property (nonatomic, weak) IBOutlet EventTableViewCell *eventTableViewCell;

@property (nonatomic, strong) NSMutableArray *filteredListContent;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

- (void)updateRowTags;

@end
