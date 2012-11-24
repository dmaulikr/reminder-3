
/*
     File: EditableTableViewCell.m
 Abstract: Table view cell to present an editable text field to display tag names.
 The cell layout is defined in the accompanying nib file -- EditableTableViewCell.
 
  Version: 1.1
 
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "EditableTableViewCell.h"

@implementation EditableTableViewCell

@synthesize textField;


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	// The user can only edit the text field when in editing mode.
    [super setEditing:editing animated:animated];
	textField.enabled = editing;
}




@end
