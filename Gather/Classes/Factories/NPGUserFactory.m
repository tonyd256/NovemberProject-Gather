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
    user.userID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    return user;
}

+ (NPGUser *)userWithDictionary:(NSDictionary *)dict
{
    NPGUser *user = [NPGUser new];

    user.name = dict[@"name"];
    user.userID = dict[@"userID"];

    return user;
}

+ (NSDictionary *)dictionayWithUser:(NPGUser *)user
{
    return @{@"name": user.name,
             @"userID": user.userID};
}

@end
