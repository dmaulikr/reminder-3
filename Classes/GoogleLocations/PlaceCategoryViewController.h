//
//  PlaceCategoryViewController.h
//  Reminder
//
//  Created by LIANGJUN JIANG on 12/4/12.
//
//

#import <UIKit/UIKit.h>

@class PlaceCategoryViewController;
typedef void(^PlaceCategoryViewControllerResponse)(PlaceCategoryViewController *controller, NSString *cat);

@interface PlaceCategoryViewController : UITableViewController{
    PlaceCategoryViewControllerResponse cancelBlock_;
    PlaceCategoryViewControllerResponse saveBlock_;
    
}

@property (nonatomic, copy) PlaceCategoryViewControllerResponse cancelBlock;
@property (nonatomic, copy) PlaceCategoryViewControllerResponse saveBlock;

@end
