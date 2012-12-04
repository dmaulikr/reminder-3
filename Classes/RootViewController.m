
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
#import "ItemDetailViewController.h"
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
	
	
	// Configure the add and edit buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *aButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
	self.addButton = aButton;
	
	addButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = addButton;
    
    // detect shake
    [self becomeFirstResponder];
    
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
    
    cell.expiredDateLabel.text = event.expired;
	
//	NSString *string = [NSString stringWithFormat:@"%@, %@",
//						[numberFormatter stringFromNumber:[event latitude]],
//						[numberFormatter stringFromNumber:[event longitude]]];
//    cell.locationLabel.text = string;
    
//    cell.backgroundColor =  [UIColor scrollViewTexturedBackgroundColor];
	
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

	
    
    [[[UIAlertView alloc] initWithTitle:@"Set Geo-fencing?"
                                message:@"You mentioned a location?"
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"No", @"No")
                      otherButtonTitles:@"Yes", nil] show];
    
//    [self showEvent:event animated:YES];
}


#pragma mark - Alertview delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int row = [self.tableView indexPathForSelectedRow].row;
    Event *event;
    if (self.tableView == self.searchDisplayController.searchResultsTableView)
    {
        event = (self.filteredListContent)[row];
    }
    else
    {
        event = (Event *)eventsArray[row];
    }
    
    if (buttonIndex == alertView.cancelButtonIndex) {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        
        //TODO: MAKE SURE THOSE ALERT WON'T SHOW AGAIN ONCE THE USER SELECTS NO
//        int row = [self.tableView indexPathForSelectedRow].row;
        //        [self addShow:[shows objectAtIndex:row]
        //           toCalendar: [AppCalendar calendar]];
        
        EKEventStore *store = [AppCalendar eventStore];
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
                                                                                          eventStore:[AppCalendar eventStore] ];
                    chooseCal.delegate = self;
                    chooseCal.showsDoneButton = YES;
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showWithStatus:@"Loading"];
                        [self.navigationController presentViewController:chooseCal animated:YES completion:^{
                            [SVProgressHUD dismiss];
                        }];
                    });
                    
//                    [self.navigationController pushViewController:chooseCal animated:YES];
                    
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Oops"
                                                message:@"The app needs to use your calendar"
                                               delegate:self
                                      cancelButtonTitle:@"Okay"
                                      otherButtonTitles:nil] show];
                    
                }
            }
        }];

    } else {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LocationStoryboard" bundle:nil];
        UINavigationController *controller = [storyBoard instantiateInitialViewController];
        PlaceSearchViewController *searchViewController = (PlaceSearchViewController*)controller.viewControllers[0];
        
        event.where = @"target";
        NSLog(@"where it is? %@",event.where);
        searchViewController.searchString = event.where;
        [self presentViewController:controller animated:YES completion:nil];
    }
    
//    if (buttonIndex==0) {
//        //show calendar chooser view controller
//        EKCalendarChooser* chooseCal = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleSingle
//                                                                            displayStyle:EKCalendarChooserDisplayWritableCalendarsOnly
//                                                                              eventStore:[AppCalendar eventStore] ];
//        chooseCal.delegate = self;
//        chooseCal.showsDoneButton = YES;
//        [self.navigationController pushViewController:chooseCal animated:YES];
//    } else if (buttonIndex == 1) {
//        //use the app's default calendar
//        
//        
//        [self addReminder:event
//           toCalendar: [AppCalendar calendar]];
//    } else if (buttonIndex == 2) {
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LocationStoryboard" bundle:nil];
//        UINavigationController *controller = [storyBoard instantiateInitialViewController];
//        PlaceSearchViewController *searchViewController = (PlaceSearchViewController*)controller.viewControllers[0];
//        
//        event.where = @"target";
//        NSLog(@"where it is? %@",event.where);
//        searchViewController.searchString = event.where;
//        [self presentViewController:controller animated:YES completion:nil];
//    }
 
}

#pragma mark - Calendar methods

-(void)addShow:(Event*)reminder toEventStore:(EKEventStore *)store toCalendar:(EKCalendar*)calendar

