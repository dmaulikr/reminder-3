
/*
     File: RootViewController.m
 Abstract: The table view controller responsible for displaying the list of events, supporting additional functionality:
 * Addition of new new events;
 * Deletion of existing events using UITableView's tableView:commitEditingStyle:forRowAtIndexPath: method.
 * Editing an event's name.
 
  Version: 1.1
 
 
 
 */

#import "RootViewController.h"
#import "TaggedLocationsAppDelegate.h"
#import "Event.h"
#import "Tag.h"
#import "Quotation.h"
#import "Play.h"
#import "EventTableViewCell.h"
#import "TagSelectionController.h"
#import "ItemDetailViewController.h"
#import "TableViewController.h"

@implementation RootViewController


@synthesize eventsArray, managedObjectContext, addButton, locationManager, eventTableViewCell;
@synthesize filteredListContent, savedSearchTerm, savedScopeButtonIndex, searchWasActive;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Set the title.
    self.title = @"Locations";
    
	self.tableView.rowHeight = 77;
	
	
	// Configure the add and edit buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *aButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
	self.addButton = aButton;
	
	addButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = addButton;
    
	// Start the location manager.
	[[self locationManager] startUpdatingLocation];
	
	/*
	 Fetch existing events.
	 Create a fetch request; find the Event entity and assign it to the request; add a sort descriptor; then execute the fetch.
	 */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Order the events by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
	NSArray *sortDescriptors = @[sortDescriptor];
	[request setSortDescriptors:sortDescriptors];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail		
	}
	
	// Set self's events array to the mutable array, then clean up.
	[self setEventsArray:mutableFetchResults];
    
    
    // set up the searchList
    // create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.eventsArray count]];
    
    // restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}


- (void)viewDidUnload {
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
	self.eventsArray = nil;
    self.filteredListContent = nil;
	self.locationManager = nil;
	self.addButton = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    
    // For shake motion detection
    [self resignFirstResponder];
}

#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Only one section.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    /*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.filteredListContent count];
    }
	else
	{
        return [self.eventsArray count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// A date formatter for the creation date.
    static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	}
	
	// A number formatter for the latitude and longitude.
	static NSNumberFormatter *numberFormatter = nil;
	if (numberFormatter == nil) {
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:3];
	}
	
	
    static NSString *CellIdentifier = @"EventTableViewCell";

    EventTableViewCell *cell = (EventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"EventTableViewCell" owner:self options:nil];
		cell = eventTableViewCell;
		self.eventTableViewCell = nil;
    }
    
	// Get the event corresponding to the current index path and configure the table view cell.
	Event *event;// = (Event *)eventsArray[indexPath.row];
	
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        event = (self.filteredListContent)[indexPath.row];
    }
    else
    {
        event = (Event *)eventsArray[indexPath.row];
    }

    
	cell.nameField.text = event.name;
	
	cell.creationDateLabel.text = [dateFormatter stringFromDate:[event creationDate]];
	
	NSString *string = [NSString stringWithFormat:@"%@, %@",
						[numberFormatter stringFromNumber:[event latitude]],
						[numberFormatter stringFromNumber:[event longitude]]];
    cell.locationLabel.text = string;
    
	NSMutableArray *eventTagNames = [NSMutableArray array];
	for (Tag *tag in event.tags) {
		[eventTagNames addObject:tag.name];
	}
	
	NSString *tagsString = @"";
	if ([eventTagNames count] > 0) {
		tagsString = [eventTagNames componentsJoinedByString:@", "];
	}
	cell.tagsField.text = tagsString;
	
	cell.nameField.tag = indexPath.row;
	cell.tagsButton.tag = indexPath.row;
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	Event *event;// = (Event *)eventsArray[indexPath.row];
	
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        event = (self.filteredListContent)[indexPath.row];
    }
    else
    {
        event = (Event *)eventsArray[indexPath.row];
    }
    [self showEvent:event animated:YES];
}


