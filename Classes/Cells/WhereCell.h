//
//  LocationCell.h
//  TaggedLocations
//
//  Created by LIANGJUN JIANG on 11/25/12.
//
//

#import <UIKit/UIKit.h>

@interface WhereCell : UITableViewCell

@property (nonatomic, strong) UITextField  *nameTextField;
@property (nonatomic, strong) UIButton  *addressButton;

- (void)setContentForTableCellLabel:(NSString*)title andTextField:(NSString *)text andEnabled:(BOOL)enabled;
@end
