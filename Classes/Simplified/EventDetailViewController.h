//
//  VaFeedbackViewController.h
//  VaTouch
//
//  Created by Liangjun Jiang on 11/15/12.
//  Copyright (c) 2012 LJ Apps All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventDetailViewController;
@class Event;
typedef void(^EventDetailViewControllerResponse)(EventDetailViewController *controller, Event *anEvent);


@class Event;
@interface EventDetailViewController : UITableViewController

@property (nonatomic, copy) EventDetailViewControllerResponse cancelBlock;
@property (nonatomic, copy) EventDetailViewControllerResponse saveBlock;

@property (nonatomic, strong) Event *event;
@end
