//
//  NPGAnnotation.m
//  Gather
//
//  Created by Tony DiPasquale on 3/10/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGAnnotation.h"

@implementation NPGAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (!self) return nil;

    self.coordinate = coordinate;

    return self;
}

@end
