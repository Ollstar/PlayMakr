//
//  PMRLogInViewController.m
//  PlayMakr
//
//  Created by Ollstar.
//

#import "PMRLogInViewController.h"

@implementation PMRLogInViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.png"]];
    
    NSString *text = @"Sign up and start sharing your PlayMakr Personality with your friends.";
    
    CGRect textBoundingRect = [text boundingRectWithSize:CGSizeMake( 255.0f, CGFLOAT_MAX)
                                                 options:NSStringDrawingTruncatesLastVisibleLine
                                              attributes:@{NSFontAttributeName:@"HelveticaNeue-Medium"}
                                                 context:nil];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:textBoundingRect];
    [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f]];
    [textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [textLabel setNumberOfLines:0];
    [textLabel setText:text];
    [textLabel setTextColor:[UIColor colorWithRed:214.0f/255.0f green:206.0f/255.0f blue:191.0f/255.0f alpha:1.0f]];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setTextAlignment:NSTextAlignmentCenter];

    [self.logInView setLogo:nil];
    [self.logInView addSubview:textLabel]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
