//
//  PMUtility.m
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-23.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import "PMUtility.h"
#import "PMCache.h"
#import "PMConstants.h"
#import "UIImage+ResizeAdditions.h"



@implementation PMUtility


#pragma mark - PMUtility
#pragma mark Endorse Skills

+ (void)endorseSkillInBackground:(id)skill block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingEndorsements = [PFQuery queryWithClassName:kPMActivityClassKey];
    [queryExistingEndorsements whereKey:kPMActivitySkillKey equalTo:skill];
    [queryExistingEndorsements whereKey:kPMActivityTypeKey equalTo:kPMActivityTypeEndorse];
    [queryExistingEndorsements whereKey:kPMActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingEndorsements setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingEndorsements findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new endorsement
        PFObject *endorseActivity = [PFObject objectWithClassName:kPMActivityClassKey];
        [endorseActivity setObject:kPMActivityTypeEndorse forKey:kPMActivityTypeKey];
        [endorseActivity setObject:[PFUser currentUser] forKey:kPMActivityFromUserKey];
        [endorseActivity setObject:[skill objectForKey:kPMSkillUserKey] forKey:kPMActivityToUserKey];
        [endorseActivity setObject:skill forKey:kPMActivitySkillKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        endorseActivity.ACL = likeACL;
        
        [endorseActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            
            if (succeeded && ![[[skill objectForKey:kPMSkillUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                NSString *privateChannelName = [[skill objectForKey:kPMSkillUserKey] objectForKey:kPMUserPrivateChannelKey];
                if (privateChannelName && privateChannelName.length != 0) {
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSString stringWithFormat:@"%@ endorses your skill.", [PMUtility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kPMUserDisplayNameKey]]], kAPNSAlertKey,
                                          kPMRPushPayloadPayloadTypeActivityKey, kPMRPushPayloadPayloadTypeKey,
                                          kPMRPushPayloadActivityEndorseKey, kPMRPushPayloadActivityTypeKey,
                                          [[PFUser currentUser] objectId], kPMRPushPayloadFromUserObjectIdKey,
                                          [skill objectId], kPMRPushPayloadSkillObjectIdKey,
                                          nil];
                    PFPush *push = [[PFPush alloc] init];
                    [push setChannel:privateChannelName];
                    [push setData:data];
                    [push sendPushInBackground];
                }
            }
            
            // refresh cache
            PFQuery *query = [PMUtility queryForActivitiesOnSkill:skill cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *endorsers = [NSMutableArray array];
                    
                    BOOL isEndorsedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPMActivityTypeKey]isEqualToString:kPMActivityTypeEndorse] && [activity objectForKey:kPMActivityFromUserKey]) {
                            [endorsers addObject:[activity objectForKey:kPMActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPMActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPMActivityTypeKey]isEqualToString:kPMActivityTypeEndorse]) {
                                isEndorsedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PMCache sharedCache] setAttributesForSkill:skill endorsers:endorsers endorsedByCurrentUser:isEndorsedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PMUtilityUserEndorsedUnendorsedSkillCallbackFinishedNotification object:skill userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:@"liked"]];
            }];
            
        }];
    }];

}
+(void)removeEndorsementForSkillInBackground:(id)skill block:(void (^)(BOOL, NSError *))completionBlock {
    PFQuery *queryExistingEndorsements = [PFQuery queryWithClassName:kPMActivityClassKey];
    [queryExistingEndorsements whereKey:kPMActivitySkillKey equalTo:skill];
    [queryExistingEndorsements whereKey:kPMActivityTypeKey equalTo:kPMActivityTypeEndorse];
    [queryExistingEndorsements whereKey:kPMActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingEndorsements setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingEndorsements findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            
            // refresh cache
            PFQuery *query = [PMUtility queryForActivitiesOnSkill:skill cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *endorsers = [NSMutableArray array];
                    
                    BOOL isEndorsedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPMActivityTypeKey]isEqualToString:kPMActivityTypeEndorse]) {
                            [endorsers addObject:[activity objectForKey:kPMActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPMActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPMActivityTypeKey] isEqualToString:kPMActivityTypeEndorse]) {
                                isEndorsedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PMCache sharedCache] setAttributesForSkill:skill endorsers:endorsers endorsedByCurrentUser:isEndorsedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:
                 PMUtilityUserEndorsedUnendorsedSkillCallbackFinishedNotification object:skill userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:PMSkillDetailsViewControllerUserEndorsedUnendorsedSkillNotificationUserInfoEndorsedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];
}


