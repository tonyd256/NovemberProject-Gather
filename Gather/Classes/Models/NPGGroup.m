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
    return [NSString stringWithFormat:@"%lu People %@", (unsigned long)self.people.count, [NPGGroupType actionWithGroupType:self.type]];
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"Leaving at %@", [[NPGDateFormatterFactory timeFormatter] stringFromDate:self.time]];
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    NPGGroup *other = (NPGGroup *)object;
    return [self.objectID isEqualToString:other.objectID];
}

- (NSUInteger)hash
{
    return [self.objectID hash];
}

@end
