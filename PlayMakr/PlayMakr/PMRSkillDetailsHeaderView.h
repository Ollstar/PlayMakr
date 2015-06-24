//
//  PMSkillDetailsHeaderView.h
//  PlayMakr
//
//  Created by Ollstar.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol PMSkillDetailsHeaderViewDelegate;

@interface PMRSkillDetailsHeaderView : UIView

/*! @name Managing View Properties */

/// The skill displayed in the view
@property (nonatomic, strong, readonly) PFObject *skill;

/// The user that created the skill
@property (nonatomic, strong, readonly) PFUser *creator;

/// Array of the users that endorsed the skill
@property (nonatomic, strong) NSArray *endorseUsers;

/// Heart-shaped endorse button
@property (nonatomic, strong, readonly) UIButton *endorseButton;

/*! @name Delegate */
@property (nonatomic, strong) id<PMSkillDetailsHeaderViewDelegate> delegate;

+ (CGRect)rectForView;

- (id)initWithFrame:(CGRect)frame skill:(PFObject*)aSkill;
- (id)initWithFrame:(CGRect)frame skill:(PFObject*)aSkill creator:(PFUser*)aCreator endorseUsers:(NSArray*)theEndorseUsers;

- (void)setEndorseButtonState:(BOOL)selected;
- (void)reloadEndorseBar;
@end

/*!
 The protocol defines methods a delegate of a PMSkillDetailsHeaderView should implement.
 */
@protocol PMSkillDetailsHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the creator's name/avatar is tapped
 @param button the tapped UIButton
 @param user the PFUser for the creator
 */
- (void)skillDetailsHeaderView:(PMRSkillDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user;

@end