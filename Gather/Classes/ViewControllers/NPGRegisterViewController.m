//
//  NPGRegisterViewController.m
//  Gather
//
//  Created by Tony DiPasquale on 3/27/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGRegisterViewController.h"
#import "NPGUser.h"
#import "NPGUserFactory.h"
#import "NPGAppSession.h"

@interface NPGRegisterViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;

@end

@implementation NPGRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.nameField becomeFirstResponder];
}

#pragma mark - Private Methods

- (void)createUser
{
    NSString *name = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (name.length < 3) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The name you entered is too short." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }

    NPGUser *user = [NPGUserFactory userWithName:name];
    [[NPGAppSession sharedAppSession] setCurrentUser:user];
    [self.delegate registerViewControllerDidFinish];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self createUser];
    return NO;
}

#pragma mark - Actions

- (IBAction)join
{
    [self createUser];
}

- (IBAction)cancel
{
    [self.delegate registerViewControllerDidFinish];
}

@end
