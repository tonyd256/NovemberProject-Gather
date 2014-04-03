//
//  UIColor+GatherColors.m
//  Gather
//
//  Created by Tony DiPasquale on 3/12/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "UIColor+GatherColors.h"

@implementation UIColor (GatherColors)

+ (UIColor *)actionTintColor
{
    return [UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0];
}

+ (UIColor *)negativeTintColor
{
    return [UIColor colorWithRed:177/255.0 green:0 blue:2/255.0 alpha:1.0];
}

@end
