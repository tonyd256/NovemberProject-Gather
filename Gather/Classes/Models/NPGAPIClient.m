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

static NSString *const NPGAPIBaseURL = @"http://localhost:3000/api/v1/";

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
        handler(user);
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

        handler();
    }] resume];
}

@end
