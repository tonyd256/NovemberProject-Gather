//
//  NPGGroup.m
//  Gather
//
//  Created by Tony DiPasquale on 3/29/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGGroup.h"
#import "NPGGroupType.h"
#import "NPGDateFormatterFactory.h"

@implementation NPGGroup

+ (NSSet *)keyPathsForValuesAffectingTitle
{
    return [NSSet setWithObject:@"people"];
}

+ (NSSet *)keyPathsForValuesAffectingSubtitle
{
    return [NSSet setWithObject:@"time"];
}

#pragma mark - Properties

- (NSString *)title
{
    return [NSString stringWithFormat:@"%d People %@", self.people.count, [NPGGroupType actionWithGroupType:self.type]];
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"Leaving at %@", [[NPGDateFormatterFactory timeFormatter] stringFromDate:self.time]];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[self class] new];

    [copy setType:[self.type copy]];
    [copy setTime:[self.time copy]];
    [copy setCoordinate:self.coordinate];
    [copy setPeople:[self.people copy]];

    return copy;
}

@end
