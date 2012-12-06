
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
#import "EventTableViewCell.h"
#import "TagSelectionController.h"
#import "TableViewController.h"
#import "AppCalendar.h"
#import "PlaceSearchViewController.h"
#import "TaggedLocationsAppDelegate.h"
#import "TTTTimeIntervalFormatter.h"
#import "SVProgressHUD.h"

@implementation RootViewController


@synthesize eventsArray, managedObjectContext, addButton, locationManager, eventTableViewCell;
@synthesize filteredListContent, savedSearchTerm, savedScopeButtonIndex, searchWasActive;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Set the title.
    self.title = NSLocalizedString(@"Reminders", @"Reminders");
    
	self.tableView.rowHeight = 77;
	
//    [SSThemeManager customizeTableView:self.tableView];
	
	// Configure the add and edit buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *aButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
	self.addButton = aButton;
	addButton.enabled = YES;
    self.navigationItem.rightBarButtonItem = addButton;
    
    // detect shake
    [self becomeFirstResponder];
    
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
	
    static NSString *CellIdentifier = @"EventTableViewCell";

    EventTableViewCell *cell = (EventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"EventTableViewCell" owner:self options:nil];
		cell = eventTableViewCell;
		self.eventTableViewCell = nil;
    }
    
	// Get the event corresponding to the current index path and configure the table view cell.
	Event *event;
	
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
    cell.expiredDateLabel.text = (event.expired !=nil)?event.expired:@"";
    
    NSDate *now = [NSDate date];
    //The receiver, now, is later in time than anotherDate, NSOrderedDescending
    if ([now compare:event.expiredDate] == NSOrderedDescending) {
        cell.userInteractionEnabled = NO;
    }
	
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = nil;
	
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        event = (self.filteredListContent)[indexPath.row];
    }
    else
    {
        event = (Event *)eventsArray[indexPath.row];
    }
  
    EKEventStore *store = [AppCalendar eventStore];
    // we will target to ios 6 or above
    if ([store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            // handle access here
            if (error != nil) {
                [[[UIAlertView alloc] initWithTitle:@"Oops"
                                            message:@"Unexpected Error:"
                                           delegate:self
                                  cancelButtonTitle:@"Okay"
                                  otherButtonTitles:nil] show];
                
            } else {
                if (granted) {
                    EKCalendarChooser* chooseCal = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleSingle
                                                                                        displayStyle:EKCalendarChooserDisplayWritableCalendarsOnly
                                                                                          eventStore:store ];
                    chooseCal.delegate = self;
                    chooseCal.showsDoneButton = YES;
                    
                    // have to make it on main thread or very slow to load
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController pushViewController:chooseCal animated:YES];
                    });
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Oops"
                                                message:@"The app needs to use your calendar"
                                               delegate:self
                                      cancelButtonTitle:@"Okay"
                                      otherButtonTitles:nil] show];
                    
                }
            }
        }];
    }
    
    
 
}


#pragma mark - Calendar methods

