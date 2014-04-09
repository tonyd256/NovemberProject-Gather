//
//  NPGDateFormatterFactory.h
//  Gather
//
//  Created by Tony DiPasquale on 3/29/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

@interface NPGDateFormatterFactory : NSObject

+ (NSDateFormatter *)timeFormatter;
+ (NSDateFormatter *)ISO8601Formatter;

@end
