//
//  TextViewTableCell.m
//  TaggedLocations
//
//  Created by LIANGJUN JIANG on 11/25/12.
//
//

#import "NameCell.h"
#import <QuartzCore/QuartzCore.h>

#define kTextFieldWidth	140.0
#define kTextHeight		40.0
#define kPadding 5.0

@implementation NameCell
@synthesize textView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        textView = [[UITextView alloc] initWithFrame:CGRectMake(kPadding, kPadding, kTextFieldWidth, kTextHeight)];
        textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        // We also don't want to set the returnkey of keyboard "Done" for the TextView
        // because the user might just want to change to new line
        textView.returnKeyType = UIReturnKeyDefault;
        textView.keyboardType = UIKeyboardTypeDefault;
        textView.font = [UIFont systemFontOfSize:14.0f];
        textView.backgroundColor = [UIColor clearColor];
        textView.userInteractionEnabled = NO;
        [self.contentView addSubview:textView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentForTableCellLabel:(NSString*)title andTextView:(NSString *)text andKeyBoardType:(NSNumber *)type andEnabled:(BOOL)enabled
{
    self.textLabel.text = title;
    self.textView.text = text;
    self.textView.keyboardType = [type intValue];
    self.textView.layer.cornerRadius = 4.0f;
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderColor = (enabled)?[[UIColor redColor]CGColor]:[[UIColor clearColor]CGColor];
    self.textView.layer.borderWidth = 1.0f;
    self.textView.userInteractionEnabled = enabled;
    
}

- (void)setContentForTableCellTextView:(NSString *)text Editing:(BOOL)isEditing
{
    self.textView.text = text;
    self.textView.layer.cornerRadius = 4.0f;
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderColor = (isEditing)?[[UIColor redColor]CGColor]:[[UIColor clearColor]CGColor];
    self.textView.layer.borderWidth = 1.0f;
    self.textView.userInteractionEnabled = isEditing;
}

@end
