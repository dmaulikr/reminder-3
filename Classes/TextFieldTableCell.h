//
//  TextFieldTableCell.h
//  LJTableViewTextFields
//
//  Created by Liangjun Jiang on 10/26/12.
//  Copyright (c) 2012 Liangjun Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomTextField;
@interface TextFieldTableCell : UITableViewCell

@property (nonatomic, strong) CustomTextField *textField;

- (void)setContentForTableCellLabel:(NSString*)title andTextField:(NSString *)placeHolder andKeyBoardType:(NSNumber *)type andEnabled:(BOOL)enabled;

@end
