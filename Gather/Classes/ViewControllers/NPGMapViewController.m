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
#import "NPGAPIClient.h"

static NSString *const NPGEditGroupActionKey = @"NPGEditGroupActionKey";
static NSString *const NPGJoinGroupActionKey = @"NPGJoinGroupActionKey";

@interface NPGMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, NPGRegisterViewControllerDelegate, NPGEditGroupViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) NSArray *groups;
@property (nonatomic) CLLocationManager *manager;
@property (nonatomic) NPGMapViewDelegate *mapViewDelegate;
@property (nonatomic) NSString *savedAction;

@end

@implementation NPGMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.groups = [NSArray new];
    self.mapViewDelegate = [NPGMapViewDelegate new];
    self.mapView.delegate = self.mapViewDelegate;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationCalloutAccessoryTapped) name:NPGAnnotationCalloutAccessoryTappedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapViewRegionDidChange) name:NPGMapViewRegionDidChange object:nil];

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
    [NPGAPIClient fetchGroupsWithCoordinate:self.mapView.centerCoordinate range:self.mapView.region.span.longitudeDelta completionHandler:^(NSArray *groups) {
        [self syncAnnotations:groups additiveOnly:NO];
        self.groups = groups;
    }];
}

- (void)syncAnnotations:(NSArray *)annotations additiveOnly:(BOOL)addOnly
{
    NSMutableSet *oldSet = [NSMutableSet setWithArray:self.mapView.annotations];
    NSMutableSet *newSet = [NSMutableSet setWithArray:annotations];

    [newSet minusSet:oldSet];

    [newSet enumerateObjectsUsingBlock:^(NPGGroup *group, BOOL *stop) {
        [self.mapView addAnnotation:group];
    }];

    if (addOnly) {
        return;
    }

    [oldSet minusSet:[NSSet setWithArray:annotations]];
    [self.mapView removeAnnotations:[oldSet allObjects]];
}

- (void)updateAnnotationWithGroup:(NPGGroup *)group
{
    NSArray *filtered = [self.mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@ AND objectID == %@", [NPGGroup class], group.objectID]];
    NPGGroup *oldGroup = [filtered firstObject];
    oldGroup = group;
}

- (BOOL)registerUser
{
    if ([[NPGAppSession sharedAppSession] hasAskedPushPermission]) {
        return NO;
    }

    [[[UIAlertView alloc] initWithTitle:@"Push Notifications" message:@"Gather would like to send you notifications when people join or comment on your group." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    return YES;
}

- (void)joinGroup:(NPGGroup *)group
{
    [NPGAPIClient joinGroup:group completionHandler:^(NPGGroup *returnedGroup) {
        [NPGAppSession sharedAppSession].currentGroup = returnedGroup;
        [self updateAnnotationWithGroup:returnedGroup];
    }];
}

#pragma mark - NPGMapViewDelegate Notification Methods

- (void)annotationCalloutAccessoryTapped
{
    if (![[NPGAppSession sharedAppSession] isRegistered]) {
        [self performSegueWithIdentifier:@"NPGRegisterSegue" sender:self];
        self.savedAction = NPGJoinGroupActionKey;
        return;
    }

    NPGGroup *newGroup = [[self.mapView selectedAnnotations] firstObject];

    if ([NPGAppSession sharedAppSession].currentGroup) {
        [NPGAPIClient leaveGroup:[NPGAppSession sharedAppSession].currentGroup completionHandler:^(NPGGroup *group) {
            if (!group.objectID) {
                [self.mapView removeAnnotations:[self.mapView selectedAnnotations]];
            } else {
                [self updateAnnotationWithGroup:group];
            }

            if (![[NPGAppSession sharedAppSession].currentGroup isEqual:newGroup]) {
                [self joinGroup:newGroup];
            }
            [NPGAppSession sharedAppSession].currentGroup = nil;
        }];
    } else {
        [self joinGroup:newGroup];
    }
}

- (void)mapViewRegionDidChange
{
    [self loadAnnotations];
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

    if (location.horizontalAccuracy < 0 || location.horizontalAccuracy > 100) return;

    [self.manager stopUpdatingLocation];
    self.manager.delegate = nil;
    self.manager = nil;

    [self loadAnnotations];
}

#pragma mark - NPGRegisterViewControllerDelegate

- (void)registerViewControllerDidFinish
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([[NPGAppSession sharedAppSession] isRegistered]) {
            if (![self registerUser]) {
                if ([self.savedAction isEqualToString:NPGJoinGroupActionKey]) {
                    NPGGroup *group = [[self.mapView selectedAnnotations] firstObject];
                    group.people = [group.people arrayByAddingObject:[[NPGAppSession sharedAppSession] currentUser]];
                } else if ([self.savedAction isEqualToString:NPGEditGroupActionKey]) {
                    [self performSegueWithIdentifier:@"NPGEditGroupSegue" sender:self];
                }
            }
        }

        self.savedAction = nil;
    }];
}

#pragma mark - NPGEditGroupViewControllerDelegate

- (void)editGroupViewControllerDidSaveGroup:(NPGGroup *)group
{
    [self dismissViewControllerAnimated:YES completion:nil];

    if (!group) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was an error creating your group." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    [NPGAppSession sharedAppSession].currentGroup = group;
    [self loadAnnotations];
}

- (void)editGroupViewControllerDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

#pragma mark - Action Methods

- (IBAction)createGroup
{
    if ([[NPGAppSession sharedAppSession] isRegistered]) {
        return [self performSegueWithIdentifier:@"NPGEditGroupSegue" sender:self];
    }

    self.savedAction = NPGEditGroupActionKey;
    [self performSegueWithIdentifier:@"NPGRegisterSegue" sender:self];
}

#pragma mark - Transition Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NPGRegisterSegue"]) {
        NPGRegisterViewController *viewController = segue.destinationViewController;
        viewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"NPGEditGroupSegue"]) {
        NPGEditGroupViewController *viewController = segue.destinationViewController;
        viewController.coordinate = self.mapView.centerCoordinate;
        viewController.delegate = self;
    }
}

@end
