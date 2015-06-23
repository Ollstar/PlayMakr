//
//  PMConstants.h
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-23.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMConstants : NSObject




#pragma mark - NSUserDefaults
extern NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kPAPUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Launch URLs

extern NSString *const kPAPLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const PMAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const PMUtilityUserFollowingChangedNotification;
extern NSString *const PMUtilityUserEndorsedUnendorsedSkillCallbackFinishedNotification;
extern NSString *const PMUtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification;
extern NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserDeletedPhotoNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification;


#pragma mark - User Info Keys
extern NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey;
extern NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey;


#pragma mark - Installation Class

// Field keys
extern NSString *const kPMInstallationUserKey;
extern NSString *const kPMInstallationChannelsKey;


#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kPMActivityClassKey;

// Field keys
extern NSString *const kPMActivityTypeKey;
extern NSString *const kPMActivityFromUserKey;
extern NSString *const kPMActivityToUserKey;
extern NSString *const kPMActivityContentKey;
extern NSString *const kPMActivitySkillKey;

// Type values
extern NSString *const kPMActivityTypeEndorse;
extern NSString *const kPMActivityTypeFollow;
extern NSString *const kPMActivityTypeComment;
extern NSString *const kPMActivityTypeJoined;


#pragma mark - PFObject User Class
// Field keys
extern NSString *const kPMUserDisplayNameKey;
extern NSString *const kPMUserFacebookIDKey;
extern NSString *const kPMUserPhotoIDKey;
extern NSString *const kPMUserProfilePicSmallKey;
extern NSString *const kPMUserProfilePicMediumKey;
extern NSString *const kPMUserAlreadyAutoFollowedFacebookFriendsKey;
extern NSString *const kPMUserPrivateChannelKey;


#pragma mark - PFObject Skill Class
// Class key
extern NSString *const kPMSkillClassKey;

// Field keys
extern NSString *const kPMPhotoPictureKey;
extern NSString *const kPAPPhotoThumbnailKey;
extern NSString *const kPMSkillUserKey;


#pragma mark - Cached Skill Attributes
// keys
extern NSString *const kPMSkillAttributesIsEndorsedByCurrentUserKey;
extern NSString *const kPMSkillAttributesEndorseCountKey;
extern NSString *const kPMSkillAttributesEndorsersKey;
extern NSString *const kPMSkillAttributesCommentCountKey;
extern NSString *const kPMSkillAttributesCommentersKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kPMUserAttributesSkillCountKey;
extern NSString *const kPMUserAttributesIsFollowedByCurrentUserKey;


#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kPAPPushPayloadPayloadTypeKey;
extern NSString *const kPAPPushPayloadPayloadTypeActivityKey;

extern NSString *const kPAPPushPayloadActivityTypeKey;
extern NSString *const kPAPPushPayloadActivityLikeKey;
extern NSString *const kPAPPushPayloadActivityCommentKey;
extern NSString *const kPAPPushPayloadActivityFollowKey;

extern NSString *const kPAPPushPayloadFromUserObjectIdKey;
extern NSString *const kPAPPushPayloadToUserObjectIdKey;
extern NSString *const kPAPPushPayloadPhotoObjectIdKey;

@end
