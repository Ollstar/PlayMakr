//
//  PAPPhotoDetailViewController.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//

#import "PMRSkillDetailsViewController.h"
#import "PMRBaseTextCell.h"
#import "PMRActivityCell.h"
#import "PMRSkillDetailsFooterView.h"
#import "PMConstants.h"
#import "PMRAccountViewController.h"
#import "PMRLoadMoreCell.h"
#import "PMUtility.h"
#import "PMCache.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

enum ActionSheetTags {
    MainActionSheetTag = 0,
    ConfirmDeleteActionSheetTag = 1
};

@interface PMRSkillDetailsViewController ()
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) PMRSkillDetailsHeaderView *headerView;
@end

static const CGFloat kPAPCellInsetWidth = 20.0f;

@implementation PMRSkillDetailsViewController

@synthesize commentTextField;
@synthesize skill, headerView;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PMUtilityUserEndorsedUnendorsedSkillCallbackFinishedNotification object:self.skill];
}

- (id)initWithSkill:(PFObject *)aSkill {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.skill = aSkill;

        // Set query table view properties
        self.parseClassName = kPMActivityClassKey;
        self.objectsPerPage = 10;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [super viewDidLoad];
    
    self.navigationItem.title = @"Skill";

    [self.navigationItem setHidesBackButton:YES];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake( 0.0f, 0.0f, 52.0f, 32.0f)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [[backButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // Set table view properties
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;
    
    // Set table header
    self.headerView = [[PMRSkillDetailsHeaderView alloc] initWithFrame:[PMRSkillDetailsHeaderView rectForView] skill:self.skill];
    [self.headerView setDelegate:self];
    
    self.tableView.tableHeaderView = self.headerView;
    
    // Set table footer
    PMRSkillDetailsFooterView *footerView = [[PMRSkillDetailsFooterView alloc] initWithFrame:[PMRSkillDetailsFooterView rectForView]];
    commentTextField = footerView.commentField;
    [commentTextField setDelegate:self];
    self.tableView.tableFooterView = footerView;
    
    if ([[[self.skill objectForKey:kPMSkillUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonAction:)];
    }
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];     
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLikedOrUnlikedPhoto:) name:PMUtilityUserEndorsedUnendorsedSkillCallbackFinishedNotification object:self.skill];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.headerView reloadEndorseBar];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) { // A comment row
        
        BOOL hasActivityImage = NO;
        
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        if ([[object objectForKey:kPMActivityTypeKey] isEqualToString:kPMActivityTypeFollow] || [[object objectForKey:kPMActivityTypeKey] isEqualToString:kPMActivityTypeJoined]) {
            hasActivityImage = NO;
        } else {
            hasActivityImage = YES;
        }
        
        NSString *commentString  = [[self.objects objectAtIndex:indexPath.row] objectForKey:kPMActivityContentKey];
        NSString *nameString = [(PFUser*)[object objectForKey:kPMActivityFromUserKey] objectForKey:kPMUserDisplayNameKey];

        return [PMRActivityCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:kPAPCellInsetWidth];
    } else { // The pagination row
        return 44.0f;
    }
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPMActivitySkillKey equalTo:self.skill];
    [query includeKey:kPMActivityFromUserKey];
    [query whereKey:kPMActivityTypeKey equalTo:kPMActivityTypeComment];
    [query orderByAscending:@"createdAt"]; 

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

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    NSLog(@"Objects did load");
    [self.headerView reloadEndorseBar];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellID = @"commentCell";

    // Try to dequeue a cell and create one if necessary
    PMRBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PMRBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        [cell setCellInsetWidth:kPAPCellInsetWidth];
        [cell setDelegate:self];
    }
    [cell setUser:[object objectForKey:kPMActivityFromUserKey]];
    [cell setContentText:[object objectForKey:kPMActivityContentKey]];
    [cell setDate:[object createdAt]];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";
    
    PMRLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PMRLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.hideSeparatorTop = YES;
    }
    
    return cell;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.skill objectForKey:kPMSkillUserKey]) {
        PFObject *comment = [PFObject objectWithClassName:kPMActivityClassKey];
        [comment setValue:trimmedComment forKey:kPMActivityContentKey]; // Set comment text
        [comment setValue:[self.skill objectForKey:kPMSkillUserKey] forKey:kPMActivityToUserKey]; // Set toUser
        [comment setValue:[PFUser currentUser] forKey:kPMActivityFromUserKey]; // Set fromUser
        [comment setValue:kPMActivityTypeComment forKey:kPMActivityTypeKey];
        [comment setValue:self.skill forKey:kPMActivitySkillKey];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        comment.ACL = ACL;

//        [[PMCache sharedCache] incrementCommentCountForPhoto:self.ski];
        
        // Show HUD view
//        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:[NSDictionary dictionaryWithObject:comment forKey:@"comment"] repeats:NO];

        [comment saveEventually:^(BOOL succeeded, NSError *error) {
            [timer invalidate];
            
            if (error && [error code] == kPFErrorObjectNotFound) {
//                [[PAPCache sharedCache] decrementCommentCountForPhoto:self.photo];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not post comment" message:@"This photo was deleted by its owner" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                // refresh cache
                
                NSMutableSet *channelSet = [NSMutableSet setWithCapacity:self.objects.count];
                
                // set up this push notification to be sent to all commenters, excluding the current  user
                for (PFObject *comment in self.objects) {
                    PFUser *author = [comment objectForKey:kPMActivityFromUserKey];
                    NSString *privateChannelName = [author objectForKey:kPMUserPrivateChannelKey];
                    if (privateChannelName && privateChannelName.length != 0 && ![[author objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                        [channelSet addObject:privateChannelName];
                    }
                }
                [channelSet addObject:[self.skill objectForKey:kPMSkillUserKey]];
                
                if (channelSet.count > 0) {
                    NSString *alert = [NSString stringWithFormat:@"%@: %@", [PMUtility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kPMUserDisplayNameKey]], trimmedComment];
                    
                    // make sure to leave enough space for payload overhead
                    if (alert.length > 100) {
                        alert = [alert substringToIndex:99];
                        alert = [alert stringByAppendingString:@"…"];
                    }
                    
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          alert, kAPNSAlertKey,
                                          kPMRPushPayloadPayloadTypeActivityKey, kPMRPushPayloadPayloadTypeKey,
                                          kPMRPushPayloadActivityCommentKey, kPMRPushPayloadActivityTypeKey,
                                          [[PFUser currentUser] objectId], kPMRPushPayloadFromUserObjectIdKey,
                                          [self.skill objectId], kPMRPushPayloadSkillObjectIdKey,
                                          @"Increment",kAPNSBadgeKey,
                                          nil];
                    PFPush *push = [[PFPush alloc] init];
                    [push setChannels:[channelSet allObjects]];
                    [push setData:data];
                    [push sendPushInBackground];
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PMRSkillDetailsViewControllerUserCommentedOnSkillNotification object:self.skill userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.objects.count + 1] forKey:@"comments"]];
            
//            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
        }];
    }
    [textField setText:@""];
    return [textField resignFirstResponder];
}


