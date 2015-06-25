//
//  PMSkillHeaderView.m
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-23.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import "PMRSkillHeaderView.h"
#import "PMRProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "PMConstants.h"


@interface PMRSkillHeaderView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) PMRProfileImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@end


@implementation PMRSkillHeaderView
@synthesize containerView;
@synthesize avatarImageView;
@synthesize userButton;
@synthesize timestampLabel;
@synthesize timeIntervalFormatter;
@synthesize skill;
@synthesize buttons;
@synthesize endorseButton;
@synthesize commentButton;
@synthesize delegate;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame buttons:(PMSkillHeaderButtons)otherButtons {
    self = [super initWithFrame:frame];
    if (self) {
        [PMRSkillHeaderView validateButtons:otherButtons];
        buttons = otherButtons;
        
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 20.0f, 0.0f, self.bounds.size.width - 20.0f * 2.0f, self.bounds.size.height)];
        [self addSubview:self.containerView];
        [self.containerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]]];
        
        
        self.avatarImageView = [[PMRProfileImageView alloc] init];
        self.avatarImageView.frame = CGRectMake( 4.0f, 4.0f, 35.0f, 35.0f);
        [self.avatarImageView.profileButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:self.avatarImageView];
        
        
        if (self.buttons & PMRSkillHeaderButtonsComment) {
            // comments button
            commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.commentButton];
            [self.commentButton setFrame:CGRectMake( 242.0f, 10.0f, 29.0f, 28.0f)];
            [self.commentButton setBackgroundColor:[UIColor clearColor]];
            [self.commentButton setTitle:@"" forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor colorWithRed:0.369f green:0.271f blue:0.176f alpha:1.0f] forState:UIControlStateNormal];
            [self.commentButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
            [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake( -4.0f, 0.0f, 0.0f, 0.0f)];
            [[self.commentButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
            [[self.commentButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
            [[self.commentButton titleLabel] setMinimumScaleFactor:11.0f];
            [[self.commentButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [self.commentButton setBackgroundImage:[UIImage imageNamed:@"IconComment.png"] forState:UIControlStateNormal];
            [self.commentButton setSelected:NO];
        }
        
        if (self.buttons & PMRSkillHeaderButtonsEndorse) {
            // endorse button
            endorseButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.endorseButton];
            [self.endorseButton setFrame:CGRectMake(206.0f, 8.0f, 29.0f, 29.0f)];
            [self.endorseButton setBackgroundColor:[UIColor clearColor]];
            [self.endorseButton setTitle:@"" forState:UIControlStateNormal];
            [self.endorseButton setTitleColor:[UIColor colorWithRed:0.369f green:0.271f blue:0.176f alpha:1.0f] forState:UIControlStateNormal];
            [self.endorseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [self.endorseButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
            [self.endorseButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.750f] forState:UIControlStateSelected];
            [self.endorseButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
            [[self.endorseButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
            [[self.endorseButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
            [[self.endorseButton titleLabel] setMinimumScaleFactor:11.0f];
            [[self.endorseButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [self.endorseButton setAdjustsImageWhenHighlighted:NO];
            [self.endorseButton setAdjustsImageWhenDisabled:NO];
            [self.endorseButton setBackgroundImage:[UIImage imageNamed:@"ButtonLike.png"] forState:UIControlStateNormal];
            [self.endorseButton setBackgroundImage:[UIImage imageNamed:@"ButtonLikeSelected.png"] forState:UIControlStateSelected];
            [self.endorseButton setSelected:NO];
        }
        
        if (self.buttons & PMRSkillHeaderButtonsUser) {
            // This is the user's display name, on a button so that we can tap on it
            self.userButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.userButton];
            [self.userButton setBackgroundColor:[UIColor clearColor]];
            [[self.userButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15]];
            [self.userButton setTitleColor:[UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.userButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
            [[self.userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
            [[self.userButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
            [self.userButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
        }
        
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
        // timestamp
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50.0f, 24.0f, containerView.bounds.size.width - 50.0f - 72.0f, 18.0f)];
        [containerView addSubview:self.timestampLabel];
        [self.timestampLabel setTextColor:[UIColor colorWithRed:124.0f/255.0f green:124.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
        [self.timestampLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f]];
        [self.timestampLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [self.timestampLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.timestampLabel setBackgroundColor:[UIColor clearColor]];
        
        CALayer *layer = [containerView layer];
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
        layer.masksToBounds = NO;
        layer.shadowRadius = 1.0f;
        layer.shadowOffset = CGSizeMake( 0.0f, 2.0f);
        layer.shadowOpacity = 0.5f;
        layer.shouldRasterize = YES;
        layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake( 0.0f, containerView.frame.size.height - 4.0f, containerView.frame.size.width, 4.0f)].CGPath;
    }
    
    return self;
}


#pragma mark - PAPPhotoHeaderView

- (void)setSkill:(PFObject *)aSkill {

    // user's avatar
    PFUser *user = [aSkill objectForKey:kPMSkillUserKey];
    PFFile *profilePictureSmall = [user objectForKey:kPMUserProfilePicSmallKey];
    [self.avatarImageView setFile:profilePictureSmall];
    
    NSString *authorName = [user objectForKey:kPMUserDisplayNameKey];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    CGFloat constrainWidth = containerView.bounds.size.width;
    
    if (self.buttons & PMRSkillHeaderButtonsUser) {
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & PMRSkillHeaderButtonsComment) {
        constrainWidth = self.commentButton.frame.origin.x;
        [self.commentButton addTarget:self action:@selector(didTapCommentOnSkillButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & PMRSkillHeaderButtonsEndorse) {
        constrainWidth = self.endorseButton.frame.origin.x;
        [self.endorseButton addTarget:self action:@selector(didTapEndorseSkillButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // we resize the button to fit the user's name to avoid having a huge touch area
    CGPoint userButtonPoint = CGPointMake(50.0f, 6.0f);
    constrainWidth -= userButtonPoint.x;
    CGSize constrainSize = CGSizeMake(constrainWidth, containerView.bounds.size.height - userButtonPoint.y*2.0f);
    CGRect userButtonBoundingRect = [self.userButton.titleLabel.text boundingRectWithSize:constrainSize
                                                                             options:NSStringDrawingTruncatesLastVisibleLine
                                                                          attributes:@{NSFontAttributeName:self.userButton.titleLabel.font}
                                                                             context:nil];
    CGSize userButtonSize = userButtonBoundingRect.size;
    CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
    [self.userButton setFrame:userButtonFrame];
    
    NSTimeInterval timeInterval = [[aSkill createdAt] timeIntervalSinceNow];
    NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
    [self.timestampLabel setText:timestamp];
    
    [self setNeedsDisplay];
}

- (void)setEndorseStatus:(BOOL)endorsed {
    [self.endorseButton setSelected:endorsed];
    
    if (endorsed) {
        [self.endorseButton setTitleEdgeInsets:UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f)];
        [[self.endorseButton titleLabel] setShadowOffset:CGSizeMake(0.0f, -1.0f)];
    } else {
        [self.endorseButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [[self.endorseButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    }
}

- (void)shouldEnableEndorseButton:(BOOL)enable {
    if (enable) {
        [self.endorseButton removeTarget:self action:@selector(didTapEndorseSkillButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.endorseButton addTarget:self action:@selector(didTapEndorseSkillButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - ()

+ (void)validateButtons:(PMSkillHeaderButtons)buttons {
    if (buttons == PMRSkillHeaderButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing PMSkillHeaderView."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(skillHeaderView:didTapUserButton:user:)]) {
        [delegate skillHeaderView:self didTapUserButton:sender user:[self.skill objectForKey:kPMSkillUserKey]];
    }
}

- (void)didTapEndorseSkillButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(skillHeaderView:didTapEndorseSkillButton:skill:)]) {
        [delegate skillHeaderView:self didTapEndorseSkillButton:button skill:self.skill];
    }
}

- (void)didTapCommentOnSkillButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(skillHeaderView:didTapCommentOnSkillButton:skill:)]) {
        [delegate skillHeaderView:self didTapCommentOnSkillButton:sender skill:self.skill];
    }
}

@end
