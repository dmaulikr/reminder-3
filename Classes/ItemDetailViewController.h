//
//  ItemDetailViewController.h

//
//  Created by Liangjun Jiang on 10/26/12.
//  Copyright (c) 2012 Liangjun Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;
@interface ItemDetailViewController : UITableViewController

@property (nonatomic, strong) Event *event;
@end
