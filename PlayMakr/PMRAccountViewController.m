//
//  PAPAccountViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/2/12.
//

#import "PMRAccountViewController.h"
#import "PMRPhotoCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "PMRLoadMoreCell.h"
#import "PMConstants.h"
#import "PMCache.h"
#import "PMUtility.h"
#import <SCLAlertView.h>
#import "UIImage+ResizeAdditions.h"
#import "PMREditButtonItem.h"



@interface PMRAccountViewController()
@property (nonatomic, strong) UIView *headerView;
@end

@implementation PMRAccountViewController
@synthesize headerView;
@synthesize user;

#pragma mark - Initialization

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.user) {
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
    }

    self.navigationItem.title = @"PlayMakr";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake( 0.0f, 0.0f, 52.0f, 32.0f)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[backButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 222.0f)];
    [self.headerView setBackgroundColor:[UIColor clearColor]]; // should be clear, this will be the container for our avatar, photo count, follower count, following count, and so on
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;
    UIView *profilePictureBackgroundView = [[UIView alloc] initWithFrame:CGRectMake( 94.0f, 38.0f, 132.0f, 132.0f)];
    [profilePictureBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    profilePictureBackgroundView.alpha = 0.0f;
    CALayer *layer = [profilePictureBackgroundView layer];
    layer.cornerRadius = 10.0f;
    layer.masksToBounds = YES;
    [self.headerView addSubview:profilePictureBackgroundView];
    
    self.userProfileImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 94.0f, 38.0f, 132.0f, 132.0f)];
    [self.headerView addSubview:self.userProfileImageView];
    [self.userProfileImageView setContentMode:UIViewContentModeScaleAspectFill];
    layer = [self.userProfileImageView layer];
    layer.cornerRadius = 10.0f;
    layer.masksToBounds = YES;
    self.userProfileImageView.alpha = 0.0f;
    UIImageView *profilePictureStrokeImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 88.0f, 34.0f, 143.0f, 143.0f)];
    profilePictureStrokeImageView.alpha = 0.0f;
    [profilePictureStrokeImageView setImage:[UIImage imageNamed:@"ProfilePictureStroke.png"]];
    [self.headerView addSubview:profilePictureStrokeImageView];

    
    UIImageView *skillCountIconImageView = [[UIImageView alloc] initWithImage:nil];
    [skillCountIconImageView setImage:[UIImage imageNamed:@"IconPics.png"]];
    [skillCountIconImageView setFrame:CGRectMake( 26.0f, 50.0f, 45.0f, 37.0f)];
    [self.headerView addSubview:skillCountIconImageView];
    
    UILabel *skillCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f, 94.0f, 92.0f, 22.0f)];
    [skillCountLabel setTextAlignment:NSTextAlignmentCenter];
    [skillCountLabel setBackgroundColor:[UIColor clearColor]];
    [skillCountLabel setTextColor:[UIColor whiteColor]];
    [skillCountLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [skillCountLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [skillCountLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [self.headerView addSubview:skillCountLabel];
    
    UIImageView *followersIconImageView = [[UIImageView alloc] initWithImage:nil];
    [followersIconImageView setImage:[UIImage imageNamed:@"IconFollowers.png"]];
    [followersIconImageView setFrame:CGRectMake( 247.0f, 50.0f, 52.0f, 37.0f)];
    [self.headerView addSubview:followersIconImageView];
    
    UILabel *followerCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 226.0f, 94.0f, self.headerView.bounds.size.width - 226.0f, 16.0f)];
    [followerCountLabel setTextAlignment:NSTextAlignmentCenter];
    [followerCountLabel setBackgroundColor:[UIColor clearColor]];
    [followerCountLabel setTextColor:[UIColor whiteColor]];
    [followerCountLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [followerCountLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [followerCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [self.headerView addSubview:followerCountLabel];
    
    UILabel *followingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 226.0f, 110.0f, self.headerView.bounds.size.width - 226.0f, 16.0f)];
    [followingCountLabel setTextAlignment:NSTextAlignmentCenter];
    [followingCountLabel setBackgroundColor:[UIColor clearColor]];
    [followingCountLabel setTextColor:[UIColor whiteColor]];
    [followingCountLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [followingCountLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [followingCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [self.headerView addSubview:followingCountLabel];
    
    UILabel *userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 176.0f, self.headerView.bounds.size.width, 22.0f)];
    [userDisplayNameLabel setTextAlignment:NSTextAlignmentCenter];
    [userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
    [userDisplayNameLabel setTextColor:[UIColor whiteColor]];
    [userDisplayNameLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [userDisplayNameLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [userDisplayNameLabel setText:[self.user objectForKey:@"displayName"]];
    [userDisplayNameLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [self.headerView addSubview:userDisplayNameLabel];
    
    [skillCountLabel setText:@"0 games"];
    
    PFQuery *querySkillCount = [PFQuery queryWithClassName:@"Skill"];
    [querySkillCount whereKey:kPMSkillUserKey equalTo:self.user];
    [querySkillCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [querySkillCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [skillCountLabel setText:[NSString stringWithFormat:@"%d game%@", number, number==1?@"":@"s"]];
            [[PMCache sharedCache] setSkillCount:[NSNumber numberWithInt:number] user:self.user];
        }
    }];
    
    [followerCountLabel setText:@"0 followers"];
    
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPMActivityClassKey];
    [queryFollowerCount whereKey:kPMActivityTypeKey equalTo:kPMActivityTypeFollow];
    [queryFollowerCount whereKey:kPMActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    NSLog(@"Cached: %d", [queryFollowerCount hasCachedResult]);
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSLog(@"Cached callback: %d", [queryFollowerCount hasCachedResult]);
        if (!error) {
            [followerCountLabel setText:[NSString stringWithFormat:@"%d follower%@", number, number==1?@"":@"s"]];
        }
    }];

    NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
    [followingCountLabel setText:@"0 following"];
    if (followingDictionary) {
//        [followingCountLabel setText:[NSString stringWithFormat:@"%d following", [[followingDictionary allValues] count]]];
        [followingCountLabel setText:[NSString stringWithFormat:@"%lu following", (unsigned long)[[followingDictionary allValues] count]]];
    }
    
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPMActivityClassKey];
    [queryFollowingCount whereKey:kPMActivityTypeKey equalTo:kPMActivityTypeFollow];
    [queryFollowingCount whereKey:kPMActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followingCountLabel setText:[NSString stringWithFormat:@"%d following", number]];
        }
    }];
    [self configureEditButton];
    PFFile *imageFile = [self.user objectForKey:@"profileImage"];
    if (imageFile) {
        [self.userProfileImageView setFile:imageFile];
        [self.userProfileImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.200f animations:^{
                    profilePictureBackgroundView.alpha = 1.0f;
                    profilePictureStrokeImageView.alpha = 1.0f;
                    self.userProfileImageView.alpha = 1.0f;
                }];
            }
        }];
    }

    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingActivityIndicatorView startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
        
        // check if the currentUser is following this user
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kPMActivityClassKey];
        [queryIsFollowing whereKey:kPMActivityTypeKey equalTo:kPMActivityTypeFollow];
        [queryIsFollowing whereKey:kPMActivityToUserKey equalTo:self.user];
        [queryIsFollowing whereKey:kPMActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error && [error code] != kPFErrorCacheMiss) {
                NSLog(@"Couldn't determine follow relationship: %@", error);
                self.navigationItem.rightBarButtonItem = nil;
            } else {
                if (number == 0) {
                    [self configureFollowButton];
                } else {
                    [self configureUnfollowButton];
                }
            }
        }];
    }
}



