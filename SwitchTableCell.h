//
//  SwitchTableCell.h
//  TempProject
//
//  Created by Liangjun Jiang on 10/26/12.
//  Copyright (c) 2012 Liangjun Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchTableCell : UITableViewCell

@property (nonatomic,strong) UISwitch *onOffSwitch;

- (void)setSwitchStatus:(BOOL)enabled;
@end
