//
//  NPGUserFactory.h
//  Gather
//
//  Created by Tony DiPasquale on 3/27/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

@class NPGUser;

@interface NPGUserFactory : NSObject

+ (NPGUser *)userWithName:(NSString *)name;
+ (NPGUser *)userWithJSON:(NSDictionary *)json;
+ (NSArray *)usersWithJSON:(NSArray *)json;
+ (NPGUser *)userWithDictionary:(NSDictionary *)dict;

+ (NSDictionary *)dictionayWithUser:(NPGUser *)user;

@end
