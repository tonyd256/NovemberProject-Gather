//
//  NPGAppSession.h
//  Gather
//
//  Created by Tony DiPasquale on 3/27/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

@class NPGUser;
@class NPGGroup;

@interface NPGAppSession : NSObject

@property (nonatomic) NPGUser *currentUser;
@property (nonatomic) NPGGroup *currentGroup;

+ (instancetype)sharedAppSession;

- (BOOL)isRegistered;

@end
