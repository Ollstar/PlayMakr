//
//  PMConstants.m
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-23.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import "PMConstants.h"

@implementation PMConstants

NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.parse.Anypic.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsCacheFacebookFriendsKey                     = @"com.parse.Anypic.userDefaults.cache.facebookFriends";


#pragma mark - Launch URLs

NSString *const kPAPLaunchURLHostTakePicture = @"camera";


#pragma mark - NSNotification

NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification           = @"Oliver.PlayMakr.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const PAPUtilityUserFollowingChangedNotification                      = @"Oliver.PlayMakr.utility.userFollowingChanged";
NSString *const PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification     = @"Oliver.PlayMakr.utility.userLikedUnlikedPhotoCallbackFinished";
NSString *const PAPUtilityDidFinishProcessingProfilePictureNotification         = @"Oliver.PlayMakr.utility.didFinishProcessingProfilePictureNotification";
NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification            = @"Oliver.PlayMakr.tabBarController.didFinishEditingPhoto";
NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification         = @"com.parse.Anypic.tabBarController.didFinishImageFileUploadNotification";
NSString *const PAPPhotoDetailsViewControllerUserDeletedPhotoNotification       = @"com.parse.Anypic.photoDetailsViewController.userDeletedPhoto";
NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification  = @"com.parse.Anypic.photoDetailsViewController.userLikedUnlikedPhotoInDetailsViewNotification";
NSString *const PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification   = @"com.parse.Anypic.photoDetailsViewController.userCommentedOnPhotoInDetailsViewNotification";


#pragma mark - User Info Keys
NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey = @"liked";
NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey = @"comment";

#pragma mark - Installation Class

// Field keys
NSString *const kPMInstallationUserKey = @"user";
NSString *const kPMInstallationChannelsKey = @"channels";

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
NSString *const kPMActivityTypeLike       = @"endorse";
NSString *const kPMActivityTypeFollow     = @"follow";
NSString *const kPMActivityTypeComment    = @"comment";
NSString *const kPMActivityTypeJoined     = @"joined";

#pragma mark - User Class
// Field keys
NSString *const kPMUserDisplayNameKey                          = @"displayName";
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
NSString *const kPAPPhotoPictureKey         = @"image";
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
NSString *const kPAPPushPayloadPayloadTypeKey          = @"p";
NSString *const kPAPPushPayloadPayloadTypeActivityKey  = @"a";

NSString *const kPAPPushPayloadActivityTypeKey     = @"t";
NSString *const kPAPPushPayloadActivityLikeKey     = @"l";
NSString *const kPAPPushPayloadActivityCommentKey  = @"c";
NSString *const kPAPPushPayloadActivityFollowKey   = @"f";

NSString *const kPAPPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kPAPPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kPAPPushPayloadPhotoObjectIdKey    = @"pid";

@end
