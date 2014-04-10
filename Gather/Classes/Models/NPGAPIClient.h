//
//  NPGAPIClient.h
//  Gather
//
//  Created by Tony DiPasquale on 4/8/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import <MapKit/MapKit.h>

@class NPGUser;
@class NPGGroup;

typedef void (^NPGUserCompletionHandler)(NPGUser *user);
typedef void (^NPGGroupCompletionHandler)(NPGGroup *group);
typedef void (^NPGGroupsCompletionHandler)(NSArray *groups);

@interface NPGAPIClient : NSObject

+ (void)createUserWithName:(NSString *)name completionHandler:(NPGUserCompletionHandler)handler;
// update user
+ (void)registerUserWithDeviceToken:(NSString *)deviceToken completionHandler:(void (^)(void))handler;
// unregister

+ (void)fetchGroupsWithCoordinate:(CLLocationCoordinate2D)coordinate range:(double)range completionHandler:(NPGGroupsCompletionHandler)handler;
+ (void)createGroupWithType:(NSString *)type time:(NSDate *)time coordinate:(CLLocationCoordinate2D)coordinate completionHandler:(NPGGroupCompletionHandler)handler;
//+ (void)joinGroup:(NPGGroup *)group completionHandler:(NPGGroupCompletionHandler)handler;
//+ (void)leaveGroup:(NPGGroup *)group completionHandler:(NPGGroupCompletionHandler)handler;
//+ (void)commentWithGroup:(NPGGroup *)group comment:(NSString *)comment completionHandler:(NPGGroupCompletionHandler)handler;

@end
