//
//  NPGDateFormatterFactory.m
//  Gather
//
//  Created by Tony DiPasquale on 3/29/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGDateFormatterFactory.h"

@implementation NPGDateFormatterFactory

+ (NSDateFormatter *)timeFormatter
{
    static NSDateFormatter *timeFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateStyle = NSDateFormatterNoStyle;
        timeFormatter.timeStyle = NSDateFormatterShortStyle;
    });

    return timeFormatter;
}

+ (NSDateFormatter *)ISO8601Formatter
{
    static NSDateFormatter *isoFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isoFormatter = [[NSDateFormatter alloc] init];
        isoFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    });

    return isoFormatter;
}

@end
