//
//  PAPActivityFeedViewController.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//

#import "PMRActivityFeedViewController.h"
#import "PMRSettingsActionSheetDelegate.h"
#import "PMRActivityCell.h"
#import "PMRAccountViewController.h"
#import "PMRSkillDetailsViewController.h"
#import "PMRBaseTextCell.h"
#import "PMRLoadMoreCell.h"
#import "PMRSettingsButtonItem.h"
//#import "PMRFindFriendsViewController.h"
#import "PMCache.h"
#import "PMUtility.h"
#import "PMConstants.h"
#import "AppDelegate.h"
//#import "MBProgressHUD.h"

@interface PMRActivityFeedViewController ()

@property (nonatomic, strong) PMRSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) NSDate *lastRefresh;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

static NSString *const kPAPActivityTypeLikeString = @"endorsed your game";
static NSString *const kPAPActivityTypeCommentString = @"commented on your game";
static NSString *const kPAPActivityTypeFollowString = @"started following you";
static NSString *const kPAPActivityTypeJoinedString = @"joined PlayMakr";

@implementation PMRActivityFeedViewController

@synthesize settingsActionSheetDelegate;
@synthesize lastRefresh;
@synthesize blankTimelineView;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PMAppDelegateApplicationDidReceiveRemoteNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // The className to query on
        self.parseClassName = kPMActivityClassKey;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 15;          
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [super viewDidLoad];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;

    self.navigationItem.title= @"Feed";

    // Add Settings button
    self.navigationItem.rightBarButtonItem = [[PMRSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteNotification:) name:PMAppDelegateApplicationDidReceiveRemoteNotification object:nil];
    

    lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:kPMRUserDefaultsActivityFeedViewControllerLastRefreshKey];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *activityString = [PMRActivityFeedViewController stringForActivityType:(NSString*)[object objectForKey:kPMActivityTypeKey]];
        PFUser *user = (PFUser*)[object objectForKey:kPMActivityFromUserKey];
        NSString *nameString = @"";

        if (user) {
            nameString = [user objectForKey:kPMUserDisplayNameKey];
        }
        
        return [PMRActivityCell heightForCellWithName:nameString contentString:activityString];
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
        PFObject *activity = [self.objects objectAtIndex:indexPath.row];
        if ([activity objectForKey:kPMActivitySkillKey]) {
            PMRSkillDetailsViewController *detailViewController = [[PMRSkillDetailsViewController alloc] initWithSkill:[activity objectForKey:kPMActivitySkillKey]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else if ([activity objectForKey:kPMActivityFromUserKey]) {
            PMRAccountViewController *detailViewController = [[PMRAccountViewController alloc] initWithStyle:UITableViewStylePlain];
            [detailViewController setUser:[activity objectForKey:kPMActivityFromUserKey]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    } else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }

    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPMActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPMActivityFromUserKey notEqualTo:[PFUser currentUser]];
    [query whereKeyExists:kPMActivityFromUserKey];
    [query includeKey:kPMActivityFromUserKey];
    [query includeKey:kPMActivitySkillKey];
    [query orderByDescending:@"createdAt"];

    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSLog(@"Loading from cache");
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    

    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    lastRefresh = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kPMRUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

//    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        self.navigationController.tabBarItem.badgeValue = nil;

        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
        
        NSUInteger unreadCount = 0;
        for (PFObject *activity in self.objects) {
            if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending && ![[activity objectForKey:kPMActivityTypeKey] isEqualToString:kPMActivityTypeJoined]) {
                unreadCount++;
            }
        }
        
        if (unreadCount > 0) {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)unreadCount];
        } else {
            self.navigationController.tabBarItem.badgeValue = nil;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"ActivityCell";

    PMRActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PMRActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setDelegate:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }

    [cell setActivity:object];

    if ([lastRefresh compare:[object createdAt]] == NSOrderedAscending) {
        [cell setIsNew:YES];
    } else {
        [cell setIsNew:NO];
    }

    [cell hideSeparator:(indexPath.row == self.objects.count - 1)];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    PMRLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PMRLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
   }
    return cell;
}


#pragma mark - PAPActivityCellDelegate Methods

- (void)cell:(PMRActivityCell *)cellView didTapActivityButton:(PFObject *)activity {    
    // Get image associated with the activity
    PFObject *skill = [activity objectForKey:kPMActivitySkillKey];
    
    // Push single photo view controller
    PMRSkillDetailsViewController *skillViewController = [[PMRSkillDetailsViewController alloc] initWithSkill:skill];
    [self.navigationController pushViewController:skillViewController animated:YES];
}

- (void)cell:(PMRBaseTextCell *)cellView didTapUserButton:(PFUser *)user {    
    // Push account view controller
    PMRAccountViewController *accountViewController = [[PMRAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}


#pragma mark - PAPActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:kPMActivityTypeEndorse]) {
        return kPAPActivityTypeLikeString;
    } else if ([activityType isEqualToString:kPMActivityTypeFollow]) {
        return kPAPActivityTypeFollowString;
    } else if ([activityType isEqualToString:kPMActivityTypeComment]) {
        return kPAPActivityTypeCommentString;
    } else if ([activityType isEqualToString:kPMActivityTypeJoined]) {
        return kPAPActivityTypeJoinedString;
    } else {
        return nil;
    }
}

#pragma mark - ()



- (void)settingsButtonAction:(id)sender {
    settingsActionSheetDelegate = [[PMRSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My Profile", @"Find Friends", @"Log Out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)inviteFriendsButtonAction:(id)sender {
//    PMRFindFriendsViewController *detailViewController = [[PMRFindFriendsViewController alloc] init];
//    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)applicationDidReceiveRemoteNotification:(NSNotification *)note {
    [self loadObjects];
}

@end
