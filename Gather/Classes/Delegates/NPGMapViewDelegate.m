//
//  NPGMapViewDelegate.m
//  Gather
//
//  Created by Tony DiPasquale on 3/31/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGMapViewDelegate.h"
#import "NPGAnnotationView.h"
#import "NPGGroup.h"

static NSString *const NPGAnnotationViewReuseIdentifier = @"NPGAnnotationView";
NSString *const NPGAnnotationCalloutAccessoryTappedNotification = @"NPGAnnotationCalloutAccessoryTappedNotification";
NSString *const NPGMapViewRegionDidChange = @"NPGMapViewRegionDidChange";

@implementation NPGMapViewDelegate

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
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NPGAnnotationCalloutAccessoryTappedNotification object:nil];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NPGMapViewRegionDidChange object:nil];
}

@end