-(void)addEvent:(Event*)reminder toEventStore:(EKEventStore *)store toCalendar:(EKCalendar*)calendar
{
    // we parse this event
//    /* TODO: LONG WAY TO GO
//    reminder.name = @"pick up kids at 4pm";
//    NSDictionary *parsedQuestion = [self parsingLinguistic:reminder.name];
//    reminder.what = parsedQuestion[@"what"];
//    reminder.when = parsedQuestion[@"when"];
//    reminder.where = parsedQuestion[@"where"];
//    */
    // I wish I can handle better on this based on the Linguistic
    EKEvent* event = [EKEvent eventWithEventStore:store];
    event.calendar = calendar;
    
    EKAlarm* myAlarm = [EKAlarm alarmWithRelativeOffset: - 06*60 ];  // reminder in 6 mins before
    [event addAlarm: myAlarm];
    
    NSDateFormatter* frm = [[NSDateFormatter alloc] init];
    [frm setDateFormat:@"MM/dd/yyyy HH:mm zzz"];
    [frm setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    event.title = reminder.name;
//    event.location = reminder.where;
//    event.notes = reminder.how ;
    
    
    // this is how we want to set up the "how",
    NSNumber* weekDay = [NSNumber numberWithInt:1];
    //1
    EKRecurrenceDayOfWeek* showDay = [EKRecurrenceDayOfWeek dayOfWeek: [weekDay intValue] ];
    //2
    EKRecurrenceEnd* runFor3Months = [EKRecurrenceEnd recurrenceEndWithOccurrenceCount:12];
    //3
    EKRecurrenceRule* myReccurrence =
    [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
                                                 interval:1
                                            daysOfTheWeek:[NSArray arrayWithObject:showDay]
                                           daysOfTheMonth:nil
                                          monthsOfTheYear:nil
                                           weeksOfTheYear:nil
                                            daysOfTheYear:nil
                                             setPositions:nil
                                                      end:runFor3Months];
    [event addRecurrenceRule: myReccurrence];
    
    //1 save the event to the calendar
    NSError* error = nil;
    [store saveEvent:event span:EKSpanFutureEvents commit:YES error:&error];
    
    //2 show the edit event dialogue
    EKEventEditViewController* editEvent = [[EKEventEditViewController alloc] init];
    editEvent.eventStore = store;
    editEvent.event = event;
    editEvent.editViewDelegate = self;
    [self presentViewController:editEvent animated:YES completion:^{
        // we already saved so we don't handle "cancel" anymore
                    UINavigationItem* item = [editEvent.navigationBar.items objectAtIndex:0];
                    item.leftBarButtonItem = nil;
    }];

}

#pragma mark - Edit event delegate
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller
{
    return [AppCalendar calendar];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    NSError* error = nil;
    switch (action) {
        case EKEventEditViewActionDeleted:
            [[AppCalendar eventStore] removeEvent:controller.event span:EKSpanFutureEvents error:&error];
            break;
        case EKEventEditViewActionSaved:
        {
            EKEvent* returnedEvent = controller.event;
            NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
            
            // let's update the database & update the tableview
            // need to update this one
            Event *event = eventsArray[selectedPath.row];
            event.name = returnedEvent.title;
            event.expired = [self relativeDate:returnedEvent.endDate];
            event.expiredDate = returnedEvent.endDate;
            
            // Commit the change.
            NSError *error;
            if (![managedObjectContext save:&error]) {
                // Handle the error.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                exit(-1);  // Fail
            }
            
            // then we update the view
            [self.tableView reloadRowsAtIndexPaths:@[selectedPath] withRowAnimation:UITableViewRowAnimationNone];
            
            if (controller.event.location.length > 0) {
                event.where = returnedEvent.location;
                [[[UIAlertView alloc] initWithTitle:@"Set Geo-fencing?"
                                            message:@"You mentioned a location?"
                                           delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"No", @"No")
                                  otherButtonTitles:@"Yes", nil] show];
            }
            

            break;
        }
        
        default:break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    
}

#pragma mark - Alertview delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int row = [self.tableView indexPathForSelectedRow].row;
    
    Event *event = nil;
    
    if (self.tableView == self.searchDisplayController.searchResultsTableView)
    {
        event = (self.filteredListContent)[row];
    }
    else
    {
        event = (Event *)eventsArray[row];
    }
    
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        // User cancels so we set the preference value
        event.useGeoFencing = NO;
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    } else {
        event.useGeoFencing = YES;
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LocationStoryboard" bundle:nil];
        UINavigationController *controller = [storyBoard instantiateInitialViewController];
        PlaceSearchViewController *searchViewController = (PlaceSearchViewController*)controller.viewControllers[0];
        searchViewController.searchString = event.where;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - Cell update after a new event created

- (void)updateCellInfo {
    NSArray *visibleCells = [self.tableView visibleCells];
    for (EventTableViewCell *cell in visibleCells) {
        NSInteger tag = [[self.tableView indexPathForCell:cell] row];
        cell.nameField.tag = tag;
        cell.tagsButton.tag = tag;
    }
}

#pragma mark - Calendar chooser delegate

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser
{
    //1
    EKCalendar* selectedCalendar = [calendarChooser.selectedCalendars anyObject];
    
    //2
    int row = [self.tableView indexPathForSelectedRow].row;
    
    //3
    Event *event;
    
    if (self.tableView == self.searchDisplayController.searchResultsTableView)
    {
        event = (self.filteredListContent)[row];
    }
    else
    {
        event = (Event *)eventsArray[row];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addEvent:event toEventStore:[AppCalendar eventStore] toCalendar:selectedCalendar];
    });

    [self.navigationController popViewControllerAnimated:YES];
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
        // Apparantly the only way I can think is to compare the title:
        // check for a calendar with the same name with our own Event object
        EKEventStore *eventStore = [AppCalendar eventStore];
        
        __block EKEvent *targetEvent = nil;
        const double secondsInAYear = (60.0*60.0*24.0)*365.0;
        NSPredicate* predicate = [eventStore predicateForEventsWithStartDate:[NSDate dateWithTimeIntervalSinceNow:-secondsInAYear] endDate:[NSDate dateWithTimeIntervalSinceNow:secondsInAYear] calendars:nil];
        [eventStore enumerateEventsMatchingPredicate:predicate
                                          usingBlock:^(EKEvent *event, BOOL *stop) {
                                              if ([event.title isEqualToString:((Event *)eventToDelete).name]) {
                                                  targetEvent = event;
                                                  *stop = YES;
                                                  
                                              }
                                          }];
        if (targetEvent != nil) {
           [[AppCalendar eventStore] removeEvent:targetEvent span:EKSpanFutureEvents error:&error]; 
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
	
	/*
	 Create a new instance of the Event entity.
	 */
	Event *event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:managedObjectContext];
	
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

		if ([scope isEqualToString:@"Title"])
		{
            // A weak search
            NSString *name = event.name;
			NSComparisonResult result = [name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
			{
				[self.filteredListContent addObject:event];
            }
		} else if ([scope isEqualToString:@"Tag"])// search by tag
        {
            NSSet *tags = event.tags;
            [tags enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                NSString *name = ((Tag *)obj).name;
                NSRange nameRange = [name rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if(nameRange.location != NSNotFound)
                {
                    [self.filteredListContent addObject:event];
                }
            }];
        } else if ([scope isEqualToString:@"Location"])
        {
            NSString *location = event.where;
            NSRange nameRange = [location rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound)
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


#pragma mark - Sort options
- (BOOL)canBecomeFirstResponder
{
    return YES;
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sort By" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Name",@"Expired Date",@"Prority", nil];
        actionSheet.destructiveButtonIndex = 1; // Priority will be highlighted
        [actionSheet showInView:self.tableView];

    }
}

