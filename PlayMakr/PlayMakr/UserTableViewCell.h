//
//  UserTableViewCell.h
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-20.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) NSString *userObjectID;

@end
