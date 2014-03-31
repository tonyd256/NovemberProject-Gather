//
//  NPGAppSession.m
//  Gather
//
//  Created by Tony DiPasquale on 3/27/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGAppSession.h"
#import "NPGUserFactory.h"
#import "NPGUser.h"

static NSString *const NPGUserStorageKey = @"user";

@implementation NPGAppSession

@synthesize currentUser = _currentUser;

+ (instancetype)sharedAppSession
{
    static NPGAppSession *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [NPGAppSession new];
    });
    return _shared;
}

#pragma mark - Properties

- (NPGUser *)currentUser
{
    if (_currentUser) return _currentUser;

    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:NPGUserStorageKey];

    if (!dict) return nil;

    _currentUser = [NPGUserFactory userWithDictionary:dict];
    return _currentUser;
}

- (void)setCurrentUser:(NPGUser *)currentUser
{
    _currentUser = currentUser;
    [[NSUserDefaults standardUserDefaults] setObject:[NPGUserFactory dictionayWithUser:currentUser] forKey:NPGUserStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Public Methods

- (BOOL)isRegistered
{
    return self.currentUser != nil;
}

@end
