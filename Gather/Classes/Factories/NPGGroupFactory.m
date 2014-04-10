//
//  NPGGroupFactory.m
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "NPGGroupFactory.h"
#import "NPGGroup.h"
#import "NSDate+Additions.h"
#import "NPGDateFormatterFactory.h"

@implementation NPGGroupFactory

+ (NPGGroup *)groupWithJSON:(NSDictionary *)json
{
    NPGGroup *group = [NPGGroup new];

    group.objectID = json[@"_id"];
    group.coordinate = CLLocationCoordinate2DMake([json[@"coordinate"][0] doubleValue], [json[@"coordinate"][1] doubleValue]);
    group.time = [[NPGDateFormatterFactory ISO8601Formatter] dateFromString:json[@"time"]];
    group.type = json[@"type"];
    group.people = json[@"people"];

    return group;
}

+ (NSArray *)groupsWithJSON:(NSArray *)json
{
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:json.count];

    [json enumerateObjectsUsingBlock:^(NSDictionary *group, NSUInteger idx, BOOL *stop) {
        [groups addObject:[self groupWithJSON:group]];
    }];

    return groups;
}

@end
