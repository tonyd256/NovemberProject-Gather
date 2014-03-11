//
//  NPGBikeAnnotation.m
//  Gather
//
//  Created by Tony DiPasquale on 3/10/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGBikeAnnotation.h"

@implementation NPGBikeAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super initWithCoordinate:coordinate];
    if (!self) return nil;

    self.imageName = @"BikeIcon";

    return self;
}

@end
