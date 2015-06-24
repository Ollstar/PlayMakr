//
//  PMSkillHeaderView.h
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-23.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

typedef enum {
    PMRSkillHeaderButtonsNone = 0,
    PMRSkillHeaderButtonsEndorse = 1 << 0,
    PMRSkillHeaderButtonsComment = 1 << 1,
    PMRSkillHeaderButtonsUser = 1 << 2,
    
    PMSkillHeaderButtonsDefault = PMRSkillHeaderButtonsEndorse | PMRSkillHeaderButtonsComment | PMRSkillHeaderButtonsUser
} PMSkillHeaderButtons;

@protocol PMRSkillHeaderViewDelegate;

@interface PMRSkillHeaderView : UIView

/*! @name Creating Skill Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
- (id)initWithFrame:(CGRect)frame buttons:(PMSkillHeaderButtons)otherButtons;

/// The skill associated with this view
@property (nonatomic,strong) PFObject *skill;

/// The bitmask which specifies the enabled interaction elements in the view
@property (nonatomic, readonly, assign) PMSkillHeaderButtons buttons;

/*! @name Accessing Interaction Elements */

/// The Endorse Skill button
@property (nonatomic,readonly) UIButton *endorseButton;

/// The Comment On Skill button
@property (nonatomic,readonly) UIButton *commentButton;

/*! @name Delegate */
@property (nonatomic,weak) id <PMRSkillHeaderViewDelegate> delegate;

/*! @name Modifying Interaction Elements Status */

/*!
 Configures the Like Button to match the given like status.
 @param liked a BOOL indicating if the associated photo is liked by the user
 */
- (void)setEndorseStatus:(BOOL)endorsed;

/*!
 Enable the like button to start receiving actions.
 @param enable a BOOL indicating if the like button should be enabled.
 */
- (void)shouldEnableEndorseButton:(BOOL)enable;

@end


/*!
 The protocol defines methods a delegate of a PMSkillHeaderView should implement.
 All methods of the protocol are optional.
 */
@protocol PMSkillHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
- (void)skillHeaderView:(PMRSkillHeaderView *)skillHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user;

/*!
 Sent to the delegate when the endorse skill button is tapped
 @param photo the PFObject for the skill that is being endorsed or removed Endorsement
 */
- (void)skillHeaderView:(PMRSkillHeaderView *)skillHeaderView didTapEndorseSkillButton:(UIButton *)button skill:(PFObject *)skill;

/*!
 Sent to the delegate when the comment on photo button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
- (void)skillHeaderView:(PMRSkillHeaderView *)skillHeaderView didTapCommentOnSkillButton:(UIButton *)button skill:(PFObject *)skill;

@end
