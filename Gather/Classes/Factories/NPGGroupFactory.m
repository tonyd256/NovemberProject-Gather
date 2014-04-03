//
//  NPGGroupFactory.m
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGGroupFactory.h"
#import "NPGGroup.h"
#import "NSDate+Additions.h"

@implementation NPGGroupFactory

+ (NPGGroup *)createGroupWithLocation:(CLLocationCoordinate2D)location
{
    NPGGroup *group = [NPGGroup new];
    group.coordinate = location;
    group.time = [NSDate tomorrowWithHour:6 minute:0];
    group.type = @"run";
    group.people = @[];
    return group;
}

@end
