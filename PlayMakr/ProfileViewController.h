//
//  ProfileViewController.h
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-22.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileViewController : UIViewController

@property (nonatomic, strong) PFUser *profileUser;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) BOOL isCurrentUser;

@end
