//
//  WhenCell.m
//  TaggedLocations
//
//  Created by LIANGJUN JIANG on 11/25/12.
//
//

#import "WhenCell.h"
#import "CustomTextField.h"
#import <QuartzCore/QuartzCore.h>

#define kTextFieldWidth	210.0
#define kTextHeight		20.0
#define kPadding 2.0

@implementation WhenCell
@synthesize dateTextField, timeTextField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGRect frame = CGRectMake(80, kPadding, kTextFieldWidth, kTextHeight);
        dateTextField = [[UITextField alloc] initWithFrame:frame];
        dateTextField.borderStyle = UITextBorderStyleNone;
        dateTextField.textColor = [UIColor blackColor];
        dateTextField.font = [UIFont systemFontOfSize:13.0];
        dateTextField.textAlignment = NSTextAlignmentRight;
        dateTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        dateTextField.enabled = NO;
        dateTextField.backgroundColor = [UIColor clearColor];
        dateTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
        
        dateTextField.returnKeyType = UIReturnKeyDone;
        dateTextField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
        [self addSubview:dateTextField];
        
        timeTextField = [[CustomTextField alloc] initWithFrame:frame];
        timeTextField.borderStyle = UITextBorderStyleNone;
        timeTextField.textColor = [UIColor blackColor];
        timeTextField.font = [UIFont systemFontOfSize:13.0];
        timeTextField.textAlignment = NSTextAlignmentLeft;
        timeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        timeTextField.enabled = NO;
        timeTextField.backgroundColor = [UIColor clearColor];
        timeTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
        
        timeTextField.returnKeyType = UIReturnKeyDone;
        timeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
        [self addSubview:timeTextField];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    

}

- (void)setContentForTableCellLabel:(NSString*)title Editing:(BOOL)isEditing
{
    self.textLabel.text = title;
    self.dateTextField.layer.cornerRadius = 4.0f;
    self.dateTextField.layer.masksToBounds = YES;
    self.dateTextField.layer.borderColor = (isEditing)?[[UIColor redColor]CGColor]:[[UIColor clearColor]CGColor];
    self.dateTextField.layer.borderWidth = 1.0f;
    self.dateTextField.enabled = isEditing;
    
    self.timeTextField.layer.cornerRadius = 4.0f;
    self.timeTextField.layer.masksToBounds = YES;
    self.timeTextField.layer.borderColor = (isEditing)?[[UIColor redColor]CGColor]:[[UIColor clearColor]CGColor];
    self.timeTextField.layer.borderWidth = 1.0f;
    self.timeTextField.enabled = isEditing;
    
    
}

@end
