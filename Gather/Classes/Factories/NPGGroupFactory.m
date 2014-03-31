//
//  NPGGroupFactory.m
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGGroupFactory.h"
#import "NPGGroup.h"
@implementation NPGGroupFactory

+ (NPGGroup *)createGroupWithLocation:(CLLocationCoordinate2D)location
{
    NPGGroup *group = [NPGGroup new];
    group.location = location;
    group.time = @"6:00 AM";
    group.type = @"run";
    return group;
}

@end
