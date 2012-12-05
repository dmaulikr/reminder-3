//
//  SwitchTableCell.m
//  TempProject
//
//  Created by Liangjun Jiang on 10/26/12.
//  Copyright (c) 2012 Liangjun Jiang. All rights reserved.
//

#import "SwitchTableCell.h"

@implementation SwitchTableCell
@synthesize onOffSwitch;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGRect frame = CGRectMake(198.0, 12.0, 94.0, 27.0);
        onOffSwitch = [[UISwitch alloc] initWithFrame:frame];
        
        onOffSwitch.backgroundColor = [UIColor clearColor];
        self.accessoryView = onOffSwitch;
//        self.textLabel.font = [UIFont systemFontOfSize:14];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setSwitchStatus:(BOOL)enabled
{
    onOffSwitch.on = enabled;
    
}

- (void)onSwitch:(id)sender
{
    NSLog(@"switch on/off!");
    
}

@end
