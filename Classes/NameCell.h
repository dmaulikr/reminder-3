//
//  TextViewTableCell.h
//  TaggedLocations
//
//  Created by LIANGJUN JIANG on 11/25/12.
//
//

#import <UIKit/UIKit.h>

@interface NameCell : UITableViewCell

@property (nonatomic, strong) UITextView *textView;

- (void)setContentForTableCellTextView:(NSString *)text Editing:(BOOL)isEditing;
@end
