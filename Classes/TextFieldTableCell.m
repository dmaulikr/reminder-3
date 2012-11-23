//
//  TextFieldTableCell.m
//  LJTableViewTextFields
//
//  Created by Liangjun Jiang on 10/26/12.
//  Copyright (c) 2012 Liangjun Jiang. All rights reserved.
//

#import "TextFieldTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomTextField.h"

#define kLabelWidth	140.0
#define kTextFieldWidth	140.0
#define kTextHeight		34.0

@implementation TextFieldTableCell
@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect frame = CGRectMake(155, 5.0, kTextFieldWidth, kTextHeight);
        textField = [[CustomTextField alloc] initWithFrame:frame];
        textField.borderStyle = UITextBorderStyleNone;
        textField.textColor = [UIColor blackColor];
        textField.font = [UIFont systemFontOfSize:13.0];
        textField.textAlignment = NSTextAlignmentRight;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.enabled = NO;
        textField.backgroundColor = [UIColor clearColor];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
        
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

- (void)done:(id)sender
{
    [textField resignFirstResponder];
}


- (void)setContentForTableCellLabel:(NSString*)title andTextField:(NSString *)placeHolder andKeyBoardType:(NSNumber *)type andEnabled:(BOOL)enabled
{
    self.textLabel.text = title;
    self.textField.placeholder = placeHolder;
    self.textField.keyboardType = [type intValue];
    
    self.textField.layer.cornerRadius = 4.0f;
    self.textField.layer.masksToBounds = YES;
    self.textField.layer.borderColor = (enabled)?[[UIColor redColor]CGColor]:[[UIColor clearColor]CGColor];
    self.textField.layer.borderWidth = 1.0f;
    self.textField.enabled = enabled;

}
@end
