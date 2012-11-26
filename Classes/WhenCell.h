//
//  WhenCell.h
//  TaggedLocations
//
//  Created by LIANGJUN JIANG on 11/25/12.
//
//

#import <UIKit/UIKit.h>

@interface WhenCell : UITableViewCell
@property (nonatomic, strong) UITextField  *dateTextField;
@property (nonatomic, strong) UITextField  *timeTextField;

- (void)setContentForTableCellLabel:(NSString*)title Editing:(BOOL)isEditing;
@end
