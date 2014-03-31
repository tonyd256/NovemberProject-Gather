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
#import "NPGAppSession.h"
#import "NPGGroup.h"
#import "NPGRegisterViewController.h"
#import "NPGEditGroupViewController.h"
#import "NPGGroupFactory.h"

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
    [self.groups enumerateObjectsUsingBlock:^(NPGGroup *group, NSUInteger idx, BOOL *stop) {
        NPGAnnotation *annotation;

        if ([group.type isEqualToString:@"run"]) {
            annotation = [[NPGRunAnnotation alloc] initWithCoordinate:group.location];
            annotation.title = [NSString stringWithFormat:@"%d people running", group.people.count];
        } else if ([group.type isEqualToString:@"bike"]) {
            annotation = [[NPGBikeAnnotation alloc] initWithCoordinate:group.location];
            annotation.title = [NSString stringWithFormat:@"%d people biking", group.people.count];
        } else if ([group.type isEqualToString:@"car"]) {
            annotation = [[NPGCarAnnotation alloc] initWithCoordinate:group.location];
            annotation.title = [NSString stringWithFormat:@"%d people driving", group.people.count];
        }

        annotation.subtitle = [NSString stringWithFormat:@"Leaving at %@", group.time];

        [self.mapView addAnnotation:annotation];
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
    self.selectedGroup.people = [self.selectedGroup.people arrayByAddingObject:[[NPGAppSession sharedAppSession] currentUser]];
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
