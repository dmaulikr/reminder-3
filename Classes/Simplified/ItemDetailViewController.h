//
//  ItemDetailViewController.h

//
//  Created by Liangjun Jiang on 10/26/12.
//  Copyright (c) 2012 Liangjun Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GooglePlacesConnection.h"

@class Event;
@interface ItemDetailViewController : UITableViewController
{
    CLLocation              *currentLocation;
    GooglePlacesConnection  *googlePlacesConnection;
}
@property (nonatomic, strong) Event *event;
@property (nonatomic, getter = isResultsLoaded) BOOL resultsLoaded;

@property (nonatomic, retain) CLLocation        *currentLocation;

@property (nonatomic, retain) NSMutableArray    *locations;
@property (nonatomic, retain) NSMutableArray    *locationsFilterResults;

-(void)buildSearchArrayFrom:(NSString *)matchString;
@end
