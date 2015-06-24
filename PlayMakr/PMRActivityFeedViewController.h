//
//  PAPActivityFeedViewController.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "PMRActivityCell.h"

@interface PMRActivityFeedViewController : PFQueryTableViewController <PMRActivityCellDelegate>

+ (NSString *)stringForActivityType:(NSString *)activityType;

@end