//-(void)addReminder:(Event*)reminder toCalendar:(EKCalendar*)calendar
{
    EKEventStore *es = [AppCalendar eventStore];
    
    //TODO: NEED TO BE FIXED
    [es requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        /* This code will run when uses has made his/her choice */
        
        NSString *message = @"";
        if (error !=nil){
            message = [error localizedDescription];
        } else {
            if (granted) {
                EKEvent* event = [EKEvent eventWithEventStore:es];
                event.calendar = calendar;
                
                EKAlarm* myAlarm = [EKAlarm alarmWithRelativeOffset: - 06*60 ];  // reminder in 6 mins before
                [event addAlarm: myAlarm];
                
                NSDateFormatter* frm = [[NSDateFormatter alloc] init];
                [frm setDateFormat:@"MM/dd/yyyy HH:mm zzz"];
                [frm setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                
                // Set up the content
                Event *localReminder = reminder;
                
                NSString *question = @"Remind to use coupon when entering Walmart at 5 pm, tomorrow.";
                
                localReminder.name = question;
                
                NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
                NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
                tagger.string = question;
                
                // I need a better algorithm for this
                __block NSMutableArray *tagArrays = [NSMutableArray array];
                [tagger enumerateTagsInRange:NSMakeRange(0, [question length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                    NSString *token = [question substringWithRange:tokenRange];
                    NSDictionary *dict = @{@"tag":tag, @"token":token};
                    [tagArrays addObject:dict];
                }];
                
                // I know this is stupid
                __block NSUInteger conjunctionIndex = 0;
                __block NSUInteger particleIndex = 0;
                __block NSUInteger prepositionIndex = 0;
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
                //    NSLog(@"par:%d, con:%d,  prep: %d",particleIndex, conjunctionIndex, prepositionIndex);
                //
                //
                __block NSMutableString *whatString = [NSMutableString string];
                
                if  (conjunctionIndex - (particleIndex+1) > 0)
                {
                    NSRange whatRange = NSMakeRange(particleIndex+1, conjunctionIndex-(particleIndex+ 1));
                    NSArray *whatArray = [tagArrays objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:whatRange]];
                    
                    if (whatArray.count>0) {
                        [whatArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [whatString appendString:[NSString stringWithFormat:@"%@ ",((NSDictionary *)obj)[@"token"]]];
                        }];
                    }
                    NSLog(@"what :%@",whatString);
                    localReminder.what = whatString;
                }
                
                __block NSMutableString *whereString = [NSMutableString string];
                if (prepositionIndex-(conjunctionIndex+1) > 0) {
                    NSRange whereRange = NSMakeRange(conjunctionIndex+1, prepositionIndex-(conjunctionIndex+ 1));
                    NSArray *whereArray = [tagArrays objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:whereRange]];
                    if (whereArray.count>0) {
                        [whereArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [whereString appendString:[NSString stringWithFormat:@"%@ ",((NSDictionary *)obj)[@"token"]]];
                        }];
                    }
                    NSLog(@"where :%@",whereString);
                    localReminder.where = whereString;
                }
                
                __block NSMutableString *whenString = [NSMutableString string];
                if (tagArrays.count-(prepositionIndex+1) > 0) {
                    NSRange whenRange = NSMakeRange(prepositionIndex+1, tagArrays.count-(prepositionIndex+ 1));
                    NSArray *whenArray = [tagArrays objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:whenRange]];
                    if (whenArray.count>0) {
                        [whenArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [whenString appendString:[NSString stringWithFormat:@"%@ ",((NSDictionary *)obj)[@"token"]]];
                        }];
                    }
                    NSLog(@"when :%@",whenString);
                    localReminder.when = whenString;
                }
                
                
                //    event.startDate = [frm dateFromString: [show objectForKey:@"startDate"]];
                //    event.endDate   = [frm dateFromString: [show objectForKey:@"endDate"]];
                
                event.title = localReminder.name; //[show objectForKey:@"title"];
                //    event.URL = [NSURL URLWithString:[show objectForKey:@"url"]];
                event.location = localReminder.where; //@"The living room";
                event.notes = localReminder.how ;
                //    event.notes = [show objectForKey:@"tip"];
                
                
                // this is how we want to set up the how.
                NSNumber* weekDay = [NSNumber numberWithInt:1]; //[show objectForKey:@"dayOfTheWeek"];
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
                [[AppCalendar eventStore] saveEvent:event span:EKSpanFutureEvents commit:YES error:&error];
                
                //2 show the edit event dialogue
                EKEventEditViewController* editEvent = [[EKEventEditViewController alloc] init];
                editEvent.eventStore = [AppCalendar eventStore];
                editEvent.event = event;
                editEvent.editViewDelegate = self;
                [self presentViewController:editEvent animated:YES completion:^{
//                    UINavigationItem* item = [editEvent.navigationBar.items objectAtIndex:0];
//                    item.leftBarButtonItem = nil;
                }];

            } else {
                message = @"Please accept the request to use the app";
            }
        }
        
        if (message.length > 0) {
            [[[UIAlertView alloc] initWithTitle:@"Oops"
                                        message:message
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                              otherButtonTitles:nil] show];

        }
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
            NSLog(@"returned event: %@",returnedEvent);
            NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
            
            // need to update this one
            Event *event = eventsArray[selectedPath.row];
            event.name = returnedEvent.title;
            event.expired = [self relativeDate:returnedEvent.endDate];
            
            // Commit the change.
            NSError *error;
            if (![managedObjectContext save:&error]) {
                // Handle the error.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                exit(-1);  // Fail
            }

            // then we update the view
            [self.tableView reloadRowsAtIndexPaths:@[selectedPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        
        default:break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    // let's update the database & update the tableview
}

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
        [self addShow:event toEventStore:[AppCalendar eventStore] toCalendar:selectedCalendar];
    });

