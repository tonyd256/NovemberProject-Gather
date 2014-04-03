//
//  NPGMapViewController.m
//  Gather
//
//  Created by Tony DiPasquale on 3/10/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "NPGMapViewController.h"
#import "NPGAppSession.h"
#import "NPGGroup.h"
#import "NPGRegisterViewController.h"
#import "NPGEditGroupViewController.h"
#import "NPGGroupFactory.h"
#import "NPGMapViewDelegate.h"

@interface NPGMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, NPGRegisterViewControllerDelegate, NPGEditGroupViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) NSArray *groups;
@property (nonatomic) CLLocationManager *manager;
@property (nonatomic) NPGMapViewDelegate *mapViewDelegate;

@end

@implementation NPGMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.groups = [NSArray new];
    self.mapViewDelegate = [NPGMapViewDelegate new];
    self.mapView.delegate = self.mapViewDelegate;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationCalloutAccessoryTapped) name:NPGAnnotationCalloutAccessoryTappedNotification object:nil];

    self.manager = [CLLocationManager new];
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    self.manager.distanceFilter = 10;
    [self.manager startUpdatingLocation];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

- (void)loadAnnotations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.groups enumerateObjectsUsingBlock:^(NPGGroup *group, NSUInteger idx, BOOL *stop) {
        [self.mapView addAnnotation:group];
    }];
}

#pragma mark - NPGMapViewDelegate Notification Methods

- (void)annotationCalloutAccessoryTapped
{
    if (![[NPGAppSession sharedAppSession] isRegistered]) {
        [self performSegueWithIdentifier:@"NPGRegisterSegue" sender:self];
        return;
    }

    // join group
    NPGGroup *group = [[self.mapView selectedAnnotations] firstObject];
    group.people = [group.people arrayByAddingObject:[[NPGAppSession sharedAppSession] currentUser]];
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSDate *date = location.timestamp;
    NSTimeInterval interval = [date timeIntervalSinceNow];

    if (abs(interval) < 15.0) {
        self.mapView.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.02, 0.02));
    }

    if (location.horizontalAccuracy < 0 || location.horizontalAccuracy > 25) return;

    [self.manager stopUpdatingLocation];
    self.manager.delegate = nil;
    self.manager = nil;
}

#pragma mark - NPGRegisterViewControllerDelegate

- (void)registerViewControllerDidFinish
{
    // add current user to selected group
    if ([[NPGAppSession sharedAppSession] isRegistered]) {
        NPGGroup *group = [[self.mapView selectedAnnotations] firstObject];
        group.people = [group.people arrayByAddingObject:[[NPGAppSession sharedAppSession] currentUser]];
        // refresh this annotation view
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NPGEditGroupViewControllerDelegate

- (void)editGroupViewControllerDidSaveGroup:(NPGGroup *)group
{
    // save selected group
    self.groups = [self.groups arrayByAddingObject:group];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self loadAnnotations];
}

- (void)editGroupViewControllerDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Transition Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NPGRegisterSegue"]) {
        NPGRegisterViewController *viewController = segue.destinationViewController;
        viewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"NPGEditGroupSegue"]) {
        NPGEditGroupViewController *viewController = segue.destinationViewController;
        viewController.group = [NPGGroupFactory createGroupWithLocation:self.mapView.centerCoordinate];
        viewController.delegate = self;
    }
}

@end
