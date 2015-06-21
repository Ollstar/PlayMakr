//
//  PlayrUser.h
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-20.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PlayrUser : PFUser <PFSubclassing>

@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) int *age;
@property (nonatomic, strong) NSString *city;

+(PlayrUser *)user;

@end
