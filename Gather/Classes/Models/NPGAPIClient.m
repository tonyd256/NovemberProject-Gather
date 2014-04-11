//
//  NPGAPIClient.m
//  Gather
//
//  Created by Tony DiPasquale on 4/8/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGAPIClient.h"
#import "NPGAppSession.h"
#import "NPGUser.h"
#import "NPGUserFactory.h"
#import "NPGGroup.h"
#import "NPGGroupFactory.h"

static NSString *const NPGAPIBaseURL = @"https://novproject-gather.herokuapp.com/api/v1/";

typedef void (^NPGAPIResponseCompletionHandler)(id json, NSHTTPURLResponse *response, NSError *error);

@implementation NPGAPIClient

#pragma mark - Public Methods

+ (void)createUserWithName:(NSString *)name completionHandler:(NPGUserCompletionHandler)handler
{
    NSDictionary *params = @{@"name": name,
                             @"deviceID": [[[UIDevice currentDevice] identifierForVendor] UUIDString]};

    [self postWithPath:@"user" dictionary:params completionHandler:^(id json, NSHTTPURLResponse *response, NSError *error) {
        if (response.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil);
            });
            return;
        }

        NPGUser *user = [NPGUserFactory userWithJSON:json];

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(user);
        });
    }];
}

+ (void)registerUserWithDeviceToken:(NSString *)deviceToken completionHandler:(void (^)(void))handler
{
    if (![[NPGAppSession sharedAppSession] isRegistered]) {
        return handler();
    }

    NSDictionary *params = @{@"deviceToken": deviceToken};
    NSString *path = [NSString stringWithFormat:@"user/%@/register", [NPGAppSession sharedAppSession].currentUser.objectID];

    [self postWithPath:path dictionary:params completionHandler:^(id json, NSHTTPURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler();
        });
    }];
}

+ (void)fetchGroupsWithCoordinate:(CLLocationCoordinate2D)coordinate range:(double)range completionHandler:(NPGGroupsCompletionHandler)handler
{
    NSString *path = [NSString stringWithFormat:@"groups?latitude=%f&longitude=%f&range=%f", coordinate.latitude, coordinate.longitude, range];

    [self getWithPath:path completionHandler:^(id json, NSHTTPURLResponse *response, NSError *error) {
        if (response.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(@[]);
            });
            return;
        }

        NSArray *groups = [NPGGroupFactory groupsWithJSON:json];

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(groups);
        });
    }];
}

+ (void)createGroupWithType:(NSString *)type time:(NSDate *)time coordinate:(CLLocationCoordinate2D)coordinate completionHandler:(NPGGroupCompletionHandler)handler
{
    NSDictionary *params = @{@"type": type,
                             @"time": [time description],
                             @"latitude": @(coordinate.latitude),
                             @"longitude": @(coordinate.longitude),
                             @"owner": [NPGAppSession sharedAppSession].currentUser.objectID};

    [self postWithPath:@"groups" dictionary:params completionHandler:^(id json, NSHTTPURLResponse *response, NSError *error) {
        if (response.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil);
            });
            return;
        }

        NPGGroup *group = [NPGGroupFactory groupWithJSON:json];

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(group);
        });
    }];
}

+ (void)joinGroup:(NPGGroup *)group completionHandler:(NPGGroupCompletionHandler)handler
{
    NSString *path = [NSString stringWithFormat:@"groups/%@/join/%@", group.objectID, [NPGAppSession sharedAppSession].currentUser.objectID];

    [self getWithPath:path completionHandler:^(id json, NSHTTPURLResponse *response, NSError *error) {
        if (response.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil);
            });
            return;
        }

        NPGGroup *returnedGroup = [NPGGroupFactory groupWithJSON:json];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(returnedGroup);
        });
    }];
}

+ (void)leaveGroup:(NPGGroup *)group completionHandler:(NPGGroupCompletionHandler)handler
{
    NSString *path = [NSString stringWithFormat:@"groups/%@/leave/%@", group.objectID, [NPGAppSession sharedAppSession].currentUser.objectID];

    [self getWithPath:path completionHandler:^(id json, NSHTTPURLResponse *response, NSError *error) {
        if (response.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil);
            });
            return;
        }

        NPGGroup *returnedGroup = [NPGGroupFactory groupWithJSON:json];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(returnedGroup);
        });
    }];
}

#pragma mark - Private Methods

+ (void)postWithPath:(NSString *)path dictionary:(NSDictionary *)dictionary completionHandler:(NPGAPIResponseCompletionHandler)handler
{
    NSURL *url = [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:NPGAPIBaseURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        NSError *err;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];

        if (err) {
            NSLog(@"Returned: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }

        handler(json, httpResponse, error);
    }] resume];
}

+ (void)getWithPath:(NSString *)path completionHandler:(NPGAPIResponseCompletionHandler)handler
{
    NSURL *url = [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:NPGAPIBaseURL]];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        NSError *err;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];

        if (err) {
            NSLog(@"Returned: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }

        handler(json, httpResponse, error);
    }] resume];
}

@end
