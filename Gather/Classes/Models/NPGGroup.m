//
//  NPGGroup.m
//  Gather
//
//  Created by Tony DiPasquale on 3/29/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGGroup.h"

@implementation NPGGroup

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[self class] new];

    [copy setType:[self.type copy]];
    [copy setTime:[self.time copy]];
    [copy setLocation:self.location];
    [copy setPeople:[self.people copy]];

    return copy;
}

@end
