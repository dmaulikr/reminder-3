//
//  LocationCell.m
//  TaggedLocations
//
//  Created by LIANGJUN JIANG on 11/25/12.
//
//

#import "WhereCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomTextField.h"

#define kLabelWidth	140.0
#define kTextFieldWidth	220.0
#define kTextHeight		20.0
#define kPadding 2.0

@implementation WhereCell
@synthesize nameTextField, addressButton;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGRect frame = CGRectMake(80, kPadding, kTextFieldWidth, kTextHeight);
        nameTextField = [[CustomTextField alloc] initWithFrame:frame];
        nameTextField.borderStyle = UITextBorderStyleNone;
        nameTextField.textColor = [UIColor blackColor];
        nameTextField.font = [UIFont systemFontOfSize:13.0];
        nameTextField.textAlignment = NSTextAlignmentLeft;
        nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        nameTextField.enabled = NO;
        nameTextField.backgroundColor = [UIColor clearColor];
        nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
        
        nameTextField.returnKeyType = UIReturnKeyDone;
        nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
        [self.contentView addSubview:nameTextField];
        addressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addressButton.frame = CGRectMake(155.0, kTextHeight+2*kPadding, kTextFieldWidth, kTextHeight);
        [self.contentView addSubview:addressButton];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentForTableCellLabel:(NSString*)title andTextField:(NSString *)text andEnabled:(BOOL)enabled
{
    self.textLabel.text = title;
    self.nameTextField.text = text;
    
    self.nameTextField.layer.cornerRadius = 4.0f;
    self.nameTextField.layer.masksToBounds = YES;
    self.nameTextField.layer.borderColor = (enabled)?[[UIColor redColor]CGColor]:[[UIColor clearColor]CGColor];
    self.nameTextField.layer.borderWidth = 1.0f;
    self.nameTextField.enabled = enabled;
    
}


@end
