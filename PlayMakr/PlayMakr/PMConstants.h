//
//  PMConstants.h
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-23.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PMRHomeTabBarItemIndex = 0,
    PMREmptyTabBarItemIndex = 1,
    PMRActivityTabBarItemIndex = 2
} PMRTabBarControllerViewControllerIndex;

@interface PMConstants : NSObject

#pragma mark - NSUserDefaults
extern NSString *const kPMRUserDefaultsActivityFeedViewControllerLastRefreshKey;

#pragma mark - Launch URLs

extern NSString *const kPAPLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const PMAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const PMUtilityUserFollowingChangedNotification;
extern NSString *const PMUtilityUserEndorsedUnendorsedSkillCallbackFinishedNotification;
extern NSString *const PMUtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification;
extern NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const PMRSkillDetailsViewControllerUserDeletedSkillNotification;
extern NSString *const PMSkillDetailsViewControllerUserEndorsedUnendorsedSkillNotification;
extern NSString *const PMRSkillDetailsViewControllerUserCommentedOnSkillNotification;


#pragma mark - User Info Keys
extern NSString *const PMSkillDetailsViewControllerUserEndorsedUnendorsedSkillNotificationUserInfoEndorsedKey;
extern NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey;


#pragma mark - Installation Class

// Field keys
extern NSString *const kPMRInstallationUserKey;
extern NSString *const kPMRInstallationChannelsKey;


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
extern NSString *const kPMSkillPictureKey;
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

extern NSString *const kPMRPushPayloadPayloadTypeKey;
extern NSString *const kPMRPushPayloadPayloadTypeActivityKey;

extern NSString *const kPMRPushPayloadActivityTypeKey;
extern NSString *const kPMRPushPayloadActivityEndorseKey;
extern NSString *const kPMRPushPayloadActivityCommentKey;
extern NSString *const kPMRPushPayloadActivityFollowKey;

extern NSString *const kPMRPushPayloadFromUserObjectIdKey;
extern NSString *const kPMRPushPayloadToUserObjectIdKey;
extern NSString *const kPMRPushPayloadSkillObjectIdKey;

@end
