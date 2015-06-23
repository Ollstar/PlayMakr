//
//  PMCache.h
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-23.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface PMCache : NSObject

+ (id)sharedCache;

- (void)clear;
- (void)setAttributesForSkill:(PFObject *)skill endorsers:(NSArray *)endorsers endorsedByCurrentUser:(BOOL)endorsedByCurrentUser;
- (NSDictionary *)attributesForSkill:(PFObject *)skill;
- (NSNumber *)endorseCountForSkill:(PFObject *)skill;
- (NSArray *)endorsersForSkill:(PFObject *)skill;
- (void)setSkillIsEndorsedByCurrentUser:(PFObject *)skill endorsed:(BOOL)endorsed;
- (BOOL)isSkillEndorsedByCurrentUser:(PFObject *)skill;
- (void)incrementEndorserCountForSkill:(PFObject *)skill;
- (void)decrementEndorserCountForSkill:(PFObject *)skill;

- (NSDictionary *)attributesForUser:(PFUser *)user;
- (NSNumber *)skillCountForUser:(PFUser *)user;
- (BOOL)followStatusForUser:(PFUser *)user;
- (void)setSkillCount:(NSNumber *)count user:(PFUser *)user;
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;

@end
