
/*
     File: EditableTableViewCell.h
 Abstract: Table view cell to present an editable text field to display tag names.
 The cell layout is defined in the accompanying nib file -- EditableTableViewCell.
 
  Version: 1.1
 
  
 Copyright (C) 2010 LJApps. All Rights Reserved.
 
 */


@interface EditableTableViewCell : UITableViewCell {
	UITextField *textField;
}

@property (nonatomic, strong) IBOutlet UITextField *textField;

@end
