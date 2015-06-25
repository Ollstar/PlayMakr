//
//  PAPPhotoDetailViewController.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//

#import "PMRSkillDetailsHeaderView.h"
#import "PMRBaseTextCell.h"
#import <ParseUI/ParseUI.h>

@interface PMRSkillDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, PMSkillDetailsHeaderViewDelegate, PMRBaseTextCellDelegate>

@property (nonatomic, strong) PFObject *skill;

- (id)initWithSkill:(PFObject*)aSkill;

@end
