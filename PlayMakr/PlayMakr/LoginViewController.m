//
//  LoginViewController.m
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-20.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        NSLog(@"Current User: %@", currentUser.username);
        [self performSegueWithIdentifier: @"showTabBar" sender:nil];

    }
    else {
        PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
        logInController.fields = (PFLogInFieldsUsernameAndPassword
                                  | PFLogInFieldsLogInButton
                                  | PFLogInFieldsSignUpButton
                                  | PFLogInFieldsPasswordForgotten
                                  );
        logInController.delegate = self;
        logInController.signUpController.delegate = self;
        [self presentViewController:logInController animated:YES completion:nil];
    }
}

- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier: @"showTabBar" sender:nil];
}
-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
   
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier: @"showTabBar" sender:nil];
}




@end
