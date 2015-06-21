//
//  PlayrUser.m
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-20.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import "PlayrUser.h"
#import <Parse/PFObject+Subclass.h>

@implementation PlayrUser

@dynamic age;
@dynamic name;
@dynamic city;
@dynamic bio;

+ (PlayrUser *)user {
    return (PlayrUser *)[PFUser user];
}

@end
