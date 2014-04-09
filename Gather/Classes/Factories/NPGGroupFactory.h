//
//  NPGGroupFactory.h
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

@class NPGGroup;

@interface NPGGroupFactory : NSObject

+ (NPGGroup *)groupWithJSON:(NSDictionary *)json;
+ (NSArray *)groupsWithJSON:(NSArray *)json;

@end
