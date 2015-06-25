//
//  PAPFindFriendsViewController.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//

#import "PMRFindFriendsViewController.h"
#import "PMRProfileImageView.h"
#import "AppDelegate.h"
#import "PMRLoadMoreCell.h"
#import "PMRAccountViewController.h"
#import "PMConstants.h"
#import "PMCache.h"
#import "PMUtility.h"

typedef enum {
    PMRFindFriendsFollowingNone = 0,    // User isn't following anybody in Friends list
    PMRFindFriendsFollowingAll,         // User is following all Friends
    PMRFindFriendsFollowingSome         // User is following some of their Friends
} PMRFindFriendsFollowStatus;

@interface PMRFindFriendsViewController ()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) PMRFindFriendsFollowStatus followStatus;
@property (nonatomic, strong) NSString *selectedEmailAddress;
@property (nonatomic, strong) NSMutableDictionary *outstandingFollowQueries;
@property (nonatomic, strong) NSMutableDictionary *outstandingCountQueries;
@end

//static NSUInteger const kPAPCellFollowTag = 2;
//static NSUInteger const kPAPCellNameLabelTag = 3;
//static NSUInteger const kPAPCellAvatarTag = 4;
//static NSUInteger const kPAPCellPhotoNumLabelTag = 5;

@implementation PMRFindFriendsViewController
@synthesize headerView;
@synthesize followStatus;
@synthesize selectedEmailAddress;
@synthesize outstandingFollowQueries;
@synthesize outstandingCountQueries;
#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.outstandingFollowQueries = [NSMutableDictionary dictionary];
        self.outstandingCountQueries = [NSMutableDictionary dictionary];
        
        self.selectedEmailAddress = @"";

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 15;
        
        // Used to determine Follow/Unfollow All button status
        self.followStatus = PMRFindFriendsFollowingSome;
        
        [self.tableView setSeparatorColor:[UIColor colorWithRed:210.0f/255.0f green:203.0f/255.0f blue:182.0f/255.0f alpha:1.0]];
    }
    return self;
}



#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;
        
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TitleFindFriends.png"]];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 52.0f, 32.0f)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [[backButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5.0f, 0, 0)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
//    if ([MFMailComposeViewController canSendMail] || [MFMessageComposeViewController canSendText]) {
//        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 67)];
//        [self.headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundFindFriendsCell.png"]]];
//        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [clearButton setBackgroundColor:[UIColor clearColor]];
//        [clearButton addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        [clearButton setFrame:self.headerView.frame];
//        [self.headerView addSubview:clearButton];
//        NSString *inviteString = @"Invite friends";
//        CGSize inviteStringSize = [inviteString sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(310, CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
//        UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (self.headerView.frame.size.height-inviteStringSize.height)/2, inviteStringSize.width, inviteStringSize.height)];
//        [inviteLabel setText:inviteString];
//        [inviteLabel setFont:[UIFont boldSystemFontOfSize:18]];
//        [inviteLabel setTextColor:[UIColor colorWithRed:87.0f/255.0f green:72.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
//        [inviteLabel setBackgroundColor:[UIColor clearColor]];
//        [self.headerView addSubview:inviteLabel];
//        UIImageView *separatorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SeparatorTimeline.png"]];
//        [separatorImage setFrame:CGRectMake(0, self.headerView.frame.size.height-2, 320, 2)];
//        [self.headerView addSubview:separatorImage];
//        [self.tableView setTableHeaderView:self.headerView];
//    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        return [PMRFindFriendsCell heightForCell];
    } else {
        return 44.0f;
    }
}


#pragma mark - PFQueryTableViewController


- (PFQuery *)queryForTable {
    // Use cached facebook friend ids
    
    // Query for all friends you have on facebook and who are using the app
    PFQuery *query = [PFUser query];

    
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:kPMUserDisplayNameKey];
    
    return query;
}


- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kPMActivityClassKey];
    [isFollowingQuery whereKey:kPMActivityFromUserKey equalTo:[PFUser currentUser]];
    [isFollowingQuery whereKey:kPMActivityTypeKey equalTo:kPMActivityTypeFollow];
    [isFollowingQuery whereKey:kPMActivityToUserKey containedIn:self.objects];
    [isFollowingQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            if (number == self.objects.count) {
                self.followStatus = PMRFindFriendsFollowingAll;
                [self configureUnfollowAllButton];
                for (PFUser *user in self.objects) {
                    [[PMCache sharedCache] setFollowStatus:YES user:user];
                }
            } else if (number == 0) {
                self.followStatus = PMRFindFriendsFollowingNone;
                [self configureFollowAllButton];
                for (PFUser *user in self.objects) {
                    [[PMCache sharedCache] setFollowStatus:NO user:user];
                }
            } else {
                self.followStatus = PMRFindFriendsFollowingSome;
                [self configureFollowAllButton];
            }
        }
        
        if (self.objects.count == 0) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }];
    
    if (self.objects.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    PMRFindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[PMRFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self];
    }
    
    [cell setUser:(PFUser*)object];

    [cell.photoLabel setText:@"0 skills"];
    
    NSDictionary *attributes = [[PMCache sharedCache] attributesForUser:(PFUser *)object];
    
    if (attributes) {
        // set them now
        NSString *pluralizedPhoto;
        NSNumber *number = [[PMCache sharedCache] skillCountForUser:(PFUser *)object];
        if ([number intValue] == 1) {
            pluralizedPhoto = @"skill";
        } else {
            pluralizedPhoto = @"skills";
        }
        [cell.photoLabel setText:[NSString stringWithFormat:@"%@ %@", number, pluralizedPhoto]];
    } else {
        @synchronized(self) {
            NSNumber *outstandingCountQueryStatus = [self.outstandingCountQueries objectForKey:indexPath];
            if (!outstandingCountQueryStatus) {
                [self.outstandingCountQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                PFQuery *photoNumQuery = [PFQuery queryWithClassName:kPMSkillClassKey];
                [photoNumQuery whereKey:kPMSkillUserKey equalTo:object];
                [photoNumQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                [photoNumQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    @synchronized(self) {
                        [[PMCache sharedCache] setSkillCount:[NSNumber numberWithInt:number] user:(PFUser *)object];
                        [self.outstandingCountQueries removeObjectForKey:indexPath];
                    }
                    PMRFindFriendsCell *actualCell = (PMRFindFriendsCell*)[tableView cellForRowAtIndexPath:indexPath];
                    NSString *pluralizedPhoto;
                    if (number == 1) {
                        pluralizedPhoto = @"skill";
                    } else {
                        pluralizedPhoto = @"skills";
                    }
                    [actualCell.photoLabel setText:[NSString stringWithFormat:@"%d %@", number, pluralizedPhoto]];
                    
                }];
            };
        }
    }

    cell.followButton.selected = NO;
    cell.tag = indexPath.row;
    
    if (self.followStatus == PMRFindFriendsFollowingSome) {
        if (attributes) {
            [cell.followButton setSelected:[[PMCache sharedCache] followStatusForUser:(PFUser *)object]];
        } else {
            @synchronized(self) {
                NSNumber *outstandingQuery = [self.outstandingFollowQueries objectForKey:indexPath];
                if (!outstandingQuery) {
                    [self.outstandingFollowQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kPMActivityClassKey];
                    [isFollowingQuery whereKey:kPMActivityFromUserKey equalTo:[PFUser currentUser]];
                    [isFollowingQuery whereKey:kPMActivityTypeKey equalTo:kPMActivityTypeFollow];
                    [isFollowingQuery whereKey:kPMActivityToUserKey equalTo:object];
                    [isFollowingQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                    
                    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                        @synchronized(self) {
                            [self.outstandingFollowQueries removeObjectForKey:indexPath];
                            [[PMCache sharedCache] setFollowStatus:(!error && number > 0) user:(PFUser *)object];
                        }
                        if (cell.tag == indexPath.row) {
                            [cell.followButton setSelected:(!error && number > 0)];
                        }
                    }];
                }
            }
        }
    } else {
        [cell.followButton setSelected:(self.followStatus == PMRFindFriendsFollowingAll)];
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *NextPageCellIdentifier = @"NextPageCell";
    
    PMRLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:NextPageCellIdentifier];
    
    if (cell == nil) {
        cell = [[PMRLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NextPageCellIdentifier];
        [cell.mainView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundFindFriendsCell.png"]]];
        cell.hideSeparatorBottom = YES;
        cell.hideSeparatorTop = YES;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}


#pragma mark - PMRFindFriendsCellDelegate

- (void)cell:(PMRFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser {
    // Push account view controller
    PMRAccountViewController *accountViewController = [[PMRAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:aUser];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)cell:(PMRFindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser {
    [self shouldToggleFollowFriendForCell:cellView];
}


//#pragma mark - UIActionSheetDelegate
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == actionSheet.cancelButtonIndex) {
//        return;
//    }
//
//    if (buttonIndex == 0) {
//        [self presentMailComposeViewController:self.selectedEmailAddress];
//    } else if (buttonIndex == 1) {
//        [self presentMessageComposeViewController:self.selectedEmailAddress];
//    }
//}

#pragma mark - ()

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)followAllFriendsButtonAction:(id)sender {
    
    self.followStatus = PMRFindFriendsFollowingAll;
    [self configureUnfollowAllButton];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow All" style:UIBarButtonItemStylePlain target:self action:@selector(unfollowAllFriendsButtonAction:)];
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.objects.count];
        for (int r = 0; r < self.objects.count; r++) {
            PFObject *user = [self.objects objectAtIndex:r];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:0];
            PMRFindFriendsCell *cell = (PMRFindFriendsCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath object:user];
            cell.followButton.selected = YES;
            [indexPaths addObject:indexPath];
        }
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];

        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(followUsersTimerFired:) userInfo:nil repeats:NO];
        [PMUtility followUsersEventually:self.objects block:^(BOOL succeeded, NSError *error) {
            // note -- this block is called once for every user that is followed successfully. We use a timer to only execute the completion block once no more saveEventually blocks have been called in 2 seconds
            [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2.0f]];
        }];
        
    });
}