+ (BOOL)userHasProfilePictures:(PFUser *)user {
    PFFile *profilePictureMedium = [user objectForKey:kPMUserProfilePicMediumKey];
    PFFile *profilePictureSmall = [user objectForKey:kPMUserProfilePicSmallKey];
    
    return (profilePictureMedium && profilePictureSmall);
}


#pragma mark Display Name

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    if (!displayName || displayName.length == 0) {
        return @"Someone";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    return firstName;
}


#pragma mark User Following

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kPMActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPMActivityFromUserKey];
    [followActivity setObject:user forKey:kPMActivityToUserKey];
    [followActivity setObject:kPMActivityTypeFollow forKey:kPMActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
        
        if (succeeded) {
            [PMUtility sendFollowingPushNotification:user];
        }
    }];
    [[PMCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kPMActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPMActivityFromUserKey];
    [followActivity setObject:user forKey:kPMActivityToUserKey];
    [followActivity setObject:kPMActivityTypeFollow forKey:kPMActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveEventually:completionBlock];
    [[PMCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [PMUtility followUserEventually:user block:completionBlock];
        [[PMCache sharedCache] setFollowStatus:YES user:user];
    }
}

+ (void)unfollowUserEventually:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:kPMActivityClassKey];
    [query whereKey:kPMActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPMActivityToUserKey equalTo:user];
    [query whereKey:kPMActivityTypeKey equalTo:kPMActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
    [[PMCache sharedCache] setFollowStatus:NO user:user];
}

+ (void)unfollowUsersEventually:(NSArray *)users {
    PFQuery *query = [PFQuery queryWithClassName:kPMActivityClassKey];
    [query whereKey:kPMActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPMActivityToUserKey containedIn:users];
    [query whereKey:kPMActivityTypeKey equalTo:kPMActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[PMCache sharedCache] setFollowStatus:NO user:user];
    }
}


#pragma mark Push

+ (void)sendFollowingPushNotification:(PFUser *)user {
    NSString *privateChannelName = [user objectForKey:kPMUserPrivateChannelKey];
    if (privateChannelName && privateChannelName.length != 0) {
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"%@ is now following you on PlayMakr.", [PMUtility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kPMUserDisplayNameKey]]], kAPNSAlertKey,
                              kPMRPushPayloadPayloadTypeActivityKey, kPMRPushPayloadPayloadTypeKey,
                              kPMRPushPayloadActivityTypeKey, kPMRPushPayloadActivityTypeKey,
                              [[PFUser currentUser] objectId], kPMRPushPayloadFromUserObjectIdKey,
                              nil];
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:privateChannelName];
        [push setData:data];
        [push sendPushInBackground];
    }
}

#pragma mark Activities

+ (PFQuery *)queryForActivitiesOnSkill:(PFObject *)skill cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryEndorsements = [PFQuery queryWithClassName:kPMActivityClassKey];
    [queryEndorsements whereKey:kPMActivitySkillKey equalTo:skill];
    [queryEndorsements whereKey:kPMActivityTypeKey equalTo:kPMActivityTypeEndorse];
    

    

    [queryEndorsements setCachePolicy:cachePolicy];
    [queryEndorsements includeKey:kPMActivityFromUserKey];
    [queryEndorsements includeKey:kPMActivitySkillKey];
    
    return queryEndorsements;
}


#pragma mark Shadow Rendering

+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 5.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y - 10.0f, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake( 0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake( 0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)addBottomDropShadowToNavigationBarForNavigationController:(UINavigationController *)navigationController {
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, navigationController.navigationBar.frame.size.height, navigationController.navigationBar.frame.size.width, 3.0f)];
    [gradientView setBackgroundColor:[UIColor clearColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [gradientView.layer insertSublayer:gradient atIndex:0];
    navigationController.navigationBar.clipsToBounds = NO;
    [navigationController.navigationBar addSubview:gradientView];	    
}

@end