- (IBAction)editButtonTap:(id)sender {
    //enable all fields that accept user interaction - make everything editable slighly opaque - hide the unlock button and show the lock button

    self.userProfileImageView.userInteractionEnabled = YES;
    //this can only be triggered when the user's profile is "unlocked"
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Take a new photo", @"Choose from existing", nil];
    [actionSheet showInView:self.view];
    self.userProfileImageView.alpha =.7;
    
}
//- (IBAction)lockUserTap:(id)sender {
//    //disable all fields that accept user interaction - make everything totally opaque - hide the lock button and show the unlock button
//    
//
//    self.userProfileImageView.userInteractionEnabled = NO;
//    self.userProfileImageView.alpha=1;
//    [self configureUnlockButton];
//
//    
//
//}
//- (IBAction)userImageTap:(id)sender {
//    //this can only be triggered when the user's profile is "unlocked"
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
//                                                             delegate: self
//                                                    cancelButtonTitle: @"Cancel"
//                                               destructiveButtonTitle: nil
//                                                    otherButtonTitles: @"Take a new photo", @"Choose from existing", nil];
//    [actionSheet showInView:self.view];
//    
//}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self takeNewPhoto];
            break;
        case 1:
            [self pickOldPhoto];
            break;
    }
}

-(void)takeNewPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)pickOldPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - image picker controller delegate calls

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    NSData* imageToBeUploaded = UIImageJPEGRepresentation(chosenImage, 50);

    UIImage *mediumImage = [chosenImage thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures

    UIImage *smallRoundedImage = [chosenImage thumbnailImage:64 transparentBorder:0 cornerRadius:9 interpolationQuality:kCGInterpolationLow];
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);

    
    PFFile *imageFile = [PFFile fileWithName:@"profileImage" data:imageToBeUploaded];
    [[PFUser currentUser] setObject:imageFile forKey:@"profileImage"];
    PFFile *fileMediumImage = [PFFile fileWithName:kPMUserProfilePicMediumKey data:mediumImageData];
    [[PFUser currentUser] setObject:fileMediumImage forKey:kPMUserProfilePicMediumKey];
    PFFile *fileSmallRoundedImage = [PFFile fileWithName:kPMUserProfilePicSmallKey data:smallRoundedImageData];
    [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kPMUserProfilePicSmallKey];
    