- (void)unfollowAllFriendsButtonAction:(id)sender {

    
    self.followStatus = PMRFindFriendsFollowingNone;
    [self configureFollowAllButton];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStylePlain target:self action:@selector(followAllFriendsButtonAction:)];
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.objects.count];
        for (int r = 0; r < self.objects.count; r++) {
            PFObject *user = [self.objects objectAtIndex:r];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:0];
            PMRFindFriendsCell *cell = (PMRFindFriendsCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath object:user];
            cell.followButton.selected = NO;
            [indexPaths addObject:indexPath];
        }
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        
        
        [PMUtility unfollowUsersEventually:self.objects];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PMUtilityUserFollowingChangedNotification object:nil];
    });
    
}

- (void)shouldToggleFollowFriendForCell:(PMRFindFriendsCell*)cell {
    PFUser *cellUser = cell.user;
    if ([cell.followButton isSelected]) {
        // Unfollow
        cell.followButton.selected = NO;
        [PMUtility unfollowUserEventually:cellUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:PMUtilityUserFollowingChangedNotification object:nil];
    } else {
        // Follow
        cell.followButton.selected = YES;
        [PMUtility followUserEventually:cellUser block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PMUtilityUserFollowingChangedNotification object:nil];
            } else {
                cell.followButton.selected = NO;
            }
        }];
    }
}


- (void)configureUnfollowAllButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow All" style:UIBarButtonItemStylePlain target:self action:@selector(unfollowAllFriendsButtonAction:)];
}

- (void)configureFollowAllButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStylePlain target:self action:@selector(followAllFriendsButtonAction:)];
}



- (void)followUsersTimerFired:(NSTimer *)timer {
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:PMUtilityUserFollowingChangedNotification object:nil];
}

@end
