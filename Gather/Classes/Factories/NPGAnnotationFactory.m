//
//  NPGAnnotationFactory.m
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGAnnotationFactory.h"
#import "NPGAnnotation.h"
#import "NPGRunAnnotation.h"
#import "NPGBikeAnnotation.h"
#import "NPGCarAnnotation.h"
#import "NPGGroup.h"
#import "NPGDateFormatterFactory.h"

@implementation NPGAnnotationFactory

+ (NPGAnnotation *)annotationWithGroup:(NPGGroup *)group
{
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

    annotation.subtitle = [NSString stringWithFormat:@"Leaving at %@", [[NPGDateFormatterFactory timeFormatter] stringFromDate:group.time]];

    return annotation;
}

@end
