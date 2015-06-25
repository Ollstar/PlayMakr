//
//  PMConstants.m
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-23.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import "PMConstants.h"

@implementation PMConstants

NSString *const kPMRUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"Oliver.PlayMakr.userDefaults.activityFeedViewController.lastRefresh";


#pragma mark - Launch URLs

NSString *const kPAPLaunchURLHostTakePicture = @"camera";


#pragma mark - NSNotification

NSString *const PMAppDelegateApplicationDidReceiveRemoteNotification           = @"Oliver.PlayMakr.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const PMUtilityUserFollowingChangedNotification                      = @"Oliver.PlayMakr.utility.userFollowingChanged";
NSString *const PMUtilityUserEndorsedUnendorsedSkillCallbackFinishedNotification     = @"Oliver.PlayMakr.utility.userEndorsedUnendorsedSkillCallbackFinished";
NSString *const PAPUtilityDidFinishProcessingProfilePictureNotification         = @"Oliver.PlayMakr.utility.didFinishProcessingProfilePictureNotification";
NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification            = @"Oliver.PlayMakr.tabBarController.didFinishEditingPhoto";
NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification         = @"com.parse.Anypic.tabBarController.didFinishImageFileUploadNotification";
NSString *const PMRSkillDetailsViewControllerUserDeletedSkillNotification       = @"Oliver.PlayMakr.skillDetailsViewController.userDeletedSkill";
NSString *const PMSkillDetailsViewControllerUserEndorsedUnendorsedSkillNotification  = @"Oliver.PlayMakr.skillDetailsViewController.userEndorsedUnendorsedInDetailsViewNotification";
NSString *const PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification   = @"Oliver.PlayMakr.skillDetailsViewController.userCommentedOnSkillInDetailsViewNotification";


#pragma mark - User Info Keys
NSString *const PMSkillDetailsViewControllerUserEndorsedUnendorsedSkillNotificationUserInfoEndorsedKey = @"endorsed";
NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey = @"comment";

#pragma mark - Installation Class

// Field keys
NSString *const kPMRInstallationUserKey = @"user";
NSString *const kPMRInstallationChannelsKey = @"channels";

#pragma mark - Activity Class
// Class key
NSString *const kPMActivityClassKey = @"Activity";

// Field keys
NSString *const kPMActivityTypeKey        = @"type";
NSString *const kPMActivityFromUserKey    = @"fromUser";
NSString *const kPMActivityToUserKey      = @"toUser";
NSString *const kPMActivityContentKey     = @"content";
NSString *const kPMActivitySkillKey       = @"skill";

// Type values
NSString *const kPMActivityTypeEndorse       = @"endorse";
NSString *const kPMActivityTypeFollow     = @"follow";
NSString *const kPMActivityTypeComment    = @"comment";
NSString *const kPMActivityTypeJoined     = @"joined";

#pragma mark - User Class
// Field keys
NSString *const kPMUserDisplayNameKey                          = @"username";
NSString *const kPAPUserFacebookIDKey                           = @"facebookId";
NSString *const kPAPUserPhotoIDKey                              = @"photoId";
NSString *const kPMUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kPMUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";
NSString *const kPMUserPrivateChannelKey                       = @"channel";

#pragma mark - Skill Class
// Class key
NSString *const kPMSkillClassKey = @"Skill";

// Field keys
NSString *const kPMSkillPictureKey         = @"image";
NSString *const kPAPPhotoThumbnailKey       = @"thumbnail";
NSString *const kPMSkillUserKey            = @"user";


#pragma mark - Cached Photo Attributes
// keys
NSString *const kPMSkillAttributesIsEndorsedByCurrentUserKey = @"isEndorsedByCurrentUser";
NSString *const kPMSkillAttributesEndorseCountKey            = @"endorseCount";
NSString *const kPMSkillAttributesEndorsersKey               = @"endorsers";
NSString *const kPAPPhotoAttributesCommentCountKey         = @"commentCount";
NSString *const kPAPPhotoAttributesCommentersKey           = @"commenters";


#pragma mark - Cached User Attributes
// keys
NSString *const kPMUserAttributesSkillCountKey                 = @"skillCount";
NSString *const kPMUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";


#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";

// the following keys are intentionally kept short, APNS has a maximum payload limit
NSString *const kPMRPushPayloadPayloadTypeKey          = @"p";
NSString *const kPMRPushPayloadPayloadTypeActivityKey  = @"a";

NSString *const kPMRPushPayloadActivityTypeKey     = @"t";
NSString *const kPMRPushPayloadActivityEndorseKey     = @"e";
NSString *const kPMRPushPayloadActivityCommentKey  = @"c";
NSString *const kPMRPushPayloadActivityFollowKey   = @"f";

NSString *const kPMRPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kPMRPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kPMRPushPayloadSkillObjectIdKey    = @"sid";

@end
