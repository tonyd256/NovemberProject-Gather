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

@implementation NPGAPIClient

+ (void)createUserWithName:(NSString *)name completionHandler:(NPGUserCompletionHandler)handler
{
    NSDictionary *params = @{@"name": name,
                             @"deviceID": [[[UIDevice currentDevice] identifierForVendor] UUIDString]};

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"user" relativeToURL:[NSURL URLWithString:NPGAPIBaseURL]]];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if (httpResponse.statusCode != 200) {
            NSLog(@"Error: %@", error);
            NSLog(@"Returned: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            handler(nil);
            return;
        }

        NPGUser *user = [NPGUserFactory userWithJSON:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(user);
        });
    }] resume];
}

+ (void)registerUserWithDeviceToken:(NSString *)deviceToken completionHandler:(void (^)(void))handler
{
    if (![[NPGAppSession sharedAppSession] isRegistered]) {
        return handler();
    }

    NSDictionary *params = @{@"deviceToken": deviceToken};

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"user/%@/register", [NPGAppSession sharedAppSession].currentUser.objectID] relativeToURL:[NSURL URLWithString:NPGAPIBaseURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if (httpResponse.statusCode != 200) {
            NSLog(@"Error: %@", error);
            NSLog(@"Returned: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            handler();
        });
    }] resume];
}

+ (void)fetchGroupsWithCoordinate:(CLLocationCoordinate2D)coordinate range:(double)range completionHandler:(NPGGroupsCompletionHandler)handler
{
    NSString *urlString = [NSString stringWithFormat:@"groups?latitude=%f&longitude=%f&range=%f", coordinate.latitude, coordinate.longitude, range];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:[NSURL URLWithString:NPGAPIBaseURL]];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if (httpResponse.statusCode != 200) {
            NSLog(@"Returned: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

            dispatch_async(dispatch_get_main_queue(), ^{
                handler(@[]);
            });
            return;
        }

        NSArray *groups = [NPGGroupFactory groupsWithJSON:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(groups);
        });
    }] resume];
}

+ (void)createGroupWithType:(NSString *)type time:(NSDate *)time coordinate:(CLLocationCoordinate2D)coordinate completionHandler:(NPGGroupCompletionHandler)handler
{
    NSDictionary *params = @{@"type": type,
                             @"time": [time description],
                             @"latitude": @(coordinate.latitude),
                             @"longitude": @(coordinate.longitude),
                             @"owner": [NPGAppSession sharedAppSession].currentUser.objectID};

    NSURL *url = [NSURL URLWithString:@"groups" relativeToURL:[NSURL URLWithString:NPGAPIBaseURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if (httpResponse.statusCode != 200) {
            NSLog(@"Returned: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            handler(nil);
            return;
        }

        NPGGroup *group = [NPGGroupFactory groupWithJSON:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(group);
        });
    }] resume];
}

@end