#pragma mark - UIActionSheet Delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    } else {
        NSString *sortKey = @"";
        NSSortDescriptor *sortdis;
        
        switch (buttonIndex) {
            case 0: //
                sortKey = @"name";
                break;
            case 1: // Status
                sortKey = @"expiredDate";
                break;
            case 2: // Name
                sortKey = @"priority";
                break;
            default:
                break;
        }
        
        // I think this sort approach is better (more general in terms of the usage
        sortdis = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
        NSArray *discriptor = [NSArray arrayWithObjects:sortdis,nil];
        NSArray *sortedArray =  [self.eventsArray sortedArrayUsingDescriptors:discriptor];
        self.eventsArray = [NSMutableArray arrayWithArray:sortedArray];
        
        [self.tableView reloadData];
    }
	
}

#pragma mark - helper method
#pragma mark - get relative Date String
- (NSString *)relativeDate:(NSDate*)pastDate
{
    NSDate* rightNow = [NSDate date];
    NSTimeInterval timeInterval = [pastDate timeIntervalSinceDate:rightNow];
    static TTTTimeIntervalFormatter *_timeIntervalFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        [_timeIntervalFormatter setLocale:[NSLocale currentLocale]];
    });
    return [_timeIntervalFormatter stringForTimeInterval:timeInterval];
}

