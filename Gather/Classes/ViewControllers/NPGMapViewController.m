//
//  NPGMapViewController.m
//  Gather
//
//  Created by Tony DiPasquale on 3/10/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGMapViewController.h"
#import "NPGAnnotation.h"
#import "NPGRunAnnotation.h"
#import "NPGBikeAnnotation.h"
#import "NPGCarAnnotation.h"
#import "NPGAnnotationView.h"

@interface NPGMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>

@property (nonatomic) NSArray *groups;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) CLLocationManager *manager;

@end

@implementation NPGMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.groups = @[@{@"latitude": @42.33553,
                      @"longitude": @-71.04195,
                      @"type": @"car"},
                    @{@"latitude": @42.33674,
                      @"longitude": @-71.04757,
                      @"type": @"bike"},
                    @{@"latitude": @42.33504,
                      @"longitude": @-71.05203,
                      @"type": @"run"},
                    @{@"latitude": @42.34334,
                      @"longitude": @-71.07847,
                      @"type": @"car"},
                    @{@"latitude": @42.35434,
                      @"longitude": @-71.06553,
                      @"type": @"bike"},
                    @{@"latitude": @42.36527,
                      @"longitude": @-71.05536,
                      @"type": @"run"},
                    @{@"latitude": @42.33915,
                      @"longitude": @-71.09199,
                      @"type": @"run"}];

    [self.groups enumerateObjectsUsingBlock:^(NSDictionary *group, NSUInteger idx, BOOL *stop) {
        NPGAnnotation *annotation;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([group[@"latitude"] doubleValue], [group[@"longitude"] doubleValue]);

        if ([group[@"type"] isEqualToString:@"run"]) {
            annotation = [[NPGRunAnnotation alloc] initWithCoordinate:coordinate];
        } else if ([group[@"type"] isEqualToString:@"bike"]) {
            annotation = [[NPGBikeAnnotation alloc] initWithCoordinate:coordinate];
        } else if ([group[@"type"] isEqualToString:@"car"]) {
            annotation = [[NPGCarAnnotation alloc] initWithCoordinate:coordinate];
        }

        [self.mapView addAnnotation:annotation];
    }];

    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    self.manager.distanceFilter = 10;
    [self.manager startUpdatingLocation];
}

#pragma mark - MKMapViewDelegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(NPGAnnotation *)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    NPGAnnotationView *view = (NPGAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"NPGAnnotationView"];

    if (!view) {
        view = [[NPGAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"NPGAnnotationView"];
    } else {
        view.annotation = annotation;
    }

    return view;
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSDate *date = location.timestamp;
    NSTimeInterval interval = [date timeIntervalSinceNow];

    if (abs(interval) < 15.0) {
        self.mapView.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.1, 0.1));
    }

    [self.manager stopUpdatingLocation];
    self.manager.delegate = nil;
    self.manager = nil;
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%@", @(buttonIndex));
}

#pragma mark - Action Methods

- (IBAction)didTapNewGroup
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"How are you getting there?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Running", @"Biking", @"Driving", nil];

    [sheet showInView:self.view];
}

@end
