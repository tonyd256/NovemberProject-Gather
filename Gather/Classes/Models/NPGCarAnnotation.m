//
//  NPGCarAnnotation.m
//  Gather
//
//  Created by Tony DiPasquale on 3/10/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGCarAnnotation.h"

@implementation NPGCarAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super initWithCoordinate:coordinate];
    if (!self) return nil;

    self.imageName = @"CarIcon";

    return self;
}

@end