#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == MainActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this skill?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes, delete skill" otherButtonTitles:nil];
            actionSheet.tag = ConfirmDeleteActionSheetTag;
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        }
    } else if (actionSheet.tag == ConfirmDeleteActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PMRSkillDetailsViewControllerUserDeletedSkillNotification object:[self.skill objectId]];
            
            // Delete all activites related to this photo
            PFQuery *query = [PFQuery queryWithClassName:kPMActivityClassKey];
            [query whereKey:kPMActivitySkillKey equalTo:self.skill];
            [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
                if (!error) {
                    for (PFObject *activity in activities) {
                        [activity deleteEventually];
                    }
                }
                
                // Delete photo
                [self.skill deleteEventually];
            }];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [commentTextField resignFirstResponder];
}


#pragma mark - PAPBaseTextCellDelegate

- (void)cell:(PMRBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser {
    [self shouldPresentAccountViewForUser:aUser];
}


#pragma mark - PAPPhotoDetailsHeaderViewDelegate

-(void)photoDetailsHeaderView:(PMRSkillDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    [self shouldPresentAccountViewForUser:user];
}

- (void)actionButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:nil];
    actionSheet.tag = MainActionSheetTag;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}


#pragma mark - ()

- (void)handleCommentTimeout:(NSTimer *)aTimer {
//    [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Comment" message:@"Your comment will be posted next time there is an Internet connection."  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
    [alert show];
}

- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    PMRAccountViewController *accountViewController = [[PMRAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userLikedOrUnlikedPhoto:(NSNotification *)note {
    [self.headerView reloadEndorseBar];
}

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-kbSize.height) animated:YES];
}


@end
