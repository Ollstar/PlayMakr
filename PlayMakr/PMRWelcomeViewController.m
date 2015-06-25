//
//  PMRWelcomeViewController.m
//  PlayMakr
//
//  Created by Ollstar.
//
#import "PMRWelcomeViewController.h"
#import "AppDelegate.h"
#import "PMConstants.h"
#import <Parse/Parse.h>

@implementation PMRWelcomeViewController

#pragma mark - UIViewController
- (void)loadView {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [backgroundImageView setImage:[UIImage imageNamed:@"background1"]];
    self.view = backgroundImageView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // If not logged in, present login view controller
    if (![PFUser currentUser]) {
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentLoginViewControllerAnimated:NO];
        return;
    }
    // Present Anypic UI
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
    
    // Refresh current user with server side data -- checks if user is still valid and so on
    [[PFUser currentUser] fetchInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}



- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] logInViewController:logInController didLogInUser:user];

    
}
- (void)signUpViewController:(PFSignUpViewController *)signUpController didLogInUser:(PFUser *)user {
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] signUpViewController:signUpController didSignUpUser:user];
    
    
}

#pragma mark - ()

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        NSLog(@"User does not exist.");
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
    }
return;
}

@end
