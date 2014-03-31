//
//  UIView+NibLoading.m
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "UIView+NibLoading.h"

@implementation UIView (NibLoading)

+ (instancetype)loadNib
{
    NSArray *unarchivedObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    for (id object in unarchivedObjects) {
        if ([object isKindOfClass:[self class]]) {
            return object;
        }
    }

    return nil;
}

@end
