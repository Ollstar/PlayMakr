//
//  PAPSettingsActionSheetDelegate.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//

#import "PMRSettingsActionSheetDelegate.h"
#import "PMRFindFriendsViewController.h"
#import "PMRAccountViewController.h"
#import "AppDelegate.h"
#import "PMConstants.h"

// ActionSheet button indexes
typedef enum {
	kPAPSettingsProfile = 0,
	kPAPSettingsFindFriends,
	kPAPSettingsLogout,
    kPAPSettingsNumberOfButtons
} kPAPSettingsActionSheetButtons;
 
@implementation PMRSettingsActionSheetDelegate

@synthesize navController;

#pragma mark - Initialization

- (id)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        navController = navigationController;
    }
    return self;
}

- (id)init {
    return [self initWithNavigationController:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!self.navController) {
        [NSException raise:NSInvalidArgumentException format:@"navController cannot be nil"];
        return;
    }
    
    switch ((kPAPSettingsActionSheetButtons)buttonIndex) {
        case kPAPSettingsProfile:
        {
            PMRAccountViewController *accountViewController = [[PMRAccountViewController alloc] initWithStyle:UITableViewStylePlain];
            [accountViewController setUser:[PFUser currentUser]];
            [navController pushViewController:accountViewController animated:YES];
            break;
        }
        case kPAPSettingsFindFriends:
        {
            PMRFindFriendsViewController *findFriendsVC = [[PMRFindFriendsViewController alloc] init];
            [navController pushViewController:findFriendsVC animated:YES];
            break;
        }
        case kPAPSettingsLogout:
            // Log out user and present the login view controller
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            break;
        default:
            break;
    }
}

@end