//    [self addReminder:event
//           toCalendar: selectedCalendar];
    //4
    [self.navigationController popViewControllerAnimated:YES];
}

//#pragma mark - Show Event
//- (void)showEvent:(Event *)event animated:(BOOL)animated {
//    ItemDetailViewController *eventDetailViewController = [[ItemDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    eventDetailViewController.event = event;
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:eventDetailViewController];
//    [self presentViewController:navController animated:YES completion:nil];
//}

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

#pragma mark - Region Managerment

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
	NSString *event = [NSString stringWithFormat:@"You are entering %@.", region.identifier];
	[self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	NSString *event = [NSString stringWithFormat:@"You are leaving t%@.", region.identifier];
	[self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	NSString *event = [NSString stringWithFormat:@"Monitoring fail for %@", region.identifier];
	[self updateWithEvent:event];
}

- (void)updateWithEvent:(NSString *)message {
    
    // Update the icon badge number.
	[UIApplication sharedApplication].applicationIconBadgeNumber++;
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = message;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)registerGeoFencing:(NSArray *)events
{
    // We dont' want to mointor those regions have been monitored
    NSArray *monitoredRegions = [[locationManager monitoredRegions] allObjects];
    // Define regions
    [events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        Event *event = (Event *)obj;
        
        CLLocationCoordinate2D cord = CLLocationCoordinate2DMake([event.latitude doubleValue], [event.longitude doubleValue]);
        //        CLLocationCoordinate2D cord = CLLocationCoordinate2DMake(30.359771, -97.746520);
        CLRegion *whereRegion = [[CLRegion alloc] initCircularRegionWithCenter:cord radius:50.0 identifier:event.where];
        if (![monitoredRegions containsObject:whereRegion]) {
            [locationManager startMonitoringForRegion:whereRegion desiredAccuracy:kCLLocationAccuracyBest];
        }
    }];
    
    
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
        }
//        else if ([scope isEqualToString:@"Label"]){
//            NSRange descriptionRange = [name rangeOfString:searchText options:NSCaseInsensitiveSearch];
//            if(descriptionRange.location != NSNotFound)
//            {
//                [self.filteredListContent addObject:event];
//            }
//            
//        }
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

#pragma mark - Sort options
- (BOOL)canBecomeFirstResponder
{
    return YES;
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sort By" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Status",@"Expired Time",@"Name",@"Prority", nil];
        actionSheet.destructiveButtonIndex = 3; // Priority will be highlighted
        [actionSheet showInView:self.tableView];

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

@end