#pragma mark - Show Event
- (void)showEvent:(Event *)event animated:(BOOL)animated {
    ItemDetailViewController *eventDetailViewController = [[ItemDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    eventDetailViewController.event = event;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:eventDetailViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark -
#pragma mark Editing

/**
 Handle deletion of an event.
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Ensure that if the user is editing a name field then the change is committed before deleting a row -- this ensures that changes are made to the correct event object.
		[tableView endEditing:YES];
		
        // Delete the managed object at the given index path.
		NSManagedObject *eventToDelete = eventsArray[indexPath.row];
		[managedObjectContext deleteObject:eventToDelete];
		
		// Update the array and table view.
        [eventsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		
		// Commit the change.
		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}

		[self performSelector:@selector(updateRowTags) withObject:nil afterDelay:0.0];
    }   
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    [super setEditing:editing animated:animated];
	self.navigationItem.rightBarButtonItem.enabled = !editing;
}
	

- (IBAction)editTags:(UIButton *)button {
	
	NSInteger row = button.tag;
	
	// Ensure that if the user is editing the name field then the change is committed before pushing the new view controller.
	EventTableViewCell *cell = (EventTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
	[cell.nameField endEditing:YES];
								
	TagSelectionController *tagSelectionController = [[TagSelectionController alloc] initWithStyle:UITableViewStyleGrouped];
	tagSelectionController.event = eventsArray[row];
	[self.navigationController pushViewController:tagSelectionController animated:YES];
}


- (void)updateRowTags {
	NSArray *visibleCells = [self.tableView visibleCells];	
	for (EventTableViewCell *cell in visibleCells) {
		NSInteger tag = [[self.tableView indexPathForCell:cell] row];
		cell.nameField.tag = tag;
		cell.tagsButton.tag = tag;
	}
}


#pragma mark -
#pragma mark Add an event

/**
 Add an event.
 */
- (void)addEvent {
	
	// If it's not possible to get a location, then return.
	CLLocation *location = [locationManager location];
	if (!location) {
		return;
	}
	
	/*
	 Create a new instance of the Event entity.
	 */
	Event *event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:managedObjectContext];
	
	// Configure the new event with information from the location.
	CLLocationCoordinate2D coordinate = [location coordinate];
	[event setLatitude:@(coordinate.latitude)];
	[event setLongitude:@(coordinate.longitude)];
	
	// Should be the location's timestamp, but this will be constant for simulator.
	// [event setCreationDate:[location timestamp]];
	[event setCreationDate:[NSDate date]];
	
	/*
	 Since this is a new event, and events are displayed with most recent events at the top of the list, add the new event to the beginning of the events array, then:
	 * Add a new row to the table view
	 * Scroll to make the row visible
	 * Start editing the name field
	 */
    [eventsArray insertObject:event atIndex:0];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	[self updateRowTags];

	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

	[self setEditing:YES animated:YES];
	EventTableViewCell *cell = (EventTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell.nameField becomeFirstResponder];
	
	/*
	 Don't save yet -- the name is not optional:
	 * The user should add a name before the event is saved.
	 * If the user doesn't add a name, it will be set to @"" when they press Done.
	 */
}


#pragma mark -
#pragma mark Location manager

/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager {
	
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
	
	return locationManager;
}


/**
 Conditionally enable the Add button:
 If the location manager is generating updates, then enable the button;
 If the location manager is failing, then disable the button.
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (!self.editing) {
		addButton.enabled = YES;
	}
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    addButton.enabled = NO;
}


#pragma mark -
#pragma mark Editing text fields

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	
	Event *event = eventsArray[textField.tag];
	event.name = textField.text;
	
	// Commit the change.
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	return YES;
}	


- (void)textFieldDidEndEditing:(UITextField *)textField {
	// Ensure that a text field for a row for a newly-inserted object is disabled when the user finishes editing.
	textField.enabled = self.editing;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	[textField resignFirstResponder];
	return YES;	
}


#pragma mark -
#pragma mark Memory management

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
 	for (Event *event in self.eventsArray)
	{
        NSString *name = event.name;
		if ([scope isEqualToString:@"Name"] || [name isEqualToString:scope])
		{
            // A weak search
			NSComparisonResult result = [name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
			{
				[self.filteredListContent addObject:event];
            }
		} else if ([scope isEqualToString:@"Tag"])// search by model
        {
            NSRange nameRange = [name rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound)
            {
                [self.filteredListContent addObject:event];
            }
        } else if ([scope isEqualToString:@"Label"]){
            NSRange descriptionRange = [name rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(descriptionRange.location != NSNotFound)
            {
                [self.filteredListContent addObject:event];
            }
            
        }
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [self.searchDisplayController.searchBar scopeButtonTitles][[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [self.searchDisplayController.searchBar scopeButtonTitles][searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    self.searchWasActive = YES;
    return;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.searchWasActive = NO;
    return;
}

#pragma mark - 
- (void)scheduleNotificationWithItem:(Event *)event interval:(int)minutesBefore {
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
//    [dateComps setDay:item.day];
//    [dateComps setMonth:item.month];
//    [dateComps setYear:item.year];
//    [dateComps setHour:item.hour];
//    [dateComps setMinute:item.minute];
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [itemDate dateByAddingTimeInterval:-(minutesBefore*60)];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"%@ in %i minutes.", nil),
                            event.name, minutesBefore];
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:event.name forKey:@"ToDoItemKey"];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}


#pragma mark - temp
//- (NSMutableArray *)setUpPlaysArray {
//    
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"PlaysAndQuotations" withExtension:@"plist"];
//    NSArray *playDictionariesArray = [[NSArray alloc ] initWithContentsOfURL:url];
//    NSMutableArray *playsArray = [NSMutableArray arrayWithCapacity:[playDictionariesArray count]];
//    
//    for (NSDictionary *playDictionary in playDictionariesArray) {
//        
//        Play *play = [[Play alloc] init];
//        play.name = playDictionary[@"playName"];
//        
//        NSArray *quotationDictionaries = playDictionary[@"quotations"];
//        NSMutableArray *quotations = [NSMutableArray arrayWithCapacity:[quotationDictionaries count]];
//        
//        for (NSDictionary *quotationDictionary in quotationDictionaries) {
//            
//            Quotation *quotation = [[Quotation alloc] init];
//            [quotation setValuesForKeysWithDictionary:quotationDictionary];
//            
//            [quotations addObject:quotation];
//        }
//        play.quotations = quotations;
//        
//        [playsArray addObject:play];
//    }
//    
//    return playsArray;
//}
@end

