//
//  PAPPhotoTimelineViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//

#import "PMRSkillHeaderView.h"
#import <ParseUI/ParseUI.h>

@interface PMRSkillTimelineViewController : PFQueryTableViewController <PMRSkillHeaderViewDelegate>

- (PMRSkillHeaderView *)dequeueReusableSectionHeaderView;

@end
