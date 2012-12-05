
/*
     File: TagSelectionController.h
 Abstract: The table view controller responsible for displaying all available tags.
 The controller is also given an Event object. Row for tags related to the event display a checkmark.  If the user taps a row, the corresponding tag is added to or removed from the event's tags relationship as appropriate.
 
  Version: 1.1
 
 Copyright (C) 2010 LJApps. All Rights Reserved.
 
 */

@class Event, EditableTableViewCell;

@interface TagSelectionController : UITableViewController <UITextFieldDelegate> {
	Event *event;
	NSMutableArray *tagsArray;
	
	UIView *headerView;
	UILabel *headerLabel;

	EditableTableViewCell *__weak editableTableViewCell;
}

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSMutableArray *tagsArray;

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UILabel *headerLabel;

@property (nonatomic, weak) IBOutlet EditableTableViewCell *editableTableViewCell;

- (void)insertTagAnimated:(BOOL)animated;

@end
