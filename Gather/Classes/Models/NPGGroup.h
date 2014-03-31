//
//  NPGGroup.h
//  Gather
//
//  Created by Tony DiPasquale on 3/29/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

@interface NPGGroup : NSObject <NSCopying>

@property (nonatomic) NSString *type;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) NSDate *time;
@property (nonatomic) NSArray *people;

@end
