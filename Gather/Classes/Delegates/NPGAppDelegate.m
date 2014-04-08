//
//  NPGAppDelegate.m
//  Gather
//
//  Created by Tony DiPasquale on 3/10/14
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGAppDelegate.h"
#import "NPGAPIClient.h"

@implementation NPGAppDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSMutableString *token = [NSMutableString stringWithCapacity:deviceToken.length*2];
    unsigned char *bytes = (unsigned char *)deviceToken.bytes;
    for (NSUInteger i = 0; i < deviceToken.length; i++) {
        [token appendFormat:@"%02x", bytes[i]];
    }

    [NPGAPIClient registerUserWithDeviceToken:[token copy] completionHandler:^{
        NSLog(@"Registered");
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

@end
