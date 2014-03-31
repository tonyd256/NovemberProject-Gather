//
//  NPGMapViewController.m
//  Gather
//
//  Created by Tony DiPasquale on 3/10/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGMapViewController.h"
#import "NPGAnnotation.h"
#import "NPGAnnotationView.h"
#import "NPGAppSession.h"
#import "NPGGroup.h"
#import "NPGRegisterViewController.h"
#import "NPGEditGroupViewController.h"
#import "NPGGroupFactory.h"
#import "NPGDateFormatterFactory.h"
#import "NPGAnnotationFactory.h"

@interface NPGMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, NPGRegisterViewControllerDelegate, NPGEditGroupViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) NSArray *groups;
@property (nonatomic) CLLocationManager *manager;
@property (nonatomic) NPGGroup *selectedGroup;

@end

@implementation NPGMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.groups = [NSArray new];
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    self.manager.distanceFilter = 10;
    [self.manager startUpdatingLocation];
}

- (void)loadAnnotations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.groups enumerateObjectsUsingBlock:^(NPGGroup *group, NSUInteger idx, BOOL *stop) {
        [self.mapView addAnnotation:[NPGAnnotationFactory annotationWithGroup:group]];
    }];
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }

    self.selectedGroup = self.groups[[[self.mapView annotations] indexOfObject:view.annotation]];
    [self.mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    self.selectedGroup = nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (![[NPGAppSession sharedAppSession] isRegistered]) {
        [self performSegueWithIdentifier:@"NPGRegisterSegue" sender:self];
        return;
    }

    // join group
    self.selectedGroup.people = [self.selectedGroup.people arrayByAddingObject:[[NPGAppSession sharedAppSession] currentUser]];

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
        self.selectedGroup.people = [self.selectedGroup.people arrayByAddingObject:[[NPGAppSession sharedAppSession] currentUser]];
        // refresh this annotation view
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NPGEditGroupViewControllerDelegate

- (void)editGroupViewControllerDidFinish
{
    // save selected group
    self.groups = [self.groups arrayByAddingObject:[self.selectedGroup copy]];
    self.selectedGroup = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self loadAnnotations];
}

- (void)editGroupViewControllerDidCancel
{
    self.selectedGroup = nil;
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
        self.selectedGroup = [NPGGroupFactory createGroupWithLocation:self.mapView.centerCoordinate];
        viewController.group = self.selectedGroup;
        viewController.delegate = self;
    }
}

@end
