//
//  PlacemarkViewController.m
//  HEBTest
//
//  Created by Liangjun Jiang on 1/17/12.
//  Copyright (c) 2012 LJ Apps. All rights reserved.
//

#import "PlacemarkViewController.h"
@interface MapViewAnnotation:NSObject<MKAnnotation>{
    CLLocationCoordinate2D coordinate;
    NSString *title;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
-(id)initWithTitle:(NSString*)mTitle withCoordinate:(CLLocationCoordinate2D )c2d;
@end


@implementation MapViewAnnotation
@synthesize coordinate, title;
-(id)initWithTitle:(NSString *)mTitle withCoordinate:(CLLocationCoordinate2D )c2d
{
    if (self=[super init])
    {
        coordinate = c2d;
        title = mTitle;
    }
    return self;
}


@end

@implementation PlacemarkViewController
@synthesize placemarks=_placemarks, mapView=_mapView;

#pragma MKAnnotation Delegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"H-E-B";
    MKPinAnnotationView *annotionView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    annotionView.enabled = YES;
    annotionView.canShowCallout = YES;
    
    return annotionView;
}
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *aV = views[0];
    id <MKAnnotation> mp = [aV annotation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 10000, 10000);
    [mapView setRegion:region];
    [mapView selectAnnotation:mp animated:YES];
}


#pragma init
-(id)initWithPlacemarks:(NSArray *)placemarks
{
    if (self = [super init])
    {    
        self.placemarks = placemarks;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Map";

    [self.placemarks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *currentObj = ((NSDictionary *)obj)[@"geometry"];
        CLLocationCoordinate2D location;
        
        location.latitude = [currentObj[@"location"][@"lat"] doubleValue];
        location.longitude = [currentObj[@"location"][@"lng"] doubleValue];
        MapViewAnnotation *aN = [[MapViewAnnotation alloc] initWithTitle:@"H-E-B" withCoordinate:location];
        [self.mapView addAnnotation:aN];
    }];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.mapView = nil;
    self.placemarks = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





@end
