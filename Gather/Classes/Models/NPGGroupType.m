//
//  NPGGroupType.m
//  Gather
//
//  Created by Tony DiPasquale on 3/31/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGGroupType.h"

@implementation NPGGroupType

+ (NSString *)actionWithGroupType:(NSString *)type
{
    static NSDictionary *typeActions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeActions = @{@"run": @"Running",
                        @"bike": @"Biking",
                        @"car": @"Driving"};
    });

    return typeActions[type];
}

+ (UIImage *)imageWithGroupType:(NSString *)type
{
    static NSDictionary *typeImageNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeImageNames = @{@"run": @"RunIcon",
                           @"bike": @"BikeIcon",
                           @"car": @"CarIcon"};
    });

    return [UIImage imageNamed:typeImageNames[type]];
}

@end
