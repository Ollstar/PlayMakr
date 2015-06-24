//
//  ProfileViewController.m
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-22.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *testLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self loadProfile];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadProfile {
    PFUser *currentUser = [PFUser currentUser];
    
    
    if (![currentUser.objectId isEqualToString:self.profileUser.objectId]) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        
        self.navigationItem.leftBarButtonItem = backButton;
        
        
        
    }
}
- (void)determineConnectButton {
    //set to follow button if not connected to currentUser

    PFRelation *relation = [[PFUser currentUser] objectForKey:@"connected"];
    
    PFQuery *query = relation.query;
    [query whereKey:@"objectId" equalTo:self.profileUser.objectId];
    NSInteger count = [query countObjects];
    
    if (count == 0) {
        self.isConnected = NO;
        UIBarButtonItem *followButton = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style: UIBarButtonItemStylePlain target:self action:@selector(followButtonPressed:)];
        self.navigationItem.rightBarButtonItem = followButton;
    } else {
        self.isConnected = YES;
        UIBarButtonItem *unfollowButton = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style: UIBarButtonItemStylePlain target:self action:@selector(unfollowButtonPressed:)];
        self.navigationItem.rightBarButtonItem = unfollowButton;
    }
//    PFRelation *relation = [[PFUser currentUser] objectForKey:@"connected"];
//    PFQuery *query = [[relation query] whereKey:@"connected" equalTo:self.profileUser];
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
//        
//        if (!error) {
//            UIBarButtonItem *unfollowButton = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style: UIBarButtonItemStylePlain target:self action:@selector(unfollowButtonPressed:)];
//            self.navigationItem.rightBarButtonItem = unfollowButton;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.navigationController reloadInputViews];
//            });
//        }
//    }];
    
    
    

    
    
}

- (IBAction)backButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)followButtonPressed: (UIBarButtonItem *)sender {
    sender.tintColor = [UIColor colorWithRed:0.882 green:0.722 blue:0.169 alpha:1];
    PFRelation *relation = [[PFUser currentUser] objectForKey:@"connected"];
    
    [relation addObject:self.profileUser];
    [[PFUser currentUser] saveInBackground];
    
    
}

- (IBAction)unfollowButtonPressed: (UIBarButtonItem *)sender {
    sender.tintColor = [UIColor colorWithRed:0.882 green:0.722 blue:0.169 alpha:1];
    PFRelation *relation = [[PFUser currentUser] objectForKey:@"connected"];
    
    [relation removeObject:self.profileUser];
    [[PFUser currentUser] saveInBackground];
    
}

@end