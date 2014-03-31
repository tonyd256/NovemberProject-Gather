//
//  NPGAppSession.h
//  Gather
//
//  Created by Tony DiPasquale on 3/27/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

@class NPGUser;

@interface NPGAppSession : NSObject

@property (nonatomic) NPGUser *currentUser;

+ (instancetype)sharedAppSession;

- (BOOL)isRegistered;

@end