//    if (mediumImageData.length > 0) {
//        NSLog(@"Uploading Medium Profile Picture");
//        PFFile *fileMediumImage = [PFFile fileWithName:kPMUserProfilePicMediumKey data:mediumImageData];
//        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (!error) {
//                NSLog(@"Uploaded Medium Profile Picture");
//                [[PFUser currentUser] setObject:fileMediumImage forKey:kPMUserProfilePicMediumKey];
//                [[PFUser currentUser] saveEventually];
//            }
//        }];
//    }
//    
//    if (smallRoundedImageData.length > 0) {
//        NSLog(@"Uploading Profile Picture Thumbnail");
//        PFFile *fileSmallRoundedImage = [PFFile fileWithName:kPMUserProfilePicSmallKey data:smallRoundedImageData];
//        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (!error) {
//                NSLog(@"Uploaded Profile Picture Thumbnail");
//                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kPMUserProfilePicSmallKey];
//                [[PFUser currentUser] saveEventually];
//            }
//        }];
//    }
    
    
    self.userProfileImageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];

    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded){
            NSLog(@"saved new user profile image");
        }
        else{
            NSLog(@"error saving profile image %@",error);
        }
    }];
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    self.tableView.tableHeaderView = headerView;
}

- (PFQuery *)queryForTable {
    if (!self.user) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query whereKey:kPMSkillUserKey equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query includeKey:kPMSkillUserKey];
    
    return query;
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


#pragma mark - ()

- (void)followButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];

    [self configureUnfollowButton];

    [PMUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        if (error) {
            [self configureFollowButton];
        }
    }];
}

- (void)unfollowButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];

    [self configureFollowButton];

    [PMUtility unfollowUserEventually:self.user];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureEditButton {
    self.navigationItem.rightBarButtonItem = [[PMREditButtonItem alloc] initWithTarget:self action:@selector(editButtonTap:)];

}


- (void)configureFollowButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStylePlain target:self action:@selector(followButtonAction:)];
    [[PMCache sharedCache] setFollowStatus:NO user:self.user];
}

- (void)configureUnfollowButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStylePlain target:self action:@selector(unfollowButtonAction:)];
    [[PMCache sharedCache] setFollowStatus:YES user:self.user];
}

@end