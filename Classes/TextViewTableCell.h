//
//  TextViewTableCell.h
//  TaggedLocations
//
//  Created by LIANGJUN JIANG on 11/25/12.
//
//

#import <UIKit/UIKit.h>

@interface TextViewTableCell : UITableViewCell

@property (nonatomic, strong) UITextView *textView;

- (void)setContentForTableCellLabel:(NSString*)title andTextView:(NSString *)text andKeyBoardType:(NSNumber *)type andEnabled:(BOOL)enabled;
@end
