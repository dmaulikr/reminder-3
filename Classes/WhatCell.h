//
//  TextFieldTableCell.h
//  LJTableViewTextFields
//
//  Created by Liangjun Jiang on 10/26/12.
//  Copyright (c) 2012 Liangjun Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomTextField;
@interface WhatCell : UITableViewCell

@property (nonatomic, strong) UITextField *textField;

- (void)setContentForTableCellLabel:(NSString*)title andTextField:(NSString *)text  andEnabled:(BOOL)enabled;

@end
