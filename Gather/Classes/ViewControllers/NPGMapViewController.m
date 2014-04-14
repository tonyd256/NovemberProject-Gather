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
#import "NPGAPIClient.h"
#import "NPGAnnotationView.h"

static NSString *const NPGEditGroupActionKey = @"NPGEditGroupActionKey";
static NSString *const NPGJoinGroupActionKey = @"NPGJoinGroupActionKey";
static NSString *const NPGAnnotationViewReuseIdentifier = @"NPGAnnotationView";

@interface NPGMapViewController () <MKMapViewDelegate, NPGRegisterViewControllerDelegate, NPGEditGroupViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UIButton *groupButton;

@property (nonatomic) NSString *savedAction;

@end

@implementation NPGMapViewController

#pragma mark - Private Methods

- (void)loadAnnotations
{
    [NPGAPIClient fetchGroupsWithCoordinate:self.mapView.centerCoordinate range:self.mapView.region.span.longitudeDelta completionHandler:^(NSArray *groups) {
        [self syncAnnotations:groups additiveOnly:NO];
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
    NSArray *filtered = [self.mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(className == 'NPGGroup') AND (objectID == %@)", group.objectID]];
    NPGGroup *oldGroup = [filtered firstObject];
    oldGroup.people = group.people;
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

- (void)showMenu
{
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.commentsButton.frame;
        frame.origin.x = 240;
        self.commentsButton.frame = frame;
    } completion:nil];

    [UIView animateWithDuration:0.7 delay:0.07 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.groupButton.frame;
        frame.origin.x = 280;
        self.groupButton.frame = frame;
    } completion:nil];
}

- (void)hideMenu
{
    [UIView animateWithDuration:0.7 delay:0.07 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.commentsButton.frame;
        frame.origin.x = 400;
        self.commentsButton.frame = frame;
    } completion:nil];

    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.groupButton.frame;
        frame.origin.x = 440;
        self.groupButton.frame = frame;
    } completion:nil];
}

#pragma mark - MKMapViewDelegate Notification Methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.mapView.region = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.02, 0.02));
        [self loadAnnotations];
    });
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    NPGAnnotationView *view = (NPGAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NPGAnnotationViewReuseIdentifier];

    if (!view) {
        view = [[NPGAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NPGAnnotationViewReuseIdentifier];
    } else {
        [view configureWithAnnotation:annotation];
    }

    return view;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }

    [mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
    [self showMenu];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [self hideMenu];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
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

- (IBAction)openGroupUsers
{
    // toggle users
}

- (IBAction)openComments
{
    // toggle comments
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
