
/*
     File: EventTableViewCell.m
 Abstract: Table view cell to display information about an event.
 The cell layout is defined in the accompanying nib file -- EventTableViewCell.
 Cells are loaded by the root view controller (the File's Owner), which is the target of the tags button's action.
 
  Version: 1.1
 
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "EventTableViewCell.h"


@implementation EventTableViewCell

@synthesize nameField, creationDateLabel, expiredDateLabel, tagsField, tagsButton;

/*
 When the table view becomes editable, the cell should:
 * Hide the location label (so that the Delete button does not overlap it)
 * Enable the name field (to make it editable)
 * Display the tags button
 * Set a placeholder for the tags field (so the user knows to tap to edit tags)
 The inverse applies when the table view has finished editing.
 */
 
- (void)willTransitionToState:(UITableViewCellStateMask)state {
	[super willTransitionToState:state];
	
	if (state & UITableViewCellStateEditingMask) {
		expiredDateLabel.hidden = YES;
		nameField.enabled = YES;
		tagsButton.hidden = NO;
		tagsField.placeholder = @"Tap to edit tags";
	}
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
	[super didTransitionToState:state];
	
	if (!(state & UITableViewCellStateEditingMask)) {
		expiredDateLabel.hidden = YES;
		nameField.enabled = NO;
		tagsButton.hidden = YES;
		tagsField.placeholder = @"";
	}
}




@end
