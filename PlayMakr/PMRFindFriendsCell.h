//
//  PAPFindFriendsCell.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/31/12.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class PMRProfileImageView;
@protocol PMRFindFriendsCellDelegate;

@interface PMRFindFriendsCell : UITableViewCell {
    id _delegate;
}

@property (nonatomic, strong) id<PMRFindFriendsCellDelegate> delegate;

/*! The user represented in the cell */
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UILabel *photoLabel;
@property (nonatomic, strong) UIButton *followButton;

/*! Setters for the cell's content */
- (void)setUser:(PFUser *)user;

- (void)didTapUserButtonAction:(id)sender;
- (void)didTapFollowButtonAction:(id)sender;

/*! Static Helper methods */
+ (CGFloat)heightForCell;

@end

/*!
 The protocol defines methods a delegate of a PMRBaseTextCell should implement.
 */
@protocol PMRFindFriendsCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a user button is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (void)cell:(PMRFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser;
- (void)cell:(PMRFindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser;

@end
