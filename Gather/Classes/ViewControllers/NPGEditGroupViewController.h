//
//  NPGEditGroupViewController.h
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class NPGEditGroupViewController;
@class NPGGroup;

@protocol NPGEditGroupViewControllerDelegate <NSObject>

- (void)editGroupViewControllerDidSaveGroup:(NPGGroup *)group;
- (void)editGroupViewControllerDidCancel;

@end

@interface NPGEditGroupViewController : UIViewController

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, weak) id<NPGEditGroupViewControllerDelegate>delegate;

@end
