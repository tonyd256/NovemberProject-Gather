//
//  NSDate+Additions.m
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

+ (NSDate *)tomorrowWithHour:(NSInteger)hour minute:(NSInteger)minute
{
    NSDate *now = [NSDate new];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:now];
    components.day += 1;
    components.hour = hour;
    components.minute = minute;

    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

@end
