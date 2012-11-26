//
//  TextFieldTableCell.m
//  LJTableViewTextFields
//
//  Created by Liangjun Jiang on 10/26/12.
//  Copyright (c) 2012 Liangjun Jiang. All rights reserved.
//

#import "WhatCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomTextField.h"

#define kLabelWidth	140.0
#define kTextFieldWidth	220.0
#define kTextHeight		34.0

@implementation WhatCell
@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect frame = CGRectMake(80, 5.0, kTextFieldWidth, kTextHeight);
        textField = [[UITextField alloc] initWithFrame:frame];
        textField.borderStyle = UITextBorderStyleNone;
        textField.textColor = [UIColor blackColor];
        textField.font = [UIFont systemFontOfSize:13.0];
        textField.textAlignment = NSTextAlignmentLeft;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.enabled = NO;
        textField.backgroundColor = [UIColor clearColor];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
        
        self.accessoryView = textField;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setContentForTableCellLabel:(NSString*)title andTextField:(NSString *)text  andEnabled:(BOOL)enabled
{
    self.textLabel.text = title;
    self.textField.text = text;
    self.textField.layer.cornerRadius = 4.0f;
    self.textField.layer.masksToBounds = YES;
    self.textField.layer.borderColor = (enabled)?[[UIColor redColor]CGColor]:[[UIColor clearColor]CGColor];
    self.textField.layer.borderWidth = 1.0f;
    self.textField.enabled = enabled;

}
@end
