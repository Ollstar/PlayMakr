//
//  PAPAccountViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//

#import "PMRSkillTimelineViewController.h"

@interface PMRAccountViewController : PMRSkillTimelineViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) PFUser *user;
@property (strong, nonatomic) IBOutlet PFImageView *userProfileImageView;


@end
