//
//  NPGUserFactory.m
//  Gather
//
//  Created by Tony DiPasquale on 3/27/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGUserFactory.h"
#import "NPGUser.h"

@implementation NPGUserFactory

+ (NPGUser *)userWithName:(NSString *)name
{
    NPGUser *user = [NPGUser new];

    user.name = name;
    user.deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    return user;
}

+ (NPGUser *)userWithJSON:(NSDictionary *)json
{
    NPGUser *user = [NPGUser new];

    user.objectID = json[@"_id"];
    user.name = json[@"name"];
    user.deviceID = json[@"deviceID"];

    return user;
}

+ (NSArray *)usersWithJSON:(NSArray *)json
{
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:json.count];

    [json enumerateObjectsUsingBlock:^(NSDictionary *user, NSUInteger idx, BOOL *stop) {
        [users addObject:[self userWithJSON:user]];
    }];

    return [users copy];
}

+ (NPGUser *)userWithDictionary:(NSDictionary *)dict
{
    NPGUser *user = [NPGUser new];

    user.objectID = dict[@"objectID"];
    user.name = dict[@"name"];
    user.deviceID = dict[@"deviceID"];

    return user;
}

+ (NSDictionary *)dictionayWithUser:(NPGUser *)user
{
    return @{@"objectID": user.objectID,
             @"name": user.name,
             @"deviceID": user.deviceID};
}

@end
