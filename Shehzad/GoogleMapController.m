//
//  GoogleMapController.m
//  Shehzad
//
//  Created by Shehzad Bilal on 05/04/2017.
//  Copyright © 2017 Shehzad Bilal. All rights reserved.
//

#import "GoogleMapController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface GoogleMapController () <CLLocationManagerDelegate,GMSMapViewDelegate> {
    CLLocationManager *locationManager;
    GMSMapView *mapView;
    UILongPressGestureRecognizer *longPress;
    GMSMarker *marker1;
    GMSMarker *marker2;
}

@end

@implementation GoogleMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    [self loadMapView];
}

- (void)loadMapView {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.delegate = self;
    self.view = mapView;
}

-(void)mapView:(GMSMapView *)mView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (marker1 && marker2) {
        marker1 = nil;
        marker2 = nil;
        [mapView clear];
    } else if(marker1) {
        marker2 = [[GMSMarker alloc] init];
        marker2.position = coordinate;
        marker2.map = mapView;
        
        //Map Path between marker1 and marker2
        [self drawRoute];
    } else {
        marker1 = [[GMSMarker alloc] init];
        marker1.position = coordinate;
        marker1.map = mapView;
    }
    
}

- (void)drawRoute
{
    [self fetchPolylineWithOrigin:marker1.position destination:marker2.position completionHandler:^(GMSPolyline *polyline)
     {
         if(polyline) {
             polyline.map = mapView;
         }
     }];
}

- (void)fetchPolylineWithOrigin:(CLLocationCoordinate2D)origin destination:(CLLocationCoordinate2D)destination completionHandler:(void (^)(GMSPolyline *))completionHandler
{
    NSString *originString = [NSString stringWithFormat:@"%f,%f", origin.latitude, origin.longitude];
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f", destination.latitude, destination.longitude];
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/directions/json?";
    NSString *directionsUrlString = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&mode=driving", directionsAPI, originString, destinationString];
    NSURL *directionsUrl = [NSURL URLWithString:directionsUrlString];
    
    
    NSURLSessionDataTask *fetchDirectionsTask = [[NSURLSession sharedSession] dataTaskWithURL:directionsUrl completionHandler:
                                                 ^(NSData *data, NSURLResponse *response, NSError *error)
                                                 {
                                                     NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                     if(error)
                                                     {
                                                         if(completionHandler)
                                                             completionHandler(nil);
                                                         return;
                                                     }
                                                     
                                                     NSArray *routesArray = [json objectForKey:@"routes"];
                                                     dispatch_sync(dispatch_get_main_queue(), ^{
                                                         GMSPolyline *polyline = nil;
                                                         if ([routesArray count] > 0)
                                                         {
                                                             
                                                             
                                                                 NSDictionary *routeDict = [routesArray objectAtIndex:0];
                                                                 NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                                                                 NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                                                                 GMSPath *path = [GMSPath pathFromEncodedPath:points];
                                                                 polyline = [GMSPolyline polylineWithPath:path];
                                                             
                                                         }
                                                     
                                                         if(completionHandler)
                                                             completionHandler(polyline);
                                                     });
                                                 }];
    [fetchDirectionsTask resume];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject;
    [locationManager stopUpdatingLocation];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                            longitude:location.coordinate.longitude
                                                                 zoom:15];
    [mapView animateToCameraPosition:camera];
}

@end
