//
//  PMREditButtonItem.m
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-26.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import "PMREditButtonItem.h"

@implementation PMREditButtonItem

#pragma mark - Initialization

- (id)initWithTarget:(id)target action:(SEL)action {
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self = [super initWithCustomView:settingsButton];
    if (self) {
        [settingsButton setFrame:CGRectMake( 0.0f, 0.0f, 52.0f, 32.0f)];
        [settingsButton setTitle:@"Edit" forState:UIControlStateNormal];
        [settingsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[settingsButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
        [settingsButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 5.0f)];
        [settingsButton setBackgroundImage:[UIImage imageNamed:@"ButtonSettings.png"] forState:UIControlStateNormal];
        [settingsButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [settingsButton setFrame:CGRectMake(0.0f, 0.0f, 35.0f, 32.0f)];
        [settingsButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
    
    return self;
}
@end
