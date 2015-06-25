//
//  PAPHomeViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//

#import "PMRSkillTimelineViewController.h"
#import "PMRFindFriendsViewController.h"

@interface PMRHomeViewController : PMRSkillTimelineViewController

@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;

@end
