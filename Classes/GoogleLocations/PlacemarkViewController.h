//
//  PlacemarkViewController.h
//  HEBTest
//
//  Created by Liangjun Jiang on 1/17/12.
//  Copyright (c) 2012 LJ Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PlacemarkViewController : UIViewController
{
    NSArray *_placemarks;
    MKMapView *_mapView;
}

@property (nonatomic, strong) NSArray *placemarks;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

// designed initilizers

-(id)initWithPlacemarks:(NSArray *)placemarks;
 

#pragma mark - MKAnnotation Protocol (for map pin)


@end


