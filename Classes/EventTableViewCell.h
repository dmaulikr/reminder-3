
/*
     File: EventTableViewCell.h
 Abstract: Table view cell to display information about an event.
 The cell layout is defined in the accompanying nib file -- EventTableViewCell.
 Cells are loaded by the root view controller (the File's Owner), which is the target of the tags button's action.
 
  Version: 1.1
 
 Copyright (C) 2010 LJApps. All Rights Reserved.
 
 */

@interface EventTableViewCell : UITableViewCell {
	UITextField *nameField;
	UILabel *creationDateLabel;
	UILabel *expiredDateLabel;
	UITextField *tagsField;
	UIButton *tagsButton;
}

@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) IBOutlet UILabel *creationDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *expiredDateLabel;
@property (nonatomic, strong) IBOutlet UITextField *tagsField;
@property (nonatomic, strong) IBOutlet UIButton *tagsButton;

@end
