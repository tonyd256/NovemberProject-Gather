//
//  NPGRegisterViewController.h
//  Gather
//
//  Created by Tony DiPasquale on 3/27/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

@class NPGRegisterViewController;

@protocol NPGRegisterViewControllerDelegate <NSObject>

- (void)registerViewControllerDidFinish;

@end

@interface NPGRegisterViewController : UIViewController

@property (nonatomic, weak) id<NPGRegisterViewControllerDelegate> delegate;

@end