#pragma mark - Parsing Linguistic
- (NSDictionary *)parsingLinguistic:(NSString *)title
{

    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
    tagger.string = title;

    // I need a better algorithm for this
    __block NSMutableArray *tagArrays = [NSMutableArray array];
    [tagger enumerateTagsInRange:NSMakeRange(0, [title length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        NSString *token = [title substringWithRange:tokenRange];
        NSDictionary *dict = @{@"tag":tag, @"token":token};
        [tagArrays addObject:dict];
    }];

    NSLog(@"the tags array: %@",tagArrays);

    // I know this is stupid
    __block int16_t conjunctionIndex = 0;
    __block int16_t particleIndex = 0;
    __block int16_t prepositionIndex = 0;
    [tagArrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = (NSDictionary *)obj;
        if ([dict[@"tag"] isEqualToString:@"Particle"]) {
            particleIndex = idx;
        }
        if ([dict[@"tag"] isEqualToString:@"Conjunction"]) {
            conjunctionIndex = idx;
        }
        if ([dict[@"tag"] isEqualToString:@"Preposition"]) {
            prepositionIndex = idx;
        }
        
    }];

    NSLog(@"par:%d, con:%d,  prep: %d",particleIndex, conjunctionIndex, prepositionIndex);
//
//
    __block NSMutableString *whatString = [NSMutableString string];

    if  ((conjunctionIndex - (particleIndex+1)) > 0)
    {
        NSRange whatRange = NSMakeRange(particleIndex+1, conjunctionIndex-(particleIndex+ 1));
        NSArray *whatArray = [tagArrays objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:whatRange]];
        
        if (whatArray.count>0) {
            [whatArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [whatString appendString:[NSString stringWithFormat:@"%@ ",((NSDictionary *)obj)[@"token"]]];
            }];
        }
        NSLog(@"what :%@",whatString);
    }

    __block NSMutableString *whereString = [NSMutableString string];
    if ((prepositionIndex-(conjunctionIndex+1)) > 0) {
        NSRange whereRange = NSMakeRange(conjunctionIndex+1, prepositionIndex-(conjunctionIndex+ 1));
        NSArray *whereArray = [tagArrays objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:whereRange]];
        if (whereArray.count>0) {
            [whereArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [whereString appendString:[NSString stringWithFormat:@"%@ ",((NSDictionary *)obj)[@"token"]]];
            }];
        }
        NSLog(@"where :%@",whereString);

    }

    __block NSMutableString *whenString = [NSMutableString string];
    if ((tagArrays.count-(prepositionIndex+1)) > 0) {
        NSRange whenRange = NSMakeRange(prepositionIndex+1, tagArrays.count-(prepositionIndex+ 1));
        NSArray *whenArray = [tagArrays objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:whenRange]];
        if (whenArray.count>0) {
            [whenArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [whenString appendString:[NSString stringWithFormat:@"%@ ",((NSDictionary *)obj)[@"token"]]];
            }];
        }
        NSLog(@"when :%@",whenString);
    }
    
    return @{@"what":whatString, @"where":whereString, @"when":whenString};
}


#pragma mark -
#pragma mark Location manager

/**
 Return a location manager -- create one if necessary.
 */
//- (CLLocationManager *)locationManager {
//
//    if (locationManager != nil) {
//		return locationManager;
//	}
//
//	locationManager = [[CLLocationManager alloc] init];
//	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
//	[locationManager setDelegate:self];
//
//	return locationManager;
//}


/**
 Conditionally enable the Add button:
 If the location manager is generating updates, then enable the button;
 If the location manager is failing, then disable the button.
 */
//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation {
//    if (!self.editing) {
//		addButton.enabled = YES;
//	}
//}
//
//- (void)locationManager:(CLLocationManager *)manager
//       didFailWithError:(NSError *)error {
//    addButton.enabled = NO;
//}

#pragma mark - Region Managerment

//- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
//	NSString *event = [NSString stringWithFormat:@"You are entering %@.", region.identifier];
//	[self updateWithEvent:event];
//}
//
//
//- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
//	NSString *event = [NSString stringWithFormat:@"You are leaving t%@.", region.identifier];
//	[self updateWithEvent:event];
//}
//
//
//- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
//	NSString *event = [NSString stringWithFormat:@"Monitoring fail for %@", region.identifier];
//	[self updateWithEvent:event];
//}
//
//- (void)updateWithEvent:(NSString *)message {
//
//    // Update the icon badge number.
//	[UIApplication sharedApplication].applicationIconBadgeNumber++;
//
//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    localNotification.alertBody = message;
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
//    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
//}
//
//- (void)registerGeoFencing:(NSArray *)events
//{
//    // We dont' want to mointor those regions have been monitored
//    NSArray *monitoredRegions = [[locationManager monitoredRegions] allObjects];
//    // Define regions
//    [events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//
//        Event *event = (Event *)obj;
//
//        CLLocationCoordinate2D cord = CLLocationCoordinate2DMake([event.latitude doubleValue], [event.longitude doubleValue]);
//        //        CLLocationCoordinate2D cord = CLLocationCoordinate2DMake(30.359771, -97.746520);
//        CLRegion *whereRegion = [[CLRegion alloc] initCircularRegionWithCenter:cord radius:50.0 identifier:event.where];
//        if (![monitoredRegions containsObject:whereRegion]) {
//            [locationManager startMonitoringForRegion:whereRegion desiredAccuracy:kCLLocationAccuracyBest];
//        }
//    }];
//
//
//}
@end

