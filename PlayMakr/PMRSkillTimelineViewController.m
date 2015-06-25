//
//  PAPPhotoTimelineViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/2/12.
//

#import "PMRSkillTimelineViewController.h"
#import "PMRPhotoCell.h"
#import "PMRAccountViewController.h"
#import "PMRSkillDetailsViewController.h"
#import "PMUtility.h"
#import "PMRLoadMoreCell.h"
#import "PMConstants.h"
#import "PMCache.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface PMRSkillTimelineViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@end

@implementation PMRSkillTimelineViewController
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PMUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PMSkillDetailsViewControllerUserEndorsedUnendorsedSkillNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PMUtilityUserEndorsedUnendorsedSkillCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PMRSkillDetailsViewControllerUserDeletedSkillNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        
        // The className to query on
        self.parseClassName = kPMSkillClassKey;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
        
        // Improve scrolling performance by reusing UITableView section headers
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
        
        self.shouldReloadOnAppear = NO;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; // PFQueryTableViewController reads this in viewDidLoad -- would prefer to throw this in init, but didn't work
    
    [super viewDidLoad];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    texturedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]];
    self.tableView.backgroundView = texturedBackgroundView;
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishSkill:) name:PAPTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowingChanged:) name:PMUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeleteSkill:) name:PMRSkillDetailsViewControllerUserDeletedSkillNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidEndorseOrUnendorseSkill:) name:PMSkillDetailsViewControllerUserEndorsedUnendorsedSkillNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidEndorseOrUnendorseSkill:) name:PMUtilityUserEndorsedUnendorsedSkillCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnSkill:) name:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    if (self.paginationEnabled && sections != 0)
        sections++;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        // Load More section
        return nil;
    }

    PMRSkillHeaderView *headerView = [self dequeueReusableSectionHeaderView];
    
    if (!headerView) {
        headerView = [[PMRSkillHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 44.0f) buttons:PMSkillHeaderButtonsDefault];
        headerView.delegate = self;
        [self.reusableSectionHeaderViews addObject:headerView];
    }
    
    PFObject *skill = [self.objects objectAtIndex:section];
    [headerView setSkill:skill];
    headerView.tag = section;
    [headerView.endorseButton setTag:section];
    
    NSDictionary *attributesForSkill = [[PMCache sharedCache] attributesForSkill:skill];
                                        
    if (attributesForSkill) {
        [headerView setEndorseStatus:[[PMCache sharedCache] isSkillEndorsedByCurrentUser:skill]];
        [headerView.endorseButton setTitle:[[[PMCache sharedCache] endorseCountForSkill:skill] description] forState:UIControlStateNormal];
//        [headerView.commentButton setTitle:[[[PMCache sharedCache] commentCountForSkill:skill] description] forState:UIControlStateNormal];
        
        if (headerView.endorseButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
            [UIView animateWithDuration:0.200f animations:^{
                headerView.endorseButton.alpha = 1.0f;
                headerView.commentButton.alpha = 1.0f;
            }];
        }
    } else {
        headerView.endorseButton.alpha = 0.0f;
        headerView.commentButton.alpha = 0.0f;
        
        @synchronized(self) {
            // check if we can update the cache
            NSNumber *outstandingSectionHeaderQueryStatus = [self.outstandingSectionHeaderQueries objectForKey:[NSNumber numberWithInt:section]];
            if (!outstandingSectionHeaderQueryStatus) {
                PFQuery *query = [PMUtility queryForActivitiesOnSkill:skill cachePolicy:kPFCachePolicyNetworkOnly];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self) {
                        [self.outstandingSectionHeaderQueries removeObjectForKey:[NSNumber numberWithInt:section]];

                        if (error) {
                            return;
                        }
                        
                        NSMutableArray *endorsers = [NSMutableArray array];
                        NSMutableArray *commenters = [NSMutableArray array];
                        
                        BOOL isEndorsedByCurrentUser = NO;
                        
                        for (PFObject *activity in objects) {
                            if ([[activity objectForKey:kPMActivityTypeKey] isEqualToString:kPMActivityTypeEndorse] && [activity objectForKey:kPMActivityFromUserKey]) {
                                [endorsers addObject:[activity objectForKey:kPMActivityFromUserKey]];
                            } else if ([[activity objectForKey:kPMActivityTypeKey] isEqualToString:kPMActivityTypeComment] && [activity objectForKey:kPMActivityFromUserKey]) {
                                [commenters addObject:[activity objectForKey:kPMActivityFromUserKey]];
                            }
                            
                            if ([[[activity objectForKey:kPMActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                if ([[activity objectForKey:kPMActivityTypeKey] isEqualToString:kPMActivityTypeEndorse]) {
                                    isEndorsedByCurrentUser = YES;
                                }
                            }
                        }
                        
                        [[PMCache sharedCache] setAttributesForSkill:skill endorsers:endorsers endorsedByCurrentUser:isEndorsedByCurrentUser];
                        
                        if (headerView.tag != section) {
                            return;
                        }
                        
                        [headerView setEndorseStatus:[[PMCache sharedCache] isSkillEndorsedByCurrentUser:skill]];
                        [headerView.endorseButton setTitle:[[[PMCache sharedCache] endorseCountForSkill:skill] description] forState:UIControlStateNormal];
//                        [headerView.commentButton setTitle:[[[PMCache sharedCache] commentCountForSkill:skill] description] forState:UIControlStateNormal];
                        
                        if (headerView.endorseButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
                            [UIView animateWithDuration:0.200f animations:^{
                                headerView.endorseButton.alpha = 1.0f;
                                headerView.commentButton.alpha = 1.0f;
                            }];
                        }
                    }
                }];
            }            
        }
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 16.0f)];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 16.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load More Section
        return 44.0f;
    }
    
    return 280.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        // Load More Cell
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
    
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kPMActivityClassKey];
    [followingActivitiesQuery whereKey:kPMActivityTypeKey equalTo:kPMActivityTypeFollow];
    [followingActivitiesQuery whereKey:kPMActivityFromUserKey equalTo:[PFUser currentUser]];
    followingActivitiesQuery.limit = 1000;
    
    PFQuery *skillsFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    [skillsFromFollowedUsersQuery whereKey:kPMSkillUserKey matchesKey:kPMActivityToUserKey inQuery:followingActivitiesQuery];
    [skillsFromFollowedUsersQuery whereKeyExists:kPMSkillPictureKey];

    PFQuery *skillsFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [skillsFromCurrentUserQuery whereKey:kPMSkillUserKey equalTo:[PFUser currentUser]];
    [skillsFromCurrentUserQuery whereKeyExists:kPMSkillPictureKey];

    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:skillsFromFollowedUsersQuery, skillsFromCurrentUserQuery, nil]];
    [query includeKey:kPMSkillUserKey];
    [query orderByDescending:@"createdAt"];

    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    if (indexPath.section == self.objects.count) {
        // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    } else {
        PMRPhotoCell *cell = (PMRPhotoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if (cell == nil) {
            cell = [[PMRPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell.photoButton addTarget:self action:@selector(didTapOnSkillAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.photoButton.tag = indexPath.section;
        cell.imageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"];
        
        
        PFObject *skill = [self.objects objectAtIndex:indexPath.section];
        cell.imageView.file = [skill objectForKey:kPMSkillPictureKey];
        
        // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
        if ([cell.imageView.file isDataAvailable]) {
            [cell.imageView loadInBackground];
        }

        return cell;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    PMRLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PMRLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark.png"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


#pragma mark - PAPPhotoTimelineViewController

- (PMRSkillHeaderView *)dequeueReusableSectionHeaderView {
    for (PMRSkillHeaderView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    
    return nil;
}


#pragma mark - PAPPhotoHeaderViewDelegate

- (void)photoHeaderView:(PMRSkillHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    PMRAccountViewController *accountViewController = [[PMRAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)skillHeaderView:(PMRSkillHeaderView *)skillHeaderView didTapEndorseSkillButton:(UIButton *)button skill:(PFObject *)skill {
    [skillHeaderView shouldEnableEndorseButton:NO];
    
    BOOL endorsed = !button.selected;
    [skillHeaderView setEndorseStatus:endorsed];
    
    NSString *originalButtonTitle = button.titleLabel.text;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSNumber *endorseCount = [numberFormatter numberFromString:button.titleLabel.text];
    if (endorsed) {
        endorseCount = [NSNumber numberWithInt:[endorseCount intValue] + 1];
        [[PMCache sharedCache] incrementEndorserCountForSkill:skill];
    } else {
        if ([endorseCount intValue] > 0) {
            endorseCount = [NSNumber numberWithInt:[endorseCount intValue] - 1];
        }
        [[PMCache sharedCache] decrementEndorserCountForSkill:skill];
    }
    
    [[PMCache sharedCache] setSkillIsEndorsedByCurrentUser:skill endorsed:endorsed];
    
    [button setTitle:[numberFormatter stringFromNumber:endorseCount] forState:UIControlStateNormal];
    
    if (endorsed) {
        [PMUtility endorseSkillInBackground:skill block:^(BOOL succeeded, NSError *error) {
            PMRSkillHeaderView *actualHeaderView = (PMRSkillHeaderView *)[self tableView:self.tableView viewForHeaderInSection:button.tag];
            [actualHeaderView shouldEnableEndorseButton:YES];
            [actualHeaderView setEndorseStatus:succeeded];
            
            if (!succeeded) {
                [actualHeaderView.endorseButton setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
        }];
    } else {
        [PMUtility removeEndorsementForSkillInBackground:skill block:^(BOOL succeeded, NSError *error) {
            PMRSkillHeaderView *actualHeaderView = (PMRSkillHeaderView *)[self tableView:self.tableView viewForHeaderInSection:button.tag];
            [actualHeaderView shouldEnableEndorseButton:YES];
            [actualHeaderView setEndorseStatus:!succeeded];
            
            if (!succeeded) {
                [actualHeaderView.endorseButton setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
        }];
    }
}

- (void)skillHeaderView:(PMRSkillHeaderView *)skillHeaderView didTapCommentOnSkillButton:(UIButton *)button skill:(PFObject *)skill {
    PMRSkillDetailsViewController *skillDetailsVC = [[PMRSkillDetailsViewController alloc] initWithSkill:skill];
    [self.navigationController pushViewController:skillDetailsVC animated:YES];
}


#pragma mark - ()

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    
    return nil;
}

- (void)userDidEndorseOrUnendorseSkill:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidCommentOnSkill:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidDeleteSkill:(NSNotification *)note {
    // refresh timeline after a delay
    [self performSelector:@selector(loadObjects) withObject:nil afterDelay:1.0f];
}

- (void)userDidPublishSkill:(NSNotification *)note {
    if (self.objects.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    [self loadObjects];
}

- (void)userFollowingChanged:(NSNotification *)note {
    NSLog(@"User following changed.");
    self.shouldReloadOnAppear = YES;
}


- (void)didTapOnSkillAction:(UIButton *)sender {
    PFObject *skill = [self.objects objectAtIndex:sender.tag];
    if (skill) {
        PMRSkillDetailsViewController *skillDetailsVC = [[PMRSkillDetailsViewController alloc] initWithSkill:skill];
        [self.navigationController pushViewController:skillDetailsVC animated:YES];
    }
}

@end