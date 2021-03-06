//
//  PAPActivityCell.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/14/12.
//

#import "PMRBaseTextCell.h"

@protocol PMRActivityCellDelegate;

@interface PMRActivityCell : PMRBaseTextCell

/*! Setter for the activity associated with this cell */
@property (nonatomic, strong) PFObject *activity;

/*! Set the new state. This changes the background of the cell. */
- (void)setIsNew:(BOOL)isNew;

@end


/*!
 The protocol defines methods a delegate of a PMRBaseTextCell should implement.
 */
@protocol PMRActivityCellDelegate <PMRBaseTextCellDelegate>
@optional

/*!
 Sent to the delegate when the activity button is tapped
 @param activity the PFObject of the activity that was tapped
 */
- (void)cell:(PMRActivityCell *)cellView didTapActivityButton:(PFObject *)activity;

@end