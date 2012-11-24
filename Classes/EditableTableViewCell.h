
/*
     File: EditableTableViewCell.h
 Abstract: Table view cell to present an editable text field to display tag names.
 The cell layout is defined in the accompanying nib file -- EditableTableViewCell.
 
  Version: 1.1
 
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */


@interface EditableTableViewCell : UITableViewCell {
	UITextField *textField;
}

@property (nonatomic, strong) IBOutlet UITextField *textField;

@end
